# Final ARM backtracking audit

Final source `a7f554b613`; original baseline `c1f7e4d34c`; pre-fix combined candidate `eccfc0accc`. Final production is byte-identical to `c6948a99de`; the later freeze changes one test fixture and evidence. This is a **targeted backtracking timing matrix**, not an all-four timing matrix.

## Correctness and provenance

All four loaded compiler-vocabulary suites pass. This means the harness’s loaded-child vocabulary scope, not every compiler test vocabulary on the filesystem. The linear-scan pass is reused from c694 with production equality verified; greedy, backtracking and chordal pass on the final freeze. The corrected backtracking fixture is explicitly tested with rematerialization both on and off. The failed c694 greedy attempt remains under `failed-attempt-c6948a99de`, clearly excluded from accepted results.

Final backtracking and chordal checked closures pass with SSA, interval and final original-value verification. Every one of 26 runtime outputs and iteration counts agrees across checked and timed runs. All 12 ordered code reports are retained and stable across timing rounds after removing timing fields. The counter audit rejects nonpositive CPU, wall-time or retired-instruction observations. Callback and moving-GC gates pass on the final source, followed by default bootstrap and image verification.

- baseline: 1587 expanded core/VM/compiler hashes match; prepared-image hash matches preparation status; 27,356 words selected.
- candidate: 1589 expanded core/VM/compiler hashes match; prepared-image hash matches preparation status; 27,367 words selected.

Exact ordered scope lists match within each source. The final dependency closure adds 13 words and removes two old phase wrappers, for a net increase of 11. Source inspection establishes the replacement: backtracking calls `assign-phase-ssa-registers-recording`, whose traversal calls `assign-phase-ssa-block-recording` directly. The old wrapper APIs remain in source but leave the dependency closure. All 26 benchmark entrypoints and the new recording/profitability helpers are selected. The full difference and source diff are archived; this report does not claim an identical compiler helper scope.

## Reversed-pair measurements

Four fresh timing processes ran baseline → candidate → candidate → baseline. Each has three measured samples after one warmup per workload; rematerialization and loop placement are on, GVN and timed checkers off. Ratios below are candidate / original baseline. Runtime figures are geometric means over 26 ratios of within-process sample medians; the final column combines the two reversed-round ratios geometrically.

| Measurement | B→C round | C→B round | Paired ratio |
|---|---:|---:|---:|
| compile instructions | 0.998620 | 0.999017 | 0.998818 |
| compile cpu_seconds | 1.102430 | 1.081148 | 1.091737 |
| compile ns | 1.148281 | 1.148820 | 1.148551 |
| runtime instructions | 0.999395 | 0.999161 | 0.999278 |
| runtime cpu_seconds | 0.995338 | 1.117890 | 1.054836 |
| runtime ns | 0.978076 | 1.121798 | 1.047475 |

Final runtime retired-instruction change is -0.072%; compile retired-instruction change is -0.118%. Per-round CPU and wall-time results are retained because ARM hardware execution rate varies substantially. Measured compile CPU increases 9.17% and runtime CPU increases 5.48%; this run establishes no ARM CPU speedup. The mismatch between CPU and retired-instruction changes limits source-level attribution in either direction.

## FFI, branch and integer pressure

| Workload | Pre-fix retired vs its baseline | Final retired B→C | Final retired C→B | Final paired retired | Final paired CPU |
|---|---:|---:|---:|---:|---:|
| ffi | -1.556% | -1.268% | -1.302% | -1.285% | +0.462% |
| branch | +0.439% | +0.005% | -0.081% | -0.038% | +8.614% |
| integer | +0.057% | -1.122% | -1.169% | -1.145% | +5.969% |

The pre-fix and final columns are each normalized to their own contemporary c1 baseline. They come from separate run windows and are not an isolated paired final-versus-pre-fix CPU comparison.

| Workload / static metric | Original c1 | Pre-fix ecc | Final a7 |
|---|---:|---:|---:|
| ffi code_bytes | 1344 | 1312 | 1312 |
| ffi spills | 60 | 56 | 56 |
| ffi reloads | 57 | 55 | 55 |
| ffi copies | 20 | 20 | 20 |
| ffi blocks | 8 | 6 | 6 |
| branch code_bytes | 1264 | 1280 | 1264 |
| branch spills | 31 | 31 | 31 |
| branch reloads | 31 | 32 | 31 |
| branch copies | 0 | 0 | 0 |
| branch blocks | 8 | 10 | 8 |
| integer code_bytes | 576 | 576 | 576 |
| integer spills | 25 | 25 | 25 |
| integer reloads | 25 | 25 | 25 |
| integer copies | 0 | 0 | 0 |
| integer blocks | 3 | 3 | 3 |

Largest remaining retired-instruction increases (both rounds shown):

| Workload | B→C | C→B | Paired |
|---|---:|---:|---:|
| allocator-runtime-comparison:simd-pressure-work | +0.342% | +0.304% | +0.323% |
| benchmark.csv:csv-benchmark | +0.191% | +0.174% | +0.182% |
| allocator-runtime-comparison:json-work | +0.034% | +0.080% | +0.057% |

SIMD’s main-kernel code size and spill/reload counts are unchanged (1136 bytes, 11 spills, 11 reloads); its measured workload increase remains a reported regression rather than being attributed to an unproven mechanism. Integer’s main-kernel static output also remains unchanged despite the workload instruction reduction. These measurements include the selected workload dependencies, not just the separately reported kernel.

The final profitability decision uses actual post-assignment predecessor locations. It retains one successor reload when every incoming value already has the same memory home, and delegates mixed locations to parallel edge transport. This targets the pre-fix branch duplication while preserving the FFI store/reload reduction. Raw allocation counters, including delegated entry reloads, remain in the JSONL and `comparison.json`.

## Bootstrap context

- baseline: 190.485 s wall; 188.967 s sampled CPU; 1,801,823,263,167 sampled retired instructions; 9.535 billion instructions per CPU-second.
- candidate: 203.912 s wall; 202.502 s sampled CPU; 1,805,150,233,055 sampled retired instructions; 8.914 billion instructions per CPU-second.
- historical-1m52: 115.995 s wall; 113.935 s sampled CPU; 1,800,212,929,873 sampled retired instructions; 15.800 billion instructions per CPU-second.

Final whole-process bootstrap is 203.912 seconds (core reports 3:19), so the requested two-minute goal is unmet. Retired instructions change +0.185% against contemporary c1 and +0.274% against the accepted historical 1:52-core run. The root image and original integration factor.image hashes still equal the recorded pre-run hash; the final image is saved separately.

The baseline bootstrap is the previously recorded contemporary c1 run, not an interleaved final bootstrap pair. PID snapshots may precede process exit. Differences in execution rate must be considered before attributing the wall-time change to compiler improvements.

## Archive and reproduction

`collect.py` performs read-only source/image/scope/output/counter checks and copies only completed records into this directory. `report.py` generates this report and the focused comparison JSON. `phase-dependency-change.diff` explains the selected helper replacement. `queue-driver.py` is an archived parent-owned driver, not an active workload. No compiler, VM, integration source, or benchmark driver was modified by collection, and no Factor/CPU workload was launched by the auditor.
