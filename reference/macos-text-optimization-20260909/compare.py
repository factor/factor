"""Compare native GL readbacks without allocating a Factor array per component."""
import json
from pathlib import Path

root = Path(__file__).resolve().parent
records = [json.loads(line) for line in (root / "results.jsonl").read_text().splitlines()
           if line.startswith("[")]
results = []
for i, case in enumerate(record for record in records if record[0] == "tiles"):
    tiled = (root / f"{i}-tiled.rgba").read_bytes()
    reference = (root / f"{i}-reference.rgba").read_bytes()
    assert len(tiled) == len(reference) == 1024 * case[-1] * 4
    maximum = max(abs(a - b) for a, b in zip(tiled, reference))
    changed = sum(a != b for a, b in zip(tiled, reference))
    result = {"case": i, "scale": case[1], "scroll": case[2], "phase": case[3],
              "max_component_error": maximum, "changed_components": changed}
    results.append(result)
    print(result)
    assert maximum <= 1, result
(root / "pixel-results.json").write_text(json.dumps(results, indent=2) + "\n")
assert len(results) == 5
