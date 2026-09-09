# Completed native x86-64 matrix

Linear scan has the lowest measured broad runtime and compilation costs. Relative to final linear scan, greedy uses 2.47% more runtime CPU, backtracking 1.46% more, and chordal 5.30% more. All three are slower in each separate round as well. These results do not establish statistical significance or predict ARM results.

- [Final allocator comparison](final-rank.md): all four final implementations, identical 28,375-word closure.
- [Each allocator versus its corrected prototype](summary.md): baseline `f5a6d4739eb6aa5203df67719ad8cfba1410484c`, final `30a50ab0df1147eb5c7d852b5d6aad2c0835464e`. Baseline closure has 27,289 words; final adds compiler helpers. Compilation comparisons include that complete changed closure.
- [Linear-scan rematerialization attribution](remat-attribution.md): same final source and scope, OFF versus ON. Aggregate CPU ratio ON/OFF is 0.9905, but rounds disagree (0.9796 and 1.0021) and retired ratio is 0.999988. This does not support a reliable broad runtime gain from enabling rematerialization.
- [Execution-rate and static-code diagnostics](diagnostics.md), with per-round final rankings in [diagnostics.json](diagnostics.json).
- [Collection provenance](collection.json): exact source, options, commands, per-process host loads, and all accepted run statuses.
- [Baseline acceptance](../strict-baseline-checked/checked-validation.md) and [final acceptance](../final-candidate-checked/checked-validation.md), plus the guarded callback artifacts in those directories.

This is native Linux on `agent1` (AMD Ryzen 9 7950X3D), pinned to CPU 2, with retired instructions measured by the existing perf counter helper. It is not Rosetta. The one-minute host load during timings ranged from 0.28 to 2.00. Both revisions use the same VM and original image seed; prepared image and VM hashes are retained in the acceptance directories.

The complete experiment contains 16 main timing processes and two separate attribution processes, two rounds with three timed samples each, all 26 workloads, and 1,404 measured batches. Warmups and eight checked processes (208 checked outputs) are excluded from timing aggregates. The guarded C ABI gate separately passed 40 assertions per revision. All captured outputs agree, with independent original-workload checks and asserted pressure-workload answers.

Both revisions run with rematerialization ON, backtracking loop spills ON, and GVN OFF. The attribution runs change only final linear scan's rematerialization flag. Frozen ordered word objects match within each revision across every allocator, round, and attribution run. All compiler helpers in each frozen closure are installed under the selected allocator before runtime measurement.

The twelve static kernel reports show actual allocation differences. Compared with final linear scan, full backtracking reduces total code bytes from 42,976 to 42,432 and spill-slot bytes from 3,480 to 1,776, while increasing static spill/reload/copy counts. Full chordal has 45,424 code bytes and 358 copies versus linear scan's 20 copies. Static totals describe these twelve kernels; runtime rankings equally weight all 26 workloads and include their transitive implementations.

The default remains linear scan with rematerialization and GVN disabled. This matrix is not the separate cold-bootstrap budget test.
