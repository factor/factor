# Backtracking tuning evidence

Base: `7b6cd9519a`. Policy-preserving fragment index: `dda193f12a`.
Interior-gap profitability change: `7e3f572c19`.

ARM validation used the root VM/libfactor copied into the isolated tuning
worktree and a clone of the master-candidate `full-master-default.factor.image`
(source680ab, same production7b6), with `refresh-all`, explicit resource path,
`-no-user-init`, and the parent-granted correctness CPU slot. Root assets were
not modified. The backtracking subtree passed with SSA, interval and final-value
checks enabled, rematerialization on, loop placement off. The FFI edge probe
uses both optional flags on and passed the 32,000-call native numerical oracle.

The index-only FFI output exactly matches prior ARM final-matrix allocation
counters, spills/reloads/copies and code size. This is policy-equivalence
evidence, not a compile-speed measurement. The second change removes only
normalized no-use ranges strictly inside one basic block with fewer than two
adjacent assigned fragments of the same original value. All CFG boundary and
multiblock bridges remain eligible. Original mandatory spill/reload obligations
remain intact; no memory-cleanliness or cross-value equivalence is inferred.

ARM FFI static result: copies36→20, code1392→1344 bytes. Spills58→60 and
reloads55→57 increase because the occupancy change admits another cross-GC
carrier (second-chance assignments21→22). Thirty-two interior gaps are skipped.
These static results alone do not establish a runtime benefit. Dynamic native
before/after attribution and broader policy acceptance remain pending.

`ffi-edges.factor` prints explicit per-instruction slots and predecessor/successor
machine-location maps before edge resolution, followed by final IR. Annotation
installation itself compiles helpers, so the full log includes earlier unrelated
CFGs; the target's JSON metric is the final record. `ffi-fixture.factor` contains
the exact frozen FFI workload body, extracted without loading unrelated benchmark
vocabs. The counters FFI library is the existing architecture-matched benchmark
helper under `reference/allocator-speed-crossarch-20260908/counters`.
