# Completed allocator tuning matrix: native-x86-64

Compiler baseline `7b6cd9519a71960a4fb0385bf6ceeaf66097d618`; candidate `5c848c90f63cea092191b70e1678bec4441e0238`.

Six measured runtime batches per workload, revision and allocator come from two fresh processes (three batches each), with reversed source order in round two. Compilation has two observations per revision and allocator. All 26 independent workload answers match. Strict collection accepted 16 timing processes, eight checked closures, 1,248 measured batches and 208 checked outputs. Rematerialization and loop spilling are on; GVN and timing-time verification are off. Separate strict callback and moving-GC gates passed for both revisions.

Frozen closure sizes: baseline 28,484; candidate 28,489. Each selected allocator recompiles the complete saved word-object sequence within its revision, including newly introduced compiler helpers. Matching initial image and VM provenance is retained in `../../gates/` and the experiment's asset records.

All ratios below are candidate/reference; lower is better. Runtime aggregates equally weight the 26 workload ratios using a geometric mean. Compile ratios use the median whole-closure observation.

## Each allocator versus its own pre-tuning baseline

| Allocator | Runtime CPU | Runtime retired | Compile CPU | Compile retired |
|---|---:|---:|---:|---:|
| linear-scan | 1.0027 | 1.0000 | 0.9864 | 0.9931 |
| greedy | 0.9755 | 0.9879 | 0.9995 | 1.0105 |
| backtracking | 1.0038 | 0.9972 | 0.8381 | 0.7856 |
| chordal | 0.9797 | 0.9952 | 0.9868 | 1.0014 |

## Final allocators versus final linear scan

| Allocator | Runtime CPU | Runtime retired | Compile CPU | Compile retired |
|---|---:|---:|---:|---:|
| linear-scan | 1.0000 | 1.0000 | 1.0000 | 1.0000 |
| greedy | 1.0072 | 1.0018 | 1.0493 | 1.0479 |
| backtracking | 1.0275 | 1.0197 | 1.0026 | 1.0074 |
| chordal | 1.0298 | 1.0710 | 1.2919 | 1.3262 |

## Repaired pressure cases in the full matrix

| Allocator / workload | Runtime CPU / own baseline | Retired / own baseline | Code bytes before → after |
|---|---:|---:|---:|
| greedy / integer-pressure | 0.8303 | 0.8638 | 864 → 688 |
| backtracking / ffi-pressure | 0.9916 | 0.9671 | 2000 → 2000 |
| chordal / branch-pressure | 0.7909 | 0.9441 | 2256 → 2048 |

## Largest remaining own-baseline deltas

The table includes the two highest CPU ratios and two highest retired-instruction ratios for each alternative allocator (deduplicated). Per-round CPU ratios distinguish repeatable changes from isolated execution-rate differences. These are individual workloads; the full 26-workload records remain in `summary.json`.

| Allocator / workload | CPU / own baseline | Retired / own baseline | CPU round 1 / round 2 |
|---|---:|---:|---:|
| greedy / base64-work | 1.0127 | 1.0000 | 1.0298 / 0.9949 |
| greedy / gc-pressure-work | 1.0032 | 1.0008 | 1.0055 / 1.0017 |
| greedy / tuple-arrays-benchmark | 1.0140 | 1.0006 | 1.0160 / 1.0140 |
| backtracking / base64-work | 1.1951 | 1.0000 | 1.0013 / 1.3916 |
| backtracking / sha1-work | 0.9673 | 1.0027 | 0.9689 / 0.9683 |
| backtracking / simd-pressure-work | 1.1042 | 1.0073 | 1.2026 / 1.0037 |
| chordal / base32-work | 0.9799 | 1.0155 | 0.9659 / 1.0016 |
| chordal / gc-pressure-work | 1.0741 | 1.0008 | 1.0066 / 1.1345 |
| chordal / sha1-work | 1.0297 | 1.0158 | 1.0230 / 1.0346 |

## Execution-rate limits and retained evidence

The host's one-minute load ranged from 0.65 to 1.38 (median 0.99). `diagnostics.md` records per-process CPU/wall ratios and retired instructions per CPU second; `diagnostics.json` also retains final allocator/linear-scan ratios separately for each round. Small CPU-only differences require that execution-rate context. Six batches from two processes do not provide six independent process replications.

Final machine-IR spill/reload/copy counts are static opcode counts, not emitted movement instructions or dynamic events. Equal-register copies can emit no instruction. Generated code bytes are actual machine-code bytes; retired counts measure actual execution. Targeted emitted-store provenance and disassembly are retained separately for the greedy repair.

Raw JSONL data is gzip-compressed with exact status records. `collection.json` records source identities, roots and every accepted command; source manifests cover the compiler, architecture, alien core and VM trees. `summary.json` contains every workload and code metric, own-baseline ratios and both rounds. `final-rank.json` ranks the final source against its own linear scan. These measurements do not change default policy or establish the separate cold-bootstrap budget.
