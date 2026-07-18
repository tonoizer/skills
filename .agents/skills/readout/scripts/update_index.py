#!/usr/bin/env python3
"""Regenerate a readout library index from document metadata."""

from __future__ import annotations

import html
import os
import re
import sys
import tempfile
from datetime import datetime
from html.parser import HTMLParser
from pathlib import Path

DATE_RE = re.compile(r"^(\d{4}-\d{2}-\d{2})")


class MetadataParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.in_title = False
        self.title_parts: list[str] = []
        self.description = ""

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        values = dict(attrs)
        if tag == "title":
            self.in_title = True
        elif tag == "meta" and values.get("name", "").lower() == "description":
            self.description = values.get("content") or ""

    def handle_endtag(self, tag: str) -> None:
        if tag == "title":
            self.in_title = False

    def handle_data(self, data: str) -> None:
        if self.in_title:
            self.title_parts.append(data)


def metadata(path: Path) -> dict[str, object]:
    parser = MetadataParser()
    parser.feed(path.read_text(encoding="utf-8", errors="replace"))
    match = DATE_RE.match(path.name)
    return {
        "file": path.name,
        "title": "".join(parser.title_parts).strip() or path.stem,
        "description": parser.description.strip(),
        "date": match.group(1) if match else datetime.fromtimestamp(path.stat().st_mtime).strftime("%Y-%m-%d"),
        "mtime": path.stat().st_mtime,
    }


def page(entries: list[dict[str, object]]) -> str:
    items = []
    for entry in entries:
        description = entry["description"]
        desc = f'<p>{html.escape(str(description))}</p>' if description else ""
        items.append(
            f'<li><time>{entry["date"]}</time><a href="{html.escape(str(entry["file"]), quote=True)}">'
            f'{html.escape(str(entry["title"]))}</a>{desc}</li>'
        )
    body = "\n".join(items) or "<li>No readouts yet.</li>"
    return f'''<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Readouts</title><style>:root{{color-scheme:light dark;--bg:#faf8f3;--ink:#28241f;--muted:#766f64;--line:#ddd6c9;--accent:#315d76}}@media(prefers-color-scheme:dark){{:root{{--bg:#1d1b18;--ink:#ece7dd;--muted:#aaa092;--line:#403b34;--accent:#91bfd3}}}}body{{max-width:48rem;margin:0 auto;padding:3rem 1.25rem;background:var(--bg);color:var(--ink);font:17px/1.55 Charter,Georgia,serif}}h1{{margin-bottom:.2rem}}.sub,time,p{{color:var(--muted)}}ol{{list-style:none;padding:0}}li{{border-top:1px solid var(--line);padding:1rem 0}}time{{display:block;font:12px ui-monospace,monospace}}a{{display:block;color:var(--ink);font-size:1.08rem;font-weight:700;text-decoration:none}}a:hover{{color:var(--accent)}}p{{margin:.2rem 0}}</style></head>
<body><h1>Readouts</h1><p class="sub">{len(entries)} document{"" if len(entries)==1 else "s"} · newest first</p><ol>{body}</ol></body></html>'''


def main() -> int:
    root = Path(sys.argv[1]).expanduser() if len(sys.argv) > 1 else Path(os.environ.get("READOUTS_HOME", Path.home() / ".readouts")).expanduser()
    root.mkdir(parents=True, exist_ok=True)
    entries = [metadata(path) for path in root.glob("*.html") if path.name != "index.html"]
    entries.sort(key=lambda item: (str(item["date"]), float(item["mtime"])), reverse=True)
    output = page(entries)
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=root, delete=False) as handle:
        handle.write(output)
        temporary = Path(handle.name)
    temporary.replace(root / "index.html")
    print(f"Indexed {len(entries)} readout(s) -> {root / 'index.html'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
