# Backtracking implementation contract

Reference pinned to bytecodealliance/regalloc2 commit
`2fe490bc9dda433f70c54f90f7633ed929f693d9` (retrieved 2026-09-08):
[Ion design](https://github.com/bytecodealliance/regalloc2/blob/2fe490bc9dda433f70c54f90f7633ed929f693d9/doc/ION.md),
[bundle processing](https://github.com/bytecodealliance/regalloc2/blob/2fe490bc9dda433f70c54f90f7633ed929f693d9/src/ion/process.rs).

This implementation replaces the former eviction queue over SSA-destroyed
intervals with SSA bundle backtracking. The table identifies the corresponding
mechanism and behavioral evidence. It does not claim identical heuristics,
data structures, instruction numbering or output to regalloc2.

| Reference mechanism | Factor implementation | Behavioral evidence |
|---|---|---|
| SSA ranges and edge operands | `compute-phase-ssa-intervals`; identity leaders; phi operands remain edge-specific until transport | Native 40-value distinct phi diamond executes both paths; original value-flow checker |
| Bundle merging | `prepare-backtracking-affinities`, `coalesce-bundle-groups`; exact representation and full original range disjointness required | Copy chain plus arithmetic merges four distinct SSA values and executes 10→11; interfering affinity rejected; exported bundle witness |
| Spillsets and hints | `allocation-spillset`; descendants retain members, full original ranges, hint and split count | Split descendants retain one home; native phi merges; hint statistics |
| Constraint handling | Paired SSA input/output phases; sync splitting removes memory-only operands; keep-destination exception retained; mandatory instruction fragments have infinite weight | Consecutive late→early operand split conserves both uses; call slot test; native branch/loop/FFI/GC validation corpus |
| Allocation-map probing | Per-register ordered occupancy with inclusive holes; complete conflict set, maximum conflicting weight and first intersection | Indexed occupancy oracle, hole tests and exported exact eviction witness |
| Eviction and backtracking | Strictly greater requesting weight; release and requeue every conflicting bundle; directly assign the now-free requested register | Sparse/dense pressure forces eviction and retry; exported before/after occupancy and queue |
| Directed splitting | `first-bundle-conflict`, `conflict-split-site`, `split-bundle-at`; score obstruction with maximum conflict weight plus loop move cost; preserve groups and hints | Obstruction at 12 selects cut 9; initial obstruction peels first use; exported complete split partition |
| Hot/cold clusters | Cached nesting weights at early and late points; choose cheaper loop transition within the conflict prefix | Five-use fixture selects cut 19 before hot cluster; paired phase-weight test; optional loop-store pressure tests |
| Bounded progress | At most 16 progressive splits per original spillset, then directly partition remaining mandatory instruction clusters | 400-use alternating pressure triggers budget and >100 minimal fragments while interval/operand checks pass |
| Canonical spill bundles | Subtract allocated ranges, complete Factor-call blocks and clobber/GC barriers from original ranges; offer remaining no-use bundle one non-evicting second chance | Required fragments on register 0 with blocked middle; canonical gap assigned register 1, transition reified |
| Shared spill homes | `ensure-spillset-home` reuses exact-representation storage only for disjoint complete original spillset ranges | Two real pressure allocations share slot 0; exported member/descendant ranges and slots checked independently |
| Move reification | Local split transitions collected with simultaneous reloads and emitted during phase assignment before phi removal and GC saves; shared SSA edge transport handles phi, cycle and stack moves | Physical register swap passes original-value checker; native pressure and distinct phi branches; no-use second-chance transition |

Factor ranges use **inclusive** endpoints. Ordinary first inputs occupy early
point n; later inputs and results occupy n+1. For `def-is-use-insn`, all inputs
stay live through the result. Input fragments reload at an early point, even
when their first operand use is late. Temps conflict across both phases.
Clobber/ABI and explicit GC instructions remain atomic. Second-chance ranges
exclude whole Factor-call blocks. Successors of those blocks reload from memory;
ordinary predecessors at mixed joins initialize the same home through edge
resolution. Spill tails stay inside their original contiguous live range.
Implicit derived GC
bases participate in liveness; shared SSA machinery owns their transport.

Factor's lowered target contract has register classes, temporary registers,
whole-file clobbers and memory-only ABI operands. It has no client fields for
arbitrary fixed physical operands, pinned vregs, explicit arbitrary early/late
constraints or reused-input indices. Architecture lowering handles ABI register
shuffles; the first-input affinity models the actual two-operand emitter
constraint. Those absent client features are not claimed as implementations.

Implementation differences: occupancy uses ordered vectors rather than
regalloc2's B-tree; intervals use Factor's numbering and inclusive endpoints;
loop nesting supplies static costs rather than profile frequencies. Strict
weight eviction immediately assigns after removing the complete conflict set,
without an additional redundant probe. The split cap bounds repeated peeling;
it is not a claim that every allocator operation has regalloc2's complexity.
Initial obstruction splitting guarantees mandatory-piece progress, not an
already conflict-free first piece. Impossible mandatory pressure raises an
allocation error. There is no hidden linear-scan or other allocator fallback.

All applicable algorithm mechanisms above are implemented and tested. The
shared reduced-bank native corpus and full `compiler.cfg` suite pass with SSA,
interval, mandatory operand and final original-value checks enabled. The
separate shared derived-phi GC work and cross-architecture validation must be
integrated before declaring the complete compiler candidate validated.
Default linear scan remains unchanged. Performance claims require the separate
frozen-source benchmark run; mechanism counters alone are not performance.


Second-chance profitability refinement: a normalized no-use range strictly
inside one basic block is omitted unless it touches assigned fragments of
the same original value at both ends. One-ended residency only relocates the
existing memory transfer and may add a register copy; a range touching
neither end adds transfers. The original mandatory fragments retain their
spill/reload obligations. Entry, exit, and multiblock ranges remain eligible,
including fast-path carriers around out-of-line GC blocks. This is a local
transport-cost bound, not a claim of globally optimal CFG placement.
`interior-gaps-skipped` reports this decision separately from assignments.

Ordinary block-entry reloads can use the shared SSA edge resolver directly.
For an original live-in register fragment beginning exactly at phase entry,
with a stack-slot reload and only non-kill predecessors, the allocator may
publish its assigned register as the incoming location. Each predecessor then
supplies its actual register or memory value through the existing parallel
mapping. This avoids an edge store followed by a successor reload; it neither
assumes the spill home is initialized nor equates spillset members. The
fragment's outgoing store remains intact. Phi, GC, and ABI entry instructions,
blocks with kill predecessors, and values absent from the original live-in set
retain their explicit reload. `edge-entry-reloads` counts the delegated
transports. Tests exercise a simultaneous register swap and a mixed register /
memory incoming edge, and reject deleting their required edge copies.
