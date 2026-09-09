# Completed allocator tuning matrix: native-arm64

Compiler baseline `7b6cd9519a71960a4fb0385bf6ceeaf66097d618`; candidate `5c848c90f63cea092191b70e1678bec4441e0238`.

**ARM CPU rankings are confounded in this run.** The linear-scan control has runtime CPU ratio 1.1002 despite retired-instruction ratio 1.0001. All three alternatives reverse their own-baseline CPU direction between rounds. Pooled six-sample medians can also differ materially from the paired-round comparisons: backtracking/final-LS CPU is 0.9464 when pooled, versus 0.9881 and 0.9896 by round. The apparent pooled CPU advantages do not establish an attributable allocator speedup or support changing the default. Retired counts, generated code and per-round records remain useful evidence.

Six measured runtime batches per workload, revision and allocator come from two fresh processes (three batches each), with reversed source order in round two. Compilation has two observations per revision and allocator. All 26 independent workload answers match. Strict collection accepted 16 timing processes, eight checked closures, 1,248 measured batches and 208 checked outputs. Rematerialization and loop spilling are on; GVN and timing-time verification are off. Separate strict callback and moving-GC gates passed for both revisions.

Frozen closure sizes: baseline 27,351; candidate 27,356. Each selected allocator recompiles the complete saved word-object sequence within its revision, including newly introduced compiler helpers. Matching initial image and VM provenance is retained in `../../gates/` and the experiment's asset records.

All ratios below are candidate/reference; lower is better. Runtime aggregates equally weight the 26 workload ratios using a geometric mean. Compile ratios use the median whole-closure observation.

## Each allocator versus its own pre-tuning baseline

| Allocator | Runtime CPU | Runtime retired | Compile CPU | Compile retired |
|---|---:|---:|---:|---:|
| linear-scan | 1.1002 | 1.0001 | 1.0071 | 1.0005 |
| greedy | 1.0260 | 0.9897 | 0.9915 | 1.0034 |
| backtracking | 0.9617 | 0.9949 | 0.7849 | 0.7599 |
| chordal | 0.9568 | 0.9911 | 0.9984 | 1.0037 |

## Final allocators versus final linear scan

| Allocator | Runtime CPU | Runtime retired | Compile CPU | Compile retired |
|---|---:|---:|---:|---:|
| linear-scan | 1.0000 | 1.0000 | 1.0000 | 1.0000 |
| greedy | 0.9669 | 1.0001 | 1.0317 | 1.0450 |
| backtracking | 0.9464 | 1.0238 | 1.0373 | 1.0002 |
| chordal | 0.9732 | 1.0770 | 1.3285 | 1.3398 |

## Repaired pressure cases in the full matrix

| Allocator / workload | Runtime CPU / own baseline | Retired / own baseline | Code bytes before → after |
|---|---:|---:|---:|
| greedy / integer-pressure | 0.7731 | 0.8802 | 672 → 576 |
| backtracking / ffi-pressure | 0.9632 | 0.9536 | 1392 → 1344 |
| chordal / branch-pressure | 0.7749 | 0.9117 | 1472 → 1376 |

## Largest remaining own-baseline deltas

The table includes the two highest CPU ratios and two highest retired-instruction ratios for each alternative allocator (deduplicated). Per-round CPU ratios distinguish repeatable changes from isolated execution-rate differences. These are individual workloads; the full 26-workload records remain in `summary.json`.

| Allocator / workload | CPU / own baseline | Retired / own baseline | CPU round 1 / round 2 |
|---|---:|---:|---:|
| greedy / gc-pressure-work | 1.1097 | 1.0017 | 1.2793 / 0.9969 |
| greedy / pi-work | 1.0786 | 1.0011 | 1.1595 / 1.0034 |
| backtracking / norm-work | 0.9939 | 0.9999 | 0.9806 / 0.9724 |
| backtracking / sieve-work | 0.9895 | 1.0000 | 1.0428 / 0.9691 |
| backtracking / trees-work | 0.9939 | 0.9999 | 1.0565 / 0.9489 |
| backtracking / lcs-benchmark | 0.9891 | 1.0000 | 1.0351 / 0.9510 |
| chordal / base64-work | 0.9904 | 1.0001 | 0.8925 / 1.0668 |
| chordal / gc-pressure-work | 1.0006 | 1.0002 | 0.9685 / 1.0410 |
| chordal / md5-work | 1.0083 | 0.9991 | 0.9099 / 1.0529 |

## Execution-rate limits and retained evidence

The host's one-minute load ranged from 37.03 to 92.92 (median 58.76). `diagnostics.md` records per-process CPU/wall ratios and retired instructions per CPU second; `diagnostics.json` also retains final allocator/linear-scan ratios separately for each round. Small CPU-only differences require that execution-rate context. Six batches from two processes do not provide six independent process replications.

Final machine-IR spill/reload/copy counts are static opcode counts, not emitted movement instructions or dynamic events. Equal-register copies can emit no instruction. Generated code bytes are actual machine-code bytes; retired counts measure actual execution. Targeted emitted-store provenance and disassembly are retained separately for the greedy repair.

Raw JSONL data is gzip-compressed with exact status records. `collection.json` records source identities, roots and every accepted command; source manifests cover the compiler, architecture, alien core and VM trees. `summary.json` contains every workload and code metric, own-baseline ratios and both rounds. `final-rank.json` ranks the final source against its own linear scan. These measurements do not change default policy or establish the separate cold-bootstrap budget.
