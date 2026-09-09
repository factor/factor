# Backtracking implementation contract

Reference pinned to bytecodealliance/regalloc2 commit
`2fe490bc9dda433f70c54f90f7633ed929f693d9` (retrieved 2026-09-08):
[Ion design](https://github.com/bytecodealliance/regalloc2/blob/2fe490bc9dda433f70c54f90f7633ed929f693d9/doc/ION.md),
[bundle processing](https://github.com/bytecodealliance/regalloc2/blob/2fe490bc9dda433f70c54f90f7633ed929f693d9/src/ion/process.rs).

The earlier implementation is a size-ordered eviction queue over already
SSA-destroyed intervals. It is not the complete Ion algorithm. This document
tracks replacement requirements; a row is not complete merely because a
similarly named counter or helper exists.

| Reference mechanism | Required Factor behavior | Initial status |
|---|---|---|
| SSA range construction, edge operands | Preserve phi inputs and original identities until moves are emitted; derived bases remain separate | Missing in backtracking; shared SSA extraction pending |
| Bundle merging | Merge distinct noninterfering phi/copy affinity values; reject interference and incompatible representations | Missing: only same-leader fragments grouped |
| Spillsets and register hints | Descendants share stable membership, hints and typed homes without equating SSA values | Missing |
| Constraint meet and fixed clobbers | All mandatory uses allocated; stack-only ABI operands isolated; keep-destination exception honored | Stack/clobber splitting exists; refine and test with SSA |
| Allocation-map probing | Exact holes, full conflict set, maximum conflicting weight, first conflict position | Exact indexed conflicts exist; conflict position missing |
| Eviction and progress | Strictly higher weight evicts; finite splits reach mandatory minimal intervals; no alternate allocator fallback | Basic protocol exists |
| Conflict-directed splitting | Split merged bundles at probed obstruction, preserve useful groups, use loop boundary costs | Missing: unbundle then median |
| Canonical spill bundles | Retain no-use ranges for one second-chance allocation after mandatory bundles | Missing |
| Spill slot allocation | Reuse homes for nonoverlapping spillsets with compatible storage; all fragments agree | Only per-vreg slots |
| Move reification | Resolve phi, split, clobber and cycle moves; stack-to-stack safe; final symbolic SSA checker passes | Shared mechanisms exist; SSA integration pending |

Factor target constraints differ from regalloc2's client API. At this allocation
boundary ordinary operands specify representations/register classes, temporary
operands, memory-only ABI operands and whole-register-file clobbers. Explicit
per-operand fixed physical registers, early/late operand policy, pinned vregs,
and regalloc2-style reused-input indices are not represented. Architecture
lowering owns those fixed-register ABI shuffles. Tests must exercise the actual
lowered contract rather than fabricate unsupported operand fields.

Completion requires behavioral fixtures for every applicable row, executed
branch/loop/FFI/GC pressure with the final value-flow checker, and feature counters
showing that merging, eviction, directed splitting, second chance and shared
homes actually occur. The linear-scan default remains unchanged. Broad timing
comparisons follow correctness and mechanism completion.
