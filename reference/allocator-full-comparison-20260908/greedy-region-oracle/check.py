#!/usr/bin/env python3
"""Replay independent exhaustive checks against the captured native solver output."""
import hashlib
import json
import sys
from pathlib import Path

directory = Path(__file__).resolve().parent
sys.path.insert(0, str(directory.parent))
from witnesses import check_placement

source = json.loads((directory / "source.json").read_text())
assert hashlib.sha256((directory / "solver-snapshot.factor").read_bytes()).hexdigest() == source["source_sha256"]
inputs = json.loads((directory / "inputs.json").read_text())
records = [json.loads(line) for line in (directory / "output.jsonl").read_text().splitlines()]
assert len(records) == len(inputs) == source["cases"]
for expected, result in zip(inputs, records):
    assert result["nodes"] == expected["nodes"] and result["edges"] == expected["edges"]
    check_placement(dict(
        costs={str(i): [node[0], 0] for i, node in enumerate(result["nodes"])},
        edges=[[str(a), str(b), c] for a, b, c in result["edges"]],
        hard={str(i): 0 for i, node in enumerate(result["nodes"]) if node[1]},
        resident={str(i): int(value) for i, value in enumerate(result["resident"])},
        cost=result["cost"]))
print(f"All {len(records)} native solver results match the exhaustive optimum and hard constraints.")
