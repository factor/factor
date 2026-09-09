# Independent GVN and rematerialization interaction audit

Reviewed base `ad0fc337de` on 2026-09-09. This change adds tests and evidence only. No optimizer or allocator production source or defaults were changed.

## Activation and scope

`optimize-ssa` invokes `value-numbering`. Local numbering always runs. The false-by-default `global-value-numbering?` flag additionally invokes global scalar congruence numbering, followed by copy propagation and another local numbering pass only when global elimination changed the graph. Thus GVN OFF is not an optimizer-free baseline.

The global pass numbers a fixed SSA instruction stream to a fixed point, uses predecessor-associated phi keys and must-availability to select dominating representatives, and replaces redundant operations/phis with copies. Its explicit opcode whitelist excludes floating-point operations and mutable loads. Literal values participate in congruence, but their loads are retained locally. It does not perform PRE, memory GVN, or synthesize new phis. Availability treats kill blocks as barriers.

## Focused execution

The accepted `check-output.log` gate exited 0. Existing global-numbering tests passed, including dominated reuse, sibling/join availability, edge-associated phis, loop convergence, kill barriers, and excluded FP/memory operations. The new production-selector witness has two cross-block XOR instructions with GVN OFF and one with GVN ON.

Fresh compiled inline branch/loop wrappers produced 1,312 independently calculated native answers: 41 integer inputs, two branch choices or six loop counts, under all four GVN/rematerialization settings. Linear scan was selected and SSA, interval-allocation, and final symbolic value-flow checks were enabled. The runtime oracle does not derive expected values from optimized IR. The untimed observer counted 17 global-pass invocations, 11 reporting a changed graph across the complete gate. Earlier harness attempts stopped on test-only import/parser/range errors; only the corrected accepted run is retained as passing evidence.

## Ordinary benchmark activity

The accepted `activity-output.log` gate also exited 0. It constructs each target's CFG through `measure-compilation` and the production optimization/finalization pipeline, with the same four settings and checks. It does not install or execute those benchmark code objects; the independent runtime matrix owns that validation and timing. Its observer records only immediate global-pass replacements and invocation counts.

| Target | GVN OFF calls | GVN ON calls | Replacements with GVN ON |
| --- | ---: | ---: | ---: |
| branch-pressure | 0 | 1 | 0 |
| integer-pressure | 0 | 1 | 0 |
| spectral-norm | 0 | 1 | 16 |
| explicit typed spectral-norm body | 0 | 1 | 16 |
| nbody root | 0 | 1 | 0 |
| struct-arrays-bench | 0 | 1 | 2 |

Each row holds with rematerialization both OFF and ON. Replacements are the increase in `##copy` instructions immediately around global numbering and include eliminated phis. They establish that the flag is active and non-inert on ordinary source. They do not establish fewer final instructions or lower runtime: subsequent simplification can yield identical final code. Root-only probes do not measure elimination in an entire compilation closure.

## Soundness boundaries

No new ordinary-pipeline soundness failure was found. The final allocator verifier snapshots after GVN, so it proves transport of the optimized values, not equivalence of GVN to the original program. Independent native outputs are required for this interaction.

The earlier `reference/gvn-moving-gc-review-20260908/README.md` remains a relevant qualified limitation: injecting an explicit moving GC between derived-pointer arithmetic operations can invalidate the global congruence assumption; one-block LVN has an analogous limitation. Normal CFG optimization precedes GC-check insertion, and that archive did not establish reachability from an ordinary high-level source program. This audit did not reproduce it as a new source regression or weaken any checker to accept it.

## Reproduction and provenance

`check.factor` is a portable resource-path gate for a source tree containing these tests. Invoke a matching VM/image with `-resource-path=THAT_TREE -no-user-init .../check.factor`; it refreshes source and runs test files explicitly. `activity.factor` additionally requires the benchmark workload vocabulary already loaded in the common prepared matrix image. Both scripts install an observer only inside their isolated process and are not timing harnesses.

The `*-executed.factor` files preserve the exact executed scripts; the portable versions change only test paths. Environment records identify the matching VM, image, source root and invocation. `source-hashes.json` pins the reviewed global/local pass and test source. The observer adds overhead, so none of these process durations or counters are used as performance estimates.
