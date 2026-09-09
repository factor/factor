# Native production audit at 3c3ea3feab

This is correctness and mechanism evidence, not a speed measurement or the final
freeze. A separate native x86 tree starts with the previously verified prototype
0b source, overlaid with the exact committed compiler changes listed and hashed
in `source.json`. Each process uses the original native base `factor.image`,
explicit resource path, compiler source refresh, and the final value-flow checker.
The prepared prototype timing image is not used.

`dispatch-probe.factor` instruments actual concrete method bodies and production
policy entry points in a disposable process. It records one invocation of the
selected backend and its own policy (two register choices for LS). Chordal enters
both source-level pressure rewriting and certified coloring. No alternative enters
the LS policy. This tiny CFG is a dispatch probe, not performance coverage.

`chordal-witness.factor` executes nine four-integer-register diamond CFGs: widths
4, 6, 12 and seeds 0, 1, 2. Their 45 native outputs match separate arithmetic
formulae, with original-SSA/final-machine verification enabled. All nine require
actual stores and fresh reload definitions. The producer exports its full graph,
colors, and conventional perfect-elimination order. `check.py` independently
checks graph symmetry, every interference edge, the order permutation and all
later-neighbor cliques, legal colors, and optimal uniform-bank color count. All
nine pass using four colors, with zero fallback and zero interval repair.

Run `python3 reference/allocator-full-comparison-20260908/native-x86-audit/check.py`
to recheck the retained raw outputs. These results do not certify arbitrary CFGs
or pending derived-pointer-phi GC handling. Rematerialization is OFF here; the
pending ON feature correction requires its own positive recipe/code witness.

## Positive rematerialization activity gate

`remat-probe.factor` adds only `b24a9fde54` to that pinned source (exact file
hashes in `remat-source.json`). Its native rematerialization suite passes,
including executed straight-line, diamond, loop and GC pressure cases for
each allocator with the option OFF and ON. Explicit 40-constant pressure
metrics establish that the ON flag changes generated machine code:

| Allocator | Emitted recipes OFF → ON | Spills OFF → ON | Reloads OFF → ON | Spill bytes OFF → ON | Code bytes OFF → ON |
| --- | ---: | ---: | ---: | ---: | ---: |
| Linear scan | 0 → 28 | 28 → 0 | 28 → 0 | 224 → 0 | 736 → 512 |
| Greedy | 0 → 29 | 57 → 0 | 29 → 0 | 232 → 0 | 896 → 480 |
| Backtracking | 0 → 29 | 29 → 0 | 29 → 0 | 232 → 0 | 736 → 496 |
| Chordal | 0 → 28 | 28 → 0 | 28 → 0 | 224 → 0 | 736 → 512 |

All four frames shrink from 240 bytes to zero. This targeted feature gate
is not runtime timing or evidence of an overall allocator ranking. The
independent retained-output checker requires positive activity and strict
reduction for every backend.
