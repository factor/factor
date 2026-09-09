#!/usr/bin/env python3
"""Compare all final allocators after strict paired-result validation.

Input is analyze.py's same-revision candidate/baseline summary. This does not
certify implementation completeness: run only after the contract's timing gate.
"""
import argparse
import json
import math
import statistics
from pathlib import Path

ALLOCATORS = ("linear-scan", "greedy", "backtracking", "chordal")
METRICS = ("cpu_seconds", "ns", "instructions")


def rank(summary):
    source = summary.get("source_commits", {}).get("candidate")
    if not source:
        raise ValueError("candidate source identity is required")
    if summary.get("failed_runs"):
        raise ValueError("failed runs require review before a complete ranking")
    allocators = summary["allocators"]
    if set(allocators) != set(ALLOCATORS):
        raise ValueError("all four complete allocator comparisons are required")
    baseline = allocators["linear-scan"]
    words = set(baseline["workloads"])
    if len(words) != 26:
        raise ValueError("the complete 26-workload set is required")
    for name, data in allocators.items():
        if set(data["workloads"]) != words:
            raise ValueError(name + ": workload set differs")
        if len(data.get("runtime_by_round", {})) < 2:
            raise ValueError(name + ": two paired rounds are required")
        for metric in METRICS:
            value = data["compile"][metric]["candidate"]
            if not math.isfinite(value) or value <= 0:
                raise ValueError(name + ": invalid compile measurement")
        for word, record in data["workloads"].items():
            for metric in METRICS:
                if min(record[metric]["samples"]) < 6:
                    raise ValueError(name + "/" + word + ": six timed samples per revision required")
                if not math.isfinite(record[metric]["candidate"]) or record[metric]["candidate"] <= 0:
                    raise ValueError(name + "/" + word + ": nonpositive measurement")
    result = dict(source_commit=source, options=summary["options"]["candidate"],
                  scope_words=summary["scope_words"]["candidate"],
                  reference_allocator="linear-scan", workloads=26, allocators={})
    for name in ALLOCATORS:
        data = allocators[name]
        report = dict(runtime={}, compile={}, workloads={})
        for word in sorted(words):
            report["workloads"][word] = {
                metric: data["workloads"][word][metric]["candidate"] /
                baseline["workloads"][word][metric]["candidate"] for metric in METRICS}
        for metric in METRICS:
            report["runtime"][metric] = math.exp(statistics.mean(
                math.log(v[metric]) for v in report["workloads"].values()))
            report["compile"][metric] = data["compile"][metric]["candidate"] / baseline["compile"][metric]["candidate"]
        result["allocators"][name] = report
    return result


def markdown(result):
    lines = ["# Final source, allocator / linear-scan ratios", "",
             "Source: `" + result["source_commit"] + "`. All allocators use the same "
             + str(result["scope_words"]) + "-word frozen closure and flags: `"
             + json.dumps(result["options"], sort_keys=True) + "`.", "",
             "Each runtime ratio equally weights 26 workload medians, with at least six "
             "samples per workload. Ratios below 1 mean less measured time/work. "
             "This table does not establish statistical significance on a shared host; "
             "inspect the paired per-round and per-workload records as well.", "",
             "| Allocator | Runtime CPU | Runtime retired | Compile CPU | Compile retired |",
             "|---|---:|---:|---:|---:|"]
    for name, data in result["allocators"].items():
        values = [data[k][m] for k, m in (("runtime", "cpu_seconds"), ("runtime", "instructions"),
                                        ("compile", "cpu_seconds"), ("compile", "instructions"))]
        lines.append("| " + name + " | " + " | ".join(f"{v:.4f}" for v in values) + " |")
    return "\n".join(lines) + "\n"


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("paired_summary", type=Path)
    parser.add_argument("--output", type=Path, required=True, help="output filename without extension")
    args = parser.parse_args()
    result = rank(json.loads(args.paired_summary.read_text()))
    args.output.with_suffix(".json").write_text(json.dumps(result, indent=2) + "\n")
    args.output.with_suffix(".md").write_text(markdown(result))
