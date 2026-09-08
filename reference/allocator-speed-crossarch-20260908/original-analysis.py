#!/usr/bin/env python3
"""Validate complete allocator benchmark JSONL logs and summarize runtime ratios.

Usage: python3 analysis.py [directory-or-jsonl ...] [--json report.json]
                         [--markdown report.md]
Only unchecked trials 0..4 contribute to timing. Checked runs and warmups still
participate in correctness checks. Fail closed on missing or inconsistent data.
"""
from __future__ import annotations

import argparse
import collections
import decimal
import hashlib
import gzip
import json
import math
from pathlib import Path
import re
import statistics
import sys

ALLOCATORS = ("linear-scan", "greedy", "backtracking", "chordal")
WORKLOADS = {
    "norm-work", "nbody-work", "nbody-simd-work", "trees-work",
    "fannkuch-work", "sieve-work", "pi-work", "md5-work", "sha1-work",
    "base64-work", "base32-work", "csv-benchmark", "json-work",
    "msgpack-benchmark", "lcs-benchmark", "tuple-arrays-benchmark",
    "struct-work", "matrix-work", "matrix-simd-work", "gc-work",
}
EMPTY_OUTPUT = WORKLOADS - {
    "norm-work", "nbody-work", "nbody-simd-work", "trees-work",
    "fannkuch-work", "pi-work", "md5-work", "sha1-work", "struct-work",
    "matrix-work", "matrix-simd-work",
}
METRICS = ("ns", "cpu_seconds", "instructions")


def require(condition, message):
    if not condition:
        raise ValueError(message)


def pi_digits(count=1000):
    """Independent Machin formula, with guard digits (no third-party packages)."""
    with decimal.localcontext() as ctx:
        ctx.prec = count + 30
        D = decimal.Decimal

        def atan_inverse(n):
            x = D(1) / n
            term, total, k = x, x, 1
            while True:
                term *= -x * x
                updated = total + term / (2 * k + 1)
                if updated == total:
                    return total
                total, k = updated, k + 1

        pi = 16 * atan_inverse(5) - 4 * atan_inverse(239)
        return format(pi, "f").replace(".", "")[:count]


