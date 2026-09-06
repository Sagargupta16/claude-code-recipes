#!/usr/bin/env python3
"""Fail if any tracked file contains an em dash (U+2014) or en dash (U+2013).

This repo writes ``--`` and ``-`` instead. Two earlier sweeps missed most of the
tree because they were done by hand, so it is a CI check now.

The banned characters are built from their code points rather than written
literally, so that this file does not trip its own check.

Usage: python scripts/check_dashes.py
"""

from __future__ import annotations

import pathlib
import subprocess
import sys

BANNED = {
    chr(0x2014): "em dash (U+2014), write -- instead",
    chr(0x2013): "en dash (U+2013), write - instead",
}


def tracked_files() -> list[str]:
    result = subprocess.run(
        ["git", "ls-files"], capture_output=True, text=True, check=True
    )
    return [line for line in result.stdout.splitlines() if line]


def main() -> int:
    hits = 0
    for name in tracked_files():
        path = pathlib.Path(name)
        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        for line_number, line in enumerate(text.splitlines(), start=1):
            for char, message in BANNED.items():
                if char in line:
                    print(f"{name}:{line_number}: {message}", file=sys.stderr)
                    hits += 1
    if hits:
        print(f"\n{hits} banned dash character(s) found.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
