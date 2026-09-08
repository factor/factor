#!/usr/bin/env python3
"""Run the real printf FFI regression without redirecting the parent C stream."""
import argparse
import os
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("--factor", type=Path, required=True)
parser.add_argument("--image", type=Path, required=True)
parser.add_argument("--root", type=Path, required=True)
args = parser.parse_args()
cases = ["printf.factor"]
if os.name != "nt":
    cases.append("printf-direct.factor")
for case in cases:
    result = subprocess.run([
        str(args.factor.resolve()), "-i=" + str(args.image.resolve()),
        "-resource-path=" + str(args.root.resolve()), "-no-user-init",
        str(args.root.resolve() / "basis/compiler/tests/varargs" / case),
    ], capture_output=True, timeout=120)
    expected = b"value:-42:  1.250:-1234567890123\n"
    # Windows text-mode stdout converts the C newline to CRLF.
    actual = result.stdout.replace(b"\r\n", b"\n")
    if result.returncode != 0 or actual != expected:
        raise SystemExit(f"printf regression {case} failed: exit={result.returncode}, "
                         f"stdout={result.stdout!r}, stderr={result.stderr!r}")
print(f"Real printf bytes and return count passed ({len(cases)} entry points)")
