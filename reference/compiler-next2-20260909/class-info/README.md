# Native isolated class-info constructor comparison

Candidate **04fa5fdbbaafef4ed47445d11679f46f1e177040** changes only the class-info implementation and its tests relative to logical baseline **1d67bdd034**. The executed baseline marker is **a7f554b613bd763fb7fbfc520643b75b321a6e16**, whose compiler/core/extra/VM trees are identical to 1d67. Residency and recolor changes are excluded from this candidate.

The candidate reloads the changed propagation-info vocabulary from the unchanged baseline prepared image, rebuilds the selected closure and saves a separate image. The explicit info and class-algebra unit files pass. Fresh baseline and candidate strict linear-scan checked closures both pass all 26 outputs. Their **28,500 actual word objects** match exactly, including `<class-info>`. All 12 complete static reports match after excluding pass timing fields, including code sizes and allocator statistics. This is static-report equivalence, not a raw emitted-byte comparison.

Four native compile-only processes ran B1 C1 C2 B2, pinned to CPU 2 at nice 0 with the identical capability-bearing VM. Rematerialization, loop policy, GVN and compiler checks were OFF in timing processes. Exact commands, source/image hashes, load snapshots, scripts and raw observations are retained.

| Candidate / baseline | Retired instructions | CPU seconds |
|---|---:|---:|
| Pair 1 | 0.988741777 | 0.988944792 |
| Pair 2 | 0.988741151 | 0.993218366 |
| Mean observations | **0.988741464** | **0.991070770** |

The selected compiler closure uses **1.12585% fewer retired instructions** and **0.89292% less CPU time**. Both orderings improve, with especially consistent retired work. There are two compiler observations per revision. No runtime timing or runtime speedup claim is included.

The first unit-log parser attempt is retained under `rejected-unit-log-parser/`: the driver mistook a printed Factor test literal for JSON and stopped before any compiler timing. The corrected driver treats unit output as text, checks its exit status, then performs the strict closure and paired measurements. No measured result was discarded.

The native queue exited after the final baseline observation. The user requested a stopping point, and no recolor preparation, gate or timing followed.
