"""Require identical pixels for the old and cached GPU drawing paths."""
from pathlib import Path

root = Path(__file__).resolve().parent
for case in range(2):
    baseline = (root / f"{case}-baseline.rgba").read_bytes()
    cached = (root / f"{case}-cached.rgba").read_bytes()
    assert len(baseline) == len(cached) == 1024 * 2048 * 4
    assert baseline == cached, case
    print(f"case {case}: {len(baseline)} bytes identical")
