#!/usr/bin/env python3
"""Validate a generated readout's structure, portability, and source integrity."""

from __future__ import annotations

import argparse
from collections import defaultdict
import json
import re
import subprocess
import sys
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlparse

PLACEHOLDER_RE = re.compile(r"\{\{[A-Z][A-Z0-9_]*\}\}")
BLOB_RE = re.compile(r"^/([^/]+)/([^/]+)/blob/([0-9a-fA-F]{40})/(.+)$")
LINE_RE = re.compile(r"^L\d+(?:-L\d+)?$")
KEY_RE = re.compile(r"^([^/]+)/([^@]+)@([0-9a-f]{40}):(.+)$")
VOID = {"area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"}
RENDER_URL_ATTRIBUTES = {"src", "srcset", "data", "poster", "xlink:href"}
MAX_PAYLOAD_BYTES = 524_288
MAX_ENTRY_COUNT = 128
MAX_WINDOW_COUNT = 256
MAX_WINDOW_BYTES = 65_536


def inline_render_reference(value: str) -> bool:
    value = value.strip()
    return not value or value.startswith("#")


def css_has_external_reference(css: str) -> bool:
    if re.search(r"@import\b", css, re.I):
        return True
    for match in re.finditer(r"url\(\s*(['\"]?)(.*?)\1\s*\)", css, re.I | re.S):
        if not inline_render_reference(match.group(2)):
            return True
    return False


def blob_reference(href: str) -> tuple[str, int, int] | str | None:
    parsed = urlparse(href)
    if parsed.netloc.lower() != "github.com" or "/blob/" not in parsed.path:
        return None
    match = BLOB_RE.match(parsed.path)
    if not match or not LINE_RE.match(parsed.fragment):
        return ""
    org, repo, commit, path = match.groups()
    line_match = re.fullmatch(r"L(\d+)(?:-L(\d+))?", parsed.fragment)
    assert line_match is not None
    start, end = int(line_match.group(1)), int(line_match.group(2) or line_match.group(1))
    if start > end:
        start, end = end, start
    return f"{org.lower()}/{repo.lower()}@{commit.lower()}:{unquote(path)}", start, end


def run_git(checkout: Path, *args: str) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run(["git", "-C", str(checkout), *args], capture_output=True, check=False)


def repo_slug(checkout: Path) -> str | None:
    result = run_git(checkout, "remote", "get-url", "origin")
    if result.returncode:
        return None
    remote = result.stdout.decode(errors="replace").strip()
    match = re.search(r"github\.com[:/]([^/]+)/(.+?)(?:\.git)?/?$", remote)
    return f"{match.group(1)}/{match.group(2)}".lower() if match else None


def commit_on_origin(checkout: Path, commit: str) -> bool:
    result = run_git(
        checkout, "for-each-ref", "--contains", commit,
        "--format=%(refname)", "refs/remotes/origin/",
    )
    return result.returncode == 0 and bool(result.stdout.strip())


def merge_ranges(ranges: list[tuple[int, int]], line_count: int, context: int = 0) -> list[tuple[int, int]]:
    expanded = sorted((max(1, start - context), min(line_count, end + context)) for start, end in ranges)
    merged: list[list[int]] = []
    for start, end in expanded:
        if merged and start <= merged[-1][1] + 1:
            merged[-1][1] = max(merged[-1][1], end)
        else:
            merged.append([start, end])
    return [(start, end) for start, end in merged]


class ReadoutParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.ids: set[str] = set()
        self.internal_targets: list[str] = []
        self.source_links: dict[str, list[tuple[int, int]]] = defaultdict(list)
        self.errors: list[str] = []
        self.stack: list[str] = []
        self.title = ""
        self.in_title = False
        self.description = ""
        self.has_summary = False
        self.has_provenance = False
        self.snippet_data: list[str] = []
        self.capture_snippets = False
        self.style_data: list[str] = []
        self.capture_style = False

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        values = dict(attrs)
        if tag not in VOID:
            self.stack.append(tag)
        element_id = values.get("id")
        if element_id:
            if element_id in self.ids:
                self.errors.append(f"duplicate id: {element_id}")
            self.ids.add(element_id)
            self.has_summary |= element_id == "summary"
        classes = set((values.get("class") or "").split())
        self.has_provenance |= tag == "footer" and "provenance" in classes
        if tag == "title":
            self.in_title = True
        if tag == "meta" and values.get("name", "").lower() == "description":
            self.description = values.get("content") or ""
        if tag == "a":
            href = values.get("href") or ""
            if href.startswith("#"):
                self.internal_targets.append(href[1:])
            reference = blob_reference(href)
            if reference == "":
                self.errors.append(f"source link is not pinned to a full commit and line range: {href}")
            elif reference:
                identity, start, end = reference
                self.source_links[identity].append((start, end))
        for attribute, resource in attrs:
            if not resource:
                continue
            render_bearing = attribute in RENDER_URL_ATTRIBUTES or (attribute == "href" and tag != "a")
            if render_bearing and not inline_render_reference(resource):
                self.errors.append(f"non-inline render dependency: <{tag} {attribute}> {resource}")
            if attribute == "style" and css_has_external_reference(resource):
                self.errors.append(f"non-inline dependency in style attribute: <{tag}>")
        if tag == "link" and values.get("href"):
            rel = set((values.get("rel") or "").lower().split())
            if rel & {"stylesheet", "preload", "modulepreload", "prefetch"}:
                self.errors.append(f"linked render dependency is not allowed: {values['href']}")
        if tag == "meta" and (values.get("http-equiv") or "").lower() == "refresh":
            self.errors.append("meta refresh is not allowed")
        if tag == "iframe":
            self.errors.append("iframes and srcdoc content are not allowed")
        if tag == "script" and "data-code-snippets" in values:
            self.capture_snippets = True
        if tag == "style":
            self.capture_style = True

    def handle_endtag(self, tag: str) -> None:
        if tag == "title":
            self.in_title = False
        if tag == "script" and self.capture_snippets:
            self.capture_snippets = False
        if tag == "style":
            self.capture_style = False
        if tag in VOID:
            return
        if not self.stack:
            self.errors.append(f"unexpected closing tag: {tag}")
            return
        opened = self.stack.pop()
        if opened != tag:
            self.errors.append(f"mismatched tags: opened <{opened}> but closed </{tag}>")

    def handle_data(self, data: str) -> None:
        if self.in_title:
            self.title += data
        if self.capture_snippets:
            self.snippet_data.append(data)
        if self.capture_style:
            self.style_data.append(data)


