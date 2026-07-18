#!/usr/bin/env python3
"""Allocate a collision-safe readout path and copy in the canonical template."""

from __future__ import annotations

import argparse
import os
import re
from datetime import date
from pathlib import Path


def slugify(value: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")
    return slug[:72].rstrip("-") or "readout"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("topic")
    parser.add_argument("--directory", type=Path)
    parser.add_argument("--date", default=date.today().isoformat(), dest="date_prefix")
    args = parser.parse_args()
    if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", args.date_prefix):
        parser.error("--date must use YYYY-MM-DD")

    root = args.directory or Path(os.environ.get("READOUTS_HOME", Path.home() / ".readouts"))
    root = root.expanduser().resolve()
    root.mkdir(parents=True, exist_ok=True)
    template = Path(__file__).resolve().parent.parent / "assets" / "template.html"
    content = template.read_bytes()
    stem = f"{args.date_prefix}-{slugify(args.topic)}"
    for suffix in range(1, 10_000):
        ending = "" if suffix == 1 else f"-{suffix}"
        candidate = root / f"{stem}{ending}.html"
        try:
            descriptor = os.open(candidate, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o644)
        except FileExistsError:
            continue
        with os.fdopen(descriptor, "wb") as handle:
            handle.write(content)
        print(candidate)
        return 0
    raise RuntimeError("could not allocate a unique readout filename")


if __name__ == "__main__":
    raise SystemExit(main())
