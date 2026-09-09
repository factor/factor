# Completed native ARM64 matrix

Backtracking has the lowest recorded aggregate runtime CPU on this ARM run: 0.8031 times final linear scan. Greedy is 1.0037 and chordal 1.2168. This timing advantage cannot be confidently attributed to allocator quality on the heavily loaded host. Retired instruction ratios are respectively 1.0269, 1.0089, and 1.0956: every alternative performs more retired work than linear scan.

Each final allocator compared with its own corrected prototype has the following ratios. Values below 1 mean less recorded time/work; the execution-rate limitations below apply to every CPU ratio.

| Allocator | Runtime CPU | Runtime retired | Compile CPU | Compile retired |
|---|---:|---:|---:|---:|
| linear-scan | 1.0204 | 1.0030 | 1.2367 | 1.0729 |
| greedy | 1.1158 | 1.0116 | 1.1398 | 1.1087 |
| backtracking | 1.1365 | 1.0312 | 1.0914 | 1.4027 |
| chordal | 1.3899 | 1.0551 | 1.5273 | 1.4775 |

- [Final allocator comparison](final-rank.md): all four final implementations, identical 27,296-word closure.
- [Each allocator versus its corrected prototype](summary.md): baseline `f5a6d4739eb6aa5203df67719ad8cfba1410484c`, final `30a50ab0df1147eb5c7d852b5d6aad2c0835464e`. Baseline has 26,212 frozen words; final adds compiler helpers. Compilation comparisons include the complete changed closure.
- [Linear-scan rematerialization attribution](remat-attribution.md): same final source/scope, ON/OFF runtime CPU ratio 1.0348 and retired ratio 1.000506. CPU direction reverses between rounds (1.1510 and 0.9541); this does not establish a broad runtime benefit or penalty.
- [Execution-rate and static-code diagnostics](diagnostics.md), with per-round final rankings in [diagnostics.json](diagnostics.json).
- [Collection provenance](collection.json): exact source, flags, commands, host loads, and every accepted status.
- [Baseline acceptance](../strict-baseline-checked/checked-validation.md) and [final acceptance](../final-candidate-checked/checked-validation.md), plus their guarded callback records and initial/prepared image hashes.

This is native Apple M5 Max ARM64 on macOS, using the matching ARM VM and common original image seed recorded in the acceptance directories. The existing external background-task policy and Mach thread-priority counter guards remain active. The unrelated root Factor listener was sleeping at 0% CPU with unchanged CPU time across two snapshots; it was left untouched and recorded in [matrix-host-before.json](matrix-host-before.json).

The one-minute host load during timings ranged from 29.45 to 64.12 (median 44.87). Independent host activity materially changed execution rate. The identical baseline chordal compiler retired 14.86 and 7.93 billion instructions per CPU second in its two processes. Candidate backtracking's rate changed from 18.91 to 12.46. Its final-versus-linear-scan runtime CPU ratios were 0.7002 and 0.8449, while retired ratios stayed near 1.0270. Greedy's CPU ratios reversed from 1.0630 to 0.9261. CPU time avoids scheduler waiting but still depends on execution rate; these observations prevent a clean speedup attribution. All runs are retained, with no timing exclusions or replacement runs.

The experiment has 16 main timing processes and two separate attribution processes, two rounds with three timed runtime samples each, all 26 workloads, and 1,404 measured batches. Full-closure compilation is measured once per process, giving two observations per source/allocator; reports use their median. Eight checked processes add 208 checked outputs and are excluded from timings, as are warmups. The guarded C ABI gate separately passed 40 assertions per revision. All outputs agree, with independent original-workload checks and asserted pressure answers.

Both revisions use rematerialization ON, backtracking loop spills ON, and GVN OFF. Attribution changes only final linear scan's rematerialization flag. The exact ordered frozen word objects match within each revision across every allocator, round, and attribution process; all compiler helpers are installed under the selected allocator before runtime measurement.

Across twelve static kernels, final backtracking reduces spill-slot bytes from linear scan's 2,688 to 1,568 but increases generated code from 37,968 to 38,640 bytes. Greedy produces 38,192 bytes and chordal 40,192. Spill/reload/copy counts are final machine-IR opcode counts, not dynamic events or emitted machine instruction counts; equal-register copies may emit nothing. Generated code bytes measure actual output size. Per-kernel detail is in the linked reports.

The separate completed [native x86 matrix](../../native-x86-64/final-matrix/README.md) consistently favors linear scan. These two architecture results do not justify changing the default from linear scan with rematerialization and GVN disabled. Cold-bootstrap budget assessment is a separate parent-owned experiment with separately recorded VM/seed provenance.
