#!/usr/bin/env python3
"""Embed only cited, exact-commit source windows into a readout."""

from __future__ import annotations

import argparse
import html
import json
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path
from urllib.parse import unquote

BLOB_RE = re.compile(
    r"https://github\.com/([^/\"'<>\s]+)/([^/\"'<>\s]+)/blob/"
    r"([0-9a-fA-F]{40})/([^#\"'<>\s?]+)#L(\d+)(?:-L(\d+))?"
)
SNIPPET_RE = re.compile(
    r'<script type="application/json" data-code-snippets>.*?</script>\s*', re.S
)
SENSITIVE_PARTS = {
    ".env", "credentials", "credential", "id_rsa", "id_ed25519",
    "private-key", "private_key", "secrets", "secret", "token",
}
SENSITIVE_SUFFIXES = {".pem", ".p12", ".pfx", ".key", ".keystore"}
SECRET_CONTENT_RE = re.compile(
    r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----"
    r"|AKIA[0-9A-Z]{16}"
    r"|(?i:(?:password|passwd|api[_-]?key|access[_-]?token|client[_-]?secret)\s*[:=]\s*['\"][^'\"]{12,}['\"])",
)


def run_git(checkout: Path, *args: str) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run(
        ["git", "-C", str(checkout), *args], capture_output=True, check=False
    )


def repo_slug(checkout: Path) -> str | None:
    result = run_git(checkout, "remote", "get-url", "origin")
    if result.returncode:
        return None
    remote = result.stdout.decode(errors="replace").strip()
    match = re.search(r"github\.com[:/]([^/]+)/(.+?)(?:\.git)?/?$", remote)
    return f"{match.group(1)}/{match.group(2)}" if match else None


def commit_on_origin(checkout: Path, commit: str) -> bool:
    result = run_git(
        checkout, "for-each-ref", "--contains", commit,
        "--format=%(refname)", "refs/remotes/origin/",
    )
    return result.returncode == 0 and bool(result.stdout.strip())


def sensitive(path: str) -> bool:
    parts = {part.lower() for part in Path(path).parts}
    name = Path(path).name.lower()
    stem_tokens = set(re.split(r"[^a-z0-9]+", Path(name).stem))
    return (
        bool(parts & SENSITIVE_PARTS)
        or bool(stem_tokens & SENSITIVE_PARTS)
        or name.startswith(".env")
        or Path(name).suffix in SENSITIVE_SUFFIXES
    )