def validate_snippets(
    chunks: list[str], source_links: dict[str, list[tuple[int, int]]],
    checkouts: dict[str, Path], max_context: int, errors: list[str]
) -> None:
    if len(chunks) > 1:
        errors.append("multiple embedded snippet payloads are not allowed")
    total_windows = 0
    for chunk in chunks:
        if len(chunk.encode("utf-8")) > MAX_PAYLOAD_BYTES:
            errors.append(f"embedded snippet payload exceeds {MAX_PAYLOAD_BYTES} bytes")
        try:
            payload = json.loads(chunk)
        except json.JSONDecodeError as error:
            errors.append(f"invalid embedded snippet JSON: {error}")
            continue
        if not isinstance(payload, dict):
            errors.append("embedded snippet JSON must be an object")
            continue
        if len(payload) > MAX_ENTRY_COUNT:
            errors.append(f"embedded snippet payload exceeds {MAX_ENTRY_COUNT} entries")
        for key, entry in payload.items():
            key_match = KEY_RE.match(key) if isinstance(key, str) else None
            if not key_match:
                errors.append(f"invalid canonical snippet key: {key}")
                continue
            org, repo, key_commit, key_path = key_match.groups()
            slug = f"{org}/{repo}".lower()
            canonical_key = f"{slug}@{key_commit}:{key_path}"
            if key != canonical_key:
                errors.append(f"snippet key is not canonical lowercase identity: {key}")
            if key not in source_links:
                errors.append(f"snippet has no matching pinned source link: {key}")
            if not isinstance(entry, dict):
                errors.append(f"snippet entry must be an object: {key}")
                continue
            if entry.get("commit") != key_commit or entry.get("path") != key_path:
                errors.append(f"snippet metadata does not match its key: {key}")
            windows = entry.get("windows", [])
            if not isinstance(windows, list) or not windows:
                errors.append(f"snippet entry has no windows: {key}")
                continue
            total_windows += len(windows)
            checkout = checkouts.get(slug)
            source_lines: list[str] | None = None
            covered_ranges: list[tuple[int, int]] = []
            if checkout is None:
                errors.append(f"no --repo checkout available to verify snippet: {key}")
            else:
                exact = run_git(checkout, "cat-file", "-e", f"{key_commit}^{{commit}}")
                if not exact.returncode and not commit_on_origin(checkout, key_commit):
                    errors.append(f"snippet commit is not reachable from an origin remote-tracking ref: {key}")
                result = run_git(checkout, "show", f"{key_commit}:{key_path}") if not exact.returncode else exact
                if result.returncode:
                    errors.append(f"cannot load exact source revision for snippet: {key}")
                else:
                    try:
                        source_lines = result.stdout.decode("utf-8").splitlines()
                    except UnicodeDecodeError:
                        errors.append(f"exact source is not UTF-8 text: {key}")
            for window in windows:
                if not isinstance(window, dict):
                    errors.append(f"snippet window must be an object: {key}")
                    continue
                text = window.get("text")
                start = window.get("start")
                if not isinstance(text, str):
                    errors.append(f"snippet window text must be a string: {key}")
                    continue
                if len(text.encode("utf-8")) > MAX_WINDOW_BYTES:
                    errors.append(f"snippet window exceeds {MAX_WINDOW_BYTES} bytes: {key}")
                window_lines = text.splitlines()
                if not window_lines:
                    errors.append(f"snippet window is empty: {key}")
                    continue
                if len(window_lines) > 120:
                    errors.append(f"snippet window exceeds 120 lines: {key}")
                if not isinstance(start, int) or start < 1:
                    errors.append(f"snippet window has invalid start line: {key}")
                    continue
                if source_lines is not None:
                    end = start + len(window_lines) - 1
                    covered_ranges.append((start, end))
                    expected = source_lines[start - 1:start - 1 + len(window_lines)]
                    if expected != window_lines:
                        errors.append(f"snippet text does not match exact source revision: {key}@L{start}")
                    allowed = merge_ranges(source_links.get(key, []), len(source_lines), max_context)
                    if not any(start >= first and end <= last for first, last in allowed):
                        errors.append(f"snippet window exceeds cited lines plus context: {key}@L{start}-L{end}")
            if source_lines is not None:
                covered = merge_ranges(covered_ranges, len(source_lines))
                if covered == [(1, len(source_lines))]:
                    errors.append(f"snippet windows collectively embed an entire file: {key}")
    if total_windows > MAX_WINDOW_COUNT:
        errors.append(f"embedded snippet payload exceeds {MAX_WINDOW_COUNT} windows")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("doc", type=Path)
    parser.add_argument("--repo", action="append", type=Path, default=[])
    parser.add_argument("--context", type=int, default=4)
    args = parser.parse_args()
    if not 0 <= args.context <= 20:
        parser.error("--context must be between 0 and 20")
    source = args.doc.read_text(encoding="utf-8")
    errors: list[str] = []
    if PLACEHOLDER_RE.search(source):
        errors.append("template placeholders remain")
    parsed = ReadoutParser()
    try:
        parsed.feed(source)
        parsed.close()
    except Exception as error:
        errors.append(f"HTML parse failure: {error}")
    errors.extend(parsed.errors)
    if any(css_has_external_reference(css) for css in parsed.style_data):
        errors.append("non-inline reference inside a style block is not allowed")
    if parsed.stack:
        errors.append(f"unclosed tags: {', '.join(parsed.stack)}")
    if not parsed.title.strip():
        errors.append("missing document title")
    if not parsed.description.strip():
        errors.append("missing meta description")
    if not parsed.has_summary:
        errors.append("missing #summary section")
    if not parsed.has_provenance:
        errors.append("missing provenance footer")
    missing = sorted({target for target in parsed.internal_targets if target and target not in parsed.ids})
    if missing:
        errors.append(f"internal link targets do not exist: {', '.join(missing)}")
    checkouts: dict[str, Path] = {}
    for checkout in args.repo:
        slug = repo_slug(checkout.resolve())
        if slug:
            checkouts[slug] = checkout.resolve()
        else:
            errors.append(f"cannot derive GitHub slug for --repo checkout: {checkout}")
    validate_snippets(parsed.snippet_data, parsed.source_links, checkouts, args.context, errors)
    if errors:
        for error in errors:
            print(f"error: {error}", file=sys.stderr)
        return 1
    print(f"Valid readout: {args.doc}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
