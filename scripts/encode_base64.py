#!/usr/bin/env python3
"""Encode signing assets to base64 for Codemagic secrets.

Usage:
    python scripts/encode_base64.py path/to/file

Prints a single-line base64 string to stdout. Use --env-var NAME to emit a
ready-to-paste 'NAME=...' line, or --out FILE to save the output.
"""
from __future__ import annotations

import argparse
import base64
import pathlib
import sys
from typing import Optional


def encode_file(path: pathlib.Path) -> str:
    data = path.read_bytes()
    encoded = base64.b64encode(data).decode("ascii")
    return encoded


def write_output(text: str, destination: Optional[pathlib.Path]) -> None:
    if destination is None:
        print(text)
        return
    destination.write_text(text, encoding="utf-8")
    print(f"Wrote base64 output to {destination}")


def main(argv: Optional[list[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Base64-encode a file for Codemagic secrets.")
    parser.add_argument("file", type=pathlib.Path, help="Path to the certificate, provisioning profile, or API key file")
    parser.add_argument(
        "--env-var",
        dest="env_var",
        metavar="NAME",
        help="Wrap the output as NAME=... so it can be pasted into Codemagic's environment editor.",
    )
    parser.add_argument(
        "--out",
        dest="out_path",
        type=pathlib.Path,
        help="Optional path to save the output instead of printing to stdout.",
    )

    args = parser.parse_args(argv)

    if not args.file.exists():
        print(f"error: {args.file} does not exist", file=sys.stderr)
        return 1

    encoded = encode_file(args.file)
    if args.env_var:
        encoded = f"{args.env_var}={encoded}"

    write_output(encoded, args.out_path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