def merge_ranges(ranges: list[tuple[int, int]], line_count: int, context: int) -> list[tuple[int, int]]:
    expanded = sorted((max(1, start - context), min(line_count, end + context)) for start, end in ranges)
    merged: list[list[int]] = []
    for start, end in expanded:
        if merged and start <= merged[-1][1] + 1:
            merged[-1][1] = max(merged[-1][1], end)
        else:
            merged.append([start, end])
    return [(start, end) for start, end in merged]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("doc", type=Path)
    parser.add_argument("--repo", action="append", type=Path, required=True)
    parser.add_argument("--public-repo", action="append", default=[], metavar="ORG/REPO")
    parser.add_argument("--private-source-approved", action="store_true")
    parser.add_argument("--context", type=int, default=4)
    parser.add_argument("--max-window-lines", type=int, default=120)
    parser.add_argument("--max-total-bytes", type=int, default=524_288)
    args = parser.parse_args()

    if not 0 <= args.context <= 20:
        parser.error("--context must be between 0 and 20")

    source = args.doc.read_text(encoding="utf-8")
    refs: dict[tuple[str, str, str], list[tuple[int, int]]] = defaultdict(list)
    for match in BLOB_RE.finditer(html.unescape(source)):
        org, repo, commit, encoded_path, start, end = match.groups()
        path = unquote(encoded_path)
        first, last = int(start), int(end or start)
        if first > last:
            first, last = last, first
        refs[(f"{org}/{repo}", commit.lower(), path)].append((first, last))

    if not refs:
        print("No commit-pinned GitHub line links found; nothing to embed.")
        return 0

    checkouts: dict[str, Path] = {}
    for checkout in args.repo:
        slug = repo_slug(checkout.resolve())
        if not slug:
            print(f"warning: {checkout} has no GitHub origin; skipping", file=sys.stderr)
            continue
        checkouts[slug.lower()] = checkout.resolve()

    public = {slug.lower() for slug in args.public_repo}
    snippets: dict[str, dict[str, object]] = {}
    total_bytes = 0
    errors: list[str] = []

    for (slug, commit, path), ranges in sorted(refs.items()):
        label = f"{slug.lower()}@{commit}:{path}"
        checkout = checkouts.get(slug.lower())
        if checkout is None:
            errors.append(f"{label}: no matching --repo checkout")
            continue
        if slug.lower() not in public and not args.private_source_approved:
            print(f"links only: {slug} is not declared public and private embedding was not approved")
            continue
        if sensitive(path):
            errors.append(f"{label}: sensitive path refused")
            continue
        exists = run_git(checkout, "cat-file", "-e", f"{commit}^{{commit}}")
        if exists.returncode:
            errors.append(f"{label}: exact commit is unavailable locally")
            continue
        if not commit_on_origin(checkout, commit):
            errors.append(f"{label}: commit is not reachable from an origin remote-tracking ref")
            continue
        result = run_git(checkout, "show", f"{commit}:{path}")
        if result.returncode:
            errors.append(f"{label}: file is unavailable at the exact commit")
            continue
        try:
            text = result.stdout.decode("utf-8")
        except UnicodeDecodeError:
            errors.append(f"{label}: binary or non-UTF-8 file refused")
            continue
        lines = text.splitlines()
        if not lines:
            errors.append(f"{label}: empty file")
            continue
        if any(start < 1 or end > len(lines) for start, end in ranges):
            errors.append(f"{label}: cited line range is outside the file")
            continue
        windows = []
        for start, end in merge_ranges(ranges, len(lines), args.context):
            if start == 1 and end == len(lines):
                errors.append(f"{label}: cited window would embed the entire file")
                windows = []
                break
            if end - start + 1 > args.max_window_lines:
                errors.append(f"{label}: embedded window exceeds {args.max_window_lines} lines")
                windows = []
                break
            excerpt = "\n".join(lines[start - 1:end])
            if SECRET_CONTENT_RE.search(excerpt):
                errors.append(f"{label}: excerpt resembles a credential or private key")
                windows = []
                break
            total_bytes += len(excerpt.encode("utf-8"))
            windows.append({"start": start, "text": excerpt})
        if windows:
            snippets[label] = {"commit": commit, "path": path, "windows": windows}

    if errors:
        for error in errors:
            print(f"error: {error}", file=sys.stderr)
        return 1
    if total_bytes > args.max_total_bytes:
        print(f"error: embedded excerpts exceed {args.max_total_bytes} bytes", file=sys.stderr)
        return 1
    if not snippets:
        print("No excerpts embedded; pinned links remain available.")
        return 0

    payload = json.dumps(snippets, ensure_ascii=False).replace("</", "<\\/")
    block = f'<script type="application/json" data-code-snippets>\n{payload}\n</script>\n'
    if SNIPPET_RE.search(source):
        source = SNIPPET_RE.sub(lambda _: block, source, count=1)
    elif "<style data-code-pane>" in source:
        source = source.replace("<style data-code-pane>", block + "<style data-code-pane>", 1)
    elif "</body>" in source:
        source = source.replace("</body>", block + "</body>", 1)
    else:
        print("error: readout has no </body> insertion point", file=sys.stderr)
        return 1
    args.doc.write_text(source, encoding="utf-8")
    print(f"Embedded {len(snippets)} exact-commit file excerpt set(s), {total_bytes} bytes -> {args.doc}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
