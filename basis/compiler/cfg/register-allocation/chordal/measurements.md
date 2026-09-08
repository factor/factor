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
