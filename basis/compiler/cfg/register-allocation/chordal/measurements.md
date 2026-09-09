# Historical color-first prototype measurements

These results precede the decoupled spill-before-color implementation described
in [README.md](README.md). They retain the earlier algorithms, counters, and
validation state for comparison; they do not describe the current production
pipeline or establish its performance.

Native ARM64 measurements, September 8, 2026, using the shared allocator corpus
at `reference/compiler-allocator-20260908/compare.factor`. The corpus contains
13 word bodies producing 19 procedures. These are static totals; noisy wall
times on the contended host are not used to claim an improvement.

| Policy | Code bytes | Spills | Reloads | Copies |
| --- | ---: | ---: | ---: | ---: |
| Default linear scan | 24,384 | 42 | 42 | 17 |
| Initial SSA coloring | 27,408 | 184 | 184 | 348 |
| SSA coloring with phi/copy color preferences | 25,616 | 59 | 59 | 161 |

The final local corpus run explicitly set `check-allocation?` to true. All 19
graphs passed the chordality certificate. All interval assignments used graph
colors directly; repair assignments were zero on these bodies. This does not
mean there were no spills: mandatory call/GC preservation and edge location
changes account for spills outside the register-pressure repair counter.

Color preferences materially reduce phi edge moves and preservation traffic,
but the result still loses to the default allocator. In particular, harmless
copy overlaps remain interference edges, while the default coalescer can merge
equal-valued live ranges. The contender should remain experimental.

A generated 40-value floating-point pressure case produced 6,288 code bytes and
26 spill/reload pairs with either allocator before the affinity change. Its
graph was certified chordal (481 vertices, 2,817 edges); 446 fragment assignments
used graph colors and 61 required interval repair. The persisted pressure test
checks both native results and that spills/repair actually occur.

The initial runtime-only harness produced the expected results for five tree
iterations (`-20`) and five spectral-norm iterations (`1.2742199912349306`). The
root comparison harness owns final repeated performance measurements after all
correctness fixes. Compiler codegen, float, spilling, alien, and large-return
tests, plus the allocator's direct tests, provide correctness checks independent
of the benchmark numbers.

A later matched native ARM64 run uses the explicit worktree resource path and
loads the independent final value-flow verifier. The 13-body corpus still
produces 19 procedures. The graph-only revision is `1cc32e7cb6`.

| Policy | Code bytes | Spills | Reloads | Copies |
| --- | ---: | ---: | ---: | ---: |
| Graph-only chordal | 25,616 | 56 | 56 | 145 |
| Chordal with bounded phi-color improvement | 25,264 | 48 | 48 | 58 |

Both rows passed final symbolic value-flow checks and interval allocation checks;
all 19 graphs were certified chordal. The new graph colors reduce unmatched
static affinities from 271 to 169. No exact-copy aliases survive in this corpus,
so its measured improvement comes from phi-color placement, not the separate
SSA-copy representative optimization. Exact-copy chains and representation
boundaries are tested directly. The historical 153-copy report and earlier
unqualified-resource experiments are not used as this matched baseline.

These are final emitted static counts: 87 fewer copies, eight fewer spill/reload
pairs, and 352 fewer bytes. This changes physical assignment and reduces edge
preservation traffic; it does not implement loop/cold-edge spill-site selection.
No runtime-speed or bootstrap-speed claim follows from these static counters.
The integrated comparison harness owns those measurements. Linear scan remains
the default and global value numbering remains disabled.

The final checker-enabled run passed 389 tests across the chordal subtree and
compiler codegen, float, spilling, alien, ARM64 ABI, and large-return suites.
This includes executed branch joins, phi cycles, full-pressure phi joins,
stack-to-stack edges, and derived-root collection. Graph tests compare heap MCS
and parent-neighbor certification to simple scan/clique oracles on all 64
four-vertex undirected graphs; a second exhaustive test verifies every graph
edge after recoloring, including nonchordal graphs and conflicting affinities.

Reproduction scripts and per-word totals are in
`reference/chordal-placement-20260908/`. Use the matching native VM/image and
explicit `-resource-path` and `-i` arguments. The scripts reload changed
allocator words and assert the final verifier is enabled. A separate attempted
linear-scan baseline currently exposes an `invalid-allocation-gc-root` verifier
failure on `spectral-norm`; its partial counts are not included in the table.