def independently_check(outputs):
    by_name = {word.rsplit(":", 1)[-1]: output for word, output in outputs.items()}
    payload = bytes(range(256)) * (2_000_000 // 256) + bytes(range(2_000_000 % 256))
    for name, algorithm in (("md5-work", "md5"), ("sha1-work", "sha1")):
        expected = hashlib.new(algorithm, payload).hexdigest()
        require(by_name[name].strip().lower() == expected, f"{name}: hashlib mismatch")
    rows = by_name["pi-work"].splitlines()
    chunks = []
    for row in rows:
        match = re.fullmatch(r"([0-9 ]+)\t:(\d+)", row)
        require(match is not None, f"pi-work: malformed row {row!r}")
        chunks.append(match[1].replace(" ", ""))
        require(int(match[2]) == sum(map(len, chunks)), "pi-work: incorrect digit count")
    require("".join(chunks) == pi_digits(), "pi-work: independent 1000-digit pi mismatch")
    require(by_name["fannkuch-work"].rstrip().endswith("Pfannkuchen(8) = 22"),
            "fannkuch-work: incorrect known maximum")
    tree_lines = ["stretch tree of depth 15\t check: -1"]
    for depth in range(4, 15, 2):
        count = 2 ** (14 - depth + 5)
        tree_lines.append(f"{count}\t trees of depth {depth}\t check: {-count}")
    tree_lines.append("long lived tree of depth 14\t check: -1")
    require(by_name["trees-work"].splitlines() == tree_lines,
            "trees-work: independent tree count/check mismatch")
    for name in EMPTY_OUTPUT:
        require(by_name[name] == "", f"{name}: unexpected output from assertion workload")
    norm = float(by_name["norm-work"].strip())
    require(math.isfinite(norm) and 1.27 < norm < 1.28, "norm-work: invalid norm")
    energy = {}
    for name in ("nbody-work", "nbody-simd-work"):
        values = [float(line) for line in by_name[name].splitlines()]
        require(len(values) == 2 and all(map(math.isfinite, values)), f"{name}: invalid energies")
        require(math.isclose(values[0], -0.16907516382852447, abs_tol=1e-12),
                f"{name}: incorrect initial energy")
        energy[name] = values
    require(all(math.isclose(a, b, rel_tol=1e-10, abs_tol=1e-12)
                for a, b in zip(*energy.values())), "scalar/SIMD nbody energy disagreement")
    for name, tolerance in (("matrix-work", 1e-12), ("matrix-simd-work", 2e-7)):
        # Match floating values, excluding the digits in printed class names
        # such as matrix4 and float-4. The SIMD implementation stores float32.
        values = [float(x) for x in re.findall(r"[-+]?\d+\.\d+(?:[eE][-+]?\d+)?", by_name[name])]
        require(len(values) == 16, f"{name}: expected 16 matrix values")
        require(all(math.isclose(value, math.e if index % 5 == 0 else 0.0,
                                 rel_tol=0, abs_tol=tolerance)
                    for index, value in enumerate(values)),
                f"{name}: exp(identity) disagrees with e times identity")
    return ["md5: Python hashlib", "sha1: Python hashlib",
            "pi: all 1000 digits via Decimal Machin formula", "fannkuch: known maximum 22",
            "binary trees: independently derived counts/checks",
            "nbody: known initial energy and scalar/SIMD comparison",
            "matrix exponential: e times identity, precision-specific tolerances",
            "spectral norm: finite expected range", "assertion workloads: no unexpected output"]


def read_run(path):
    records = []
    content = gzip.open(path, "rt").read() if path.suffix == ".gz" else path.read_text()
    for line_number, line in enumerate(content.splitlines(), 1):
        if line.strip():
            try:
                record = json.loads(line)
            except json.JSONDecodeError as exc:
                raise ValueError(f"{path}:{line_number}: invalid JSON: {exc}") from exc
            require(isinstance(record, dict), f"{path}:{line_number}: expected object")
            records.append(record)
    scopes = [r for r in records if r.get("kind") == "scope"]
    require(len(scopes) == 1, f"{path}: expected exactly one scope")
    scope = scopes[0]
    require(scope is records[0], f"{path}: scope must precede all measurements")
    allocator, checked = scope.get("allocator"), scope.get("checked")
    require(allocator in ALLOCATORS and type(checked) is bool, f"{path}: invalid allocator/check mode")
    words = scope.get("words")
    require(isinstance(words, list) and words and all(isinstance(w, str) for w in words),
            f"{path}: missing compilation word scope")
    require(len(words) == len(set(words)), f"{path}: duplicated compilation words")
    compiles = [r for r in records if r.get("kind") == "compile"]
    require(len(compiles) == 1, f"{path}: expected one completed compilation")
    runtime = [r for r in records if r.get("kind") == "runtime"]
    known = {"scope", "compile", "runtime", "validation", "retry"}
    require(all(r.get("kind") in known for r in records), f"{path}: unknown/error record")
    for record in records:
        for field in ("compiler-errors", "compiler_errors", "linkage-errors", "linkage_errors"):
            if field in record:
                require(not record[field], f"{path}: nonempty {field}")
        if record.get("kind") == "validation":
            require(record.get("ok") is True, f"{path}: validation did not succeed")
    seen = set()
    for record in compiles + runtime:
        for metric in METRICS:
            value = record.get(metric)
            require(type(value) in (int, float) and math.isfinite(value) and value > 0,
                    f"{path}: invalid {metric}: {value!r}")
    for record in runtime:
        word, trial, output = record.get("word"), record.get("trial"), record.get("output")
        require(isinstance(word, str) and isinstance(output, str) and type(trial) is int,
                f"{path}: malformed runtime record")
        require((word, trial) not in seen, f"{path}: duplicate sample {word}/{trial}")
        iterations = record.get("iterations", 1)
        require(type(iterations) is int and iterations >= 1,
                f"{path}: invalid batch iterations for {word}: {iterations!r}")
        record["iterations"] = iterations
        seen.add((word, trial))
    runtime_words = {r[0] for r in seen}
    require(len(runtime_words) == len(WORKLOADS) and
            {w.rsplit(":", 1)[-1] for w in runtime_words} == WORKLOADS,
            f"{path}: incomplete or unexpected workload set")
    # The harness freezes actual word objects in a common prepared image.
    # Labels need ordinal suffixes because anonymous methods can share names.
    ordinal_ids = [re.fullmatch(r"(.*)\|(\d+)", w) for w in words]
    if all(ordinal_ids):
        require({int(match[2]) for match in ordinal_ids} == set(range(len(words))),
                f"{path}: invalid frozen-scope ordinals")
        scope_labels = {match[1] for match in ordinal_ids}
    else:
        scope_labels = set(words)
    require(runtime_words <= scope_labels, f"{path}: executed workloads missing from compile scope")
    trials = (-1,) if checked else (-1, 0, 1, 2, 3, 4)
    expected = {(word, trial) for word in runtime_words for trial in trials}
    require(seen == expected, f"{path}: missing/unexpected runtime trials")
    return dict(path=str(path), allocator=allocator, checked=checked, words=sorted(words),
                prepared_image_sha256=scope.get("prepared_image_sha256"),
                compile=compiles[0], runtime=runtime)


def analyze(paths):
    require(paths, "no JSONL inputs found")
    runs = [read_run(path) for path in paths]
    reference_scope = runs[0]["words"]
    for run in runs:
        require(run["words"] == reference_scope, f"{run['path']}: compilation scope differs")
    image_hashes = {run["prepared_image_sha256"] for run in runs}
    require(len(image_hashes) == 1, "prepared-image hashes differ or are absent from some runs")
    run_counts = collections.Counter((r["allocator"], r["checked"]) for r in runs)
    for allocator in ALLOCATORS:
        for checked in (False, True):
            require(run_counts[allocator, checked] > 0,
                    f"missing {'checked' if checked else 'timing'} run: {allocator}")
    for checked in (False, True):
        require(len({run_counts[a, checked] for a in ALLOCATORS}) == 1,
                f"unequal {'checked' if checked else 'timing'} run counts across allocators")
    outputs = {}
    samples = collections.defaultdict(list)
    compile_samples = collections.defaultdict(list)
    batch_iterations = {}
    for run in runs:
        allocator = run["allocator"]
        if not run["checked"]:
            compile_samples[allocator].append(run["compile"])
        for record in run["runtime"]:
            word, output = record["word"], record["output"]
            if word in outputs:
                require(outputs[word] == output,
                        f"{run['path']}: output mismatch for {word}, trial {record['trial']}")
            outputs[word] = output
            if not run["checked"]:
                iterations = record["iterations"]
                require(word not in batch_iterations or batch_iterations[word] == iterations,
                        f"{run['path']}: unequal batch iterations for {word}")
                batch_iterations[word] = iterations
            if not run["checked"] and record["trial"] >= 0:
                normalized = dict(record)
                normalized.update({m: record[m] / record["iterations"] for m in METRICS})
                samples[word, allocator].append(normalized)
    independent = independently_check(outputs)

    def medians(records):
        return {m: statistics.median(r[m] for r in records) for m in METRICS}

    workloads = []
    for word in sorted(outputs):
        baseline = medians(samples[word, "linear-scan"])
        entries = {}
        for allocator in ALLOCATORS:
            values = samples[word, allocator]
            require(values, f"missing timing data: {word}/{allocator}")
            median = medians(values)
            entries[allocator] = {
                "samples": len(values), "median": median,
                "ratio_to_linear_scan": {m: median[m] / baseline[m] for m in METRICS},
                "min": {m: min(r[m] for r in values) for m in METRICS},
                "max": {m: max(r[m] for r in values) for m in METRICS},
            }
        workloads.append({"word": word, "output": outputs[word],
                          "iterations_per_sample": batch_iterations[word], "allocators": entries})
    geomeans = {
        a: {m: math.exp(statistics.mean(math.log(w["allocators"][a]["ratio_to_linear_scan"][m])
                                       for w in workloads)) for m in METRICS}
        for a in ALLOCATORS
    }
    baseline_compile = medians(compile_samples["linear-scan"])
    compiles = {}
    for allocator in ALLOCATORS:
        median = medians(compile_samples[allocator])
        compiles[allocator] = {
            "runs": len(compile_samples[allocator]), "median": median,
            "ratio_to_linear_scan": {m: median[m] / baseline_compile[m] for m in METRICS},
        }
    rounds = collections.defaultdict(dict)
    for run in runs:
        if run["checked"]:
            continue
        match = re.search(r"timing-[a-z-]+-(\d+)\.jsonl(?:\.gz)?$", run["path"])
        if match:
            rounds[int(match[1])][run["allocator"]] = run
    round_ratios = {}
    for number, group in sorted(rounds.items()):
        require(set(group) == set(ALLOCATORS), f"incomplete timing round {number}")
        by_allocator = {}
        for allocator, run in group.items():
            per_word = collections.defaultdict(list)
            for record in run["runtime"]:
                if record["trial"] >= 0:
                    per_word[record["word"]].append({m: record[m] / record["iterations"] for m in METRICS})
            by_allocator[allocator] = {w: medians(rs) for w, rs in per_word.items()}
        base = by_allocator["linear-scan"]
        round_ratios[number] = {
            a: {m: math.exp(statistics.mean(math.log(by_allocator[a][w][m] / base[w][m])
                                           for w in base)) for m in METRICS}
            for a in ALLOCATORS
        }
    return {
        "per_round_runtime_geometric_mean_ratios": round_ratios,
        "valid": True, "files": [str(p) for p in paths],
        "scope_words": len(reference_scope),
        "scope_sha256": hashlib.sha256("\n".join(reference_scope).encode()).hexdigest(),
        "prepared_image_sha256": runs[0]["prepared_image_sha256"],
        "checked_runs_per_allocator": run_counts["linear-scan", True],
        "timing_runs_per_allocator": run_counts["linear-scan", False],
        "independent_checks": independent, "compilation": compiles,
        "runtime_geometric_mean_ratios": geomeans, "workloads": workloads,
        "notes": ["Ratios below 1 favor the alternative; above 1 favor linear scan.",
                  "Runtime metrics are normalized per invocation by each record's iterations (default 1); batch counts must match across all timing runs including warmups.",
                  "Checked runs and warmup trial -1 are excluded from timing statistics.",
                  "Output equality covers checked runs, warmups and every measured trial.",
                  "Geometric means weight workloads equally; min/max are descriptive, not confidence intervals.",
                  "Anonymous word identity relies on the harness's common prepared image and frozen ordinal sequence; retain its artifact hash.",
                  "Successful internal assertions are inferred from completed workload records; external process exit status must also be checked."],
    }


def markdown(report):
    lines = ["# Allocator runtime comparison", "",
             f"Validated {len(report['workloads'])} workloads across all four allocators; "
             f"identical compilation scope of {report['scope_words']:,} words.", "",
             "Ratios are relative to linear scan; lower is better. Checked runs and warmups excluded.", "",
             "| Workload | Baseline CPU ms | Greedy CPU / wall / retired | Backtracking CPU / wall / retired | Chordal CPU / wall / retired |",
             "|---|---:|---:|---:|---:|"]
    for workload in report["workloads"]:
        row = [workload["word"], f"{workload['allocators']['linear-scan']['median']['cpu_seconds'] * 1000:.3f}"]
        for allocator in ALLOCATORS[1:]:
            ratios = workload["allocators"][allocator]["ratio_to_linear_scan"]
            row.append(" / ".join(f"{ratios[m]:.3f}" for m in ("cpu_seconds", "ns", "instructions")))
        lines.append("| " + " | ".join(row) + " |")
    lines.extend(["", "Independent checks: " + "; ".join(report["independent_checks"]) + ".", ""])
    for note in report["notes"]:
        lines.append("- " + note)
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("inputs", nargs="*", default=[str(Path(__file__).parent)])
    parser.add_argument("--json", type=Path)
    parser.add_argument("--markdown", type=Path)
    args = parser.parse_args()
    paths = set()
    for value in args.inputs:
        path = Path(value)
        paths.update(list(path.glob("*.jsonl")) + list(path.glob("*.jsonl.gz")) if path.is_dir() else [path])
    try:
        report = analyze(sorted(paths))
    except (ValueError, OSError, KeyError, TypeError) as exc:
        print(f"VALIDATION FAILED: {exc}", file=sys.stderr)
        return 1
    rendered = json.dumps(report, indent=2, allow_nan=False) + "\n"
    if args.json:
        args.json.write_text(rendered)
    if args.markdown:
        args.markdown.write_text(markdown(report))
    if not args.json and not args.markdown:
        print(rendered, end="")
    else:
        print(f"Validated {len(report['workloads'])} workloads in {len(paths)} files.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
