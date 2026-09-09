# Full allocator integration checks, 2026-09-08

These are correctness checks of intermediate algorithm implementations, not
performance measurements or a claim of algorithm completeness. The source
revision and exact invocation are recorded alongside each run.

`reduced-bank.factor` independently checks 33 generated CFGs and 225 native
answers per allocator: nine pressure diamonds with three supplied register
banks, and three rotating-phi loops both with and without GC points. Inputs
include both branches, zero iterations, and repeated loop backedges. The final
value-flow checker and a separate physical reduced-bank audit are active.

At the recorded intermediate revision, linear scan, greedy, and backtracking
passed. Chordal is awaiting its completed source-spilling/coloring pipeline.
The scripts will be rerun on the final integrated source; these intermediate
logs must not be used as a performance ranking.

## Completed core integration

`backtracking-chordal-complete-cores/` records the integrated backtracking and
chordal kernels passing the same 33 CFGs with rematerialization both off and on:
900 independent native answers with final value-flow and reduced-bank checks.
`greedy-complete-core/` records the completed region/local greedy core passing
the same 225-answer corpus. The later urgent-cascade fix has separate broad
CFG validation in the greedy owner's report.

These results do not close the separately discovered shared derived-pointer-phi
GC provenance gap. A targeted moving-object test and shared fix are required
before freezing either candidate or corrected prototype for timing.
