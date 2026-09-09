# Native isolated residency fast path

Candidate **7de9c40c98053832965bf4bd36a56b7c415e0f56** contains only the residency implementation/test change 08565badc6 relative to logical baseline 1d67bdd034. The retained baseline's executed marker is **a7f554b613bd763fb7fbfc520643b75b321a6e16**; its basis/core/extra/VM trees are identical to 1d67. No class-info or recolor experiment is included.

The candidate explicitly reloads the changed residency vocabulary into a fresh process from the unchanged a7 prepared image, rebuilds the reachable closure, and saves a separate prepared image. Both revisions then compile the exact same **28,500 actual word objects**, including `pressure-victims`, under chordal with rematerialization ON, loop policy ON and GVN OFF. Their native VM bytes and capability-bearing executable match. Commands, image/source hashes, affinity CPU 2, nice 0, capability and host-load snapshots are retained.

The explicit residency unit file and full strict checked 26-workload closure pass. All 12 complete static reports match the retained baseline report after excluding pass timing fields, including code sizes, spill/reload/copy counts and allocator statistics. This is static-report equivalence, not a claim that this run compared every emitted byte. The reused baseline checked record is from the previously accepted a7 gate; its original prepared-image hash 9fb6dd169665b96c9c213f918ddf498c375af73da0646c7d5f35cc0291ae079a matches the baseline image used here.

Four pristine compile-only processes ran B1 C1 C2 B2, with checks OFF and no runtime samples:

| Candidate / baseline | Retired instructions | CPU seconds |
|---|---:|---:|
| Pair 1 | 0.960946 | 0.966293 |
| Pair 2 | 0.960855 | 0.968621 |
| Mean observations | **0.960900** | **0.967457** |

The whole selected compiler closure uses **3.910% fewer retired instructions** and **3.254% less CPU time** under chordal. Both orderings agree. These are two compiler observations per revision, and no runtime speedup is claimed. `summary.json`, `runs/static-equivalence.json`, all raw/status files and exact scripts retain the complete comparison.
