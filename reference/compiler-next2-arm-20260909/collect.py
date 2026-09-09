"""Read completed ARM gates; never copy active output or infer success from it."""
import gzip
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
EXPECTED = "87ac3f9b1e19a9bee974a52d263f7abce4b61c34"


def collect_suite(allocator):
    source = Path("/tmp/compiler-next2-compiler-" + allocator)
    status_path = source / "status.json"
    if not status_path.exists():
        return {"allocator": allocator, "state": "pending", "path": str(source)}
    status = json.loads(status_path.read_text())
    log = (source / "output.log").read_bytes()
    assets = json.loads((HERE / "frozen-assets.json").read_text())
    remat = "off" if allocator == "linear-scan" else "on"
    checks = {
        "exit_zero": status["exit_code"] == 0,
        "not_timed_out": not status["timed_out"],
        "frozen_source": status["source"] == EXPECTED,
        "clean_source": status["source_status"] == "",
        "zero_test_failures": b"TEST-FAILURES 0" in log,
        "success_marker": b"SPEED compiler-suite=passed" in log,
        "strict_checks": b"checks=ssa,intervals,final-value-flow gvn=off" in log,
        "selected_allocator": ("allocator=" + allocator + "-allocator").encode() in log,
        "selected_flags": status["command"][-3:] == [allocator, remat, "on"],
        "frozen_assets": all(value == assets.get(name) for name, value in status["assets"].items()),
        "frozen_input_image": status["input_image"]["sha256"] == assets["factor.image"],
        "frozen_vm": status["executable"]["sha256"] == assets["Factor.app/Contents/MacOS/factor"],
    }
    destination = HERE / "loaded-compiler" / allocator
    destination.mkdir(parents=True, exist_ok=True)
    for name in ("environment.json", "status.json", "samples.jsonl"):
        (destination / name).write_bytes((source / name).read_bytes())
    (destination / "output.log.gz").write_bytes(gzip.compress(log, mtime=0))
    return {"allocator": allocator, "state": "passed" if all(checks.values()) else "failed-audit",
            "checks": checks, "source": status["source"], "seconds": status["seconds"],
            "output_sha256": hashlib.sha256(log).hexdigest(), "assets": status["assets"],
            "input_image": status["input_image"], "executable": status["executable"]}


if __name__ == "__main__":
    results = [collect_suite(a) for a in ("linear-scan", "greedy", "backtracking", "chordal")]
    (HERE / "suite-audit.json").write_text(json.dumps(results, indent=2) + "\n")
    print(json.dumps([{k: r[k] for k in ("allocator", "state")} for r in results]))
