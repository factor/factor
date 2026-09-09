# Full allocator integration checks, 2026-09-08

This directory retains integration checks, including intermediate failures and
their corrected runs. The source revision and exact invocation are recorded
alongside each run. Validation durations are not performance measurements.

The implemented pipelines are staged greedy allocation with CFG region
placement and bounded recoloring, SSA bundle backtracking with directed splits
and second chances, and SSA spilling before certified chordal coloring. Their
mechanisms and target limitations are reviewed in the
[independent audit](../allocator-full-comparison-20260908/AUDIT.md).
Linear scan remains the default; GVN remains off.

The [compiler and bootstrap acceptance record](ACCEPTANCE.md) describes the
compiler-suite gate at source `29b4551bb3`, including the unresolved two-minute
bootstrap target. Subsequent full benchmark-closure checks exposed greedy
fragment representation and backtracking transport failures. Their original
logs are retained in the comparison directory; the earlier suite pass does not
supersede those failures. The corrected source `30a50ab0df` passes the final full compiler suite and
documentation checks. Final performance comparisons still require its fresh
all-four benchmark closure checks on both architectures; see the acceptance
record for the exact distinction.

`reduced-bank.factor` independently checks 33 generated CFGs and 225 native
answers per allocator: nine pressure diamonds with three supplied register
banks, and three rotating-phi loops both with and without GC points. Inputs
include both branches, zero iterations, and repeated loop backedges. The final
value-flow checker and a separate physical reduced-bank audit are active.

At the first recorded intermediate revision, linear scan, greedy and
backtracking passed; chordal's completed source-spilling/coloring pipeline
arrived later. These intermediate logs must not be used as a performance
ranking.

## Completed core integration

`backtracking-chordal-complete-cores/` records the integrated backtracking and
chordal kernels passing the same 33 CFGs with rematerialization both off and on:
900 independent native answers with final value-flow and reduced-bank checks.
`greedy-complete-core/` records the completed region/local greedy core passing
the same 225-answer corpus. The later urgent-cascade fix has separate broad
CFG validation in the greedy owner's report.

The separately discovered shared derived-pointer-phi GC provenance gap was
subsequently repaired before the timing baseline was prepared. Both revisions
include the shared fix. Independent native moving-object checks cover all four
allocators, raw-derived and tagged-base phis, rematerialization off/on and
reduced register banks. See the comparison audit for exact source and evidence.
