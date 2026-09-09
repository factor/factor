# SSA bundle backtracking allocator

Select `backtracking-allocator` through the common `register-allocator` protocol.
The default remains linear scan. `backtracking-allocation-with-registers
( cfg registers -- )` accepts a reduced bank for validation; it does not call
another allocation policy.

The implementation now retains original SSA identities through allocation.
Copy and phi affinities request noninterfering bundle merges; they do not
assert that different incoming phi values have equal bits. Spillsets retain
original complete ranges, typed storage and register hints across splitting.
Nonoverlapping spillsets may share one stack home.

The main priority queue probes indexed physical occupancy, evicts strictly
lower-weight conflicts, and splits bundles at actual obstruction positions.
Splits preserve compatible groups on each side and retain their spillset.
Loop nesting weights both uses and candidate move sites. At an obstruction
on the first use, shrinking reaches a minimal mandatory fragment with infinite
weight; this is the progress case, not a claim that this immediate prefix is
already free. Impossible mandatory pressure raises an error.

After mandatory allocation, canonical no-use ranges receive one non-evicting
second chance. Clobber and GC points remain barriers. Register transitions
inside a block are reified as parallel moves, including every simultaneous
stack reload or constant recipe. Phi and CFG edge moves use the shared SSA
transport, including cycle and stack-to-stack handling. Stack-capable phi
fragments never force simultaneous phi outputs into physical registers.

This is ongoing implementation of the pinned Ion contract in
[ALGORITHM.md](ALGORITHM.md), not a claim to reproduce regalloc2 byte for byte.
The current conservative SSA interval builder still prevents productive copy
merging at touching use/definition positions; phase-aware constraints are the
next implementation step. Fixed preg, pinned-vreg and reused-input-index
fields do not exist in Factor's lowered allocator IR; its ABI slots, clobbers,
temporary registers and architecture emitter constraints are the actual
contract. The final symbolic verifier checks original value provenance.

`allocator-statistics` reports the algorithm, zero fallback count, bundle
merges, evictions, directed/minimal splits, hint reuse, second-chance attempts
and successes, shared homes and reified register transitions. The live
`bundle-spillsets`, `spill-home-pool`, `assigned-bundles` and
`backtracking-original-intervals` expose small-fixture witnesses without
instrumenting production allocation.

Tests cover distinct-value and rejected overlapping bundles, shared-home
noninterference, obstruction splits, register-cycle reification, a successful
second chance, native forty-value pressure and forty distinct phi results on
both branch paths. On native ARM64 the forty-phi fixture executes to 920.0 and
-720.0 and exercises 80 bundle merges, 38 evictions and 62 directed splits.
The complete register-allocation subtree passes with SSA, interval, mandatory
operand and final value-flow checks enabled. These are mechanism/correctness
results; performance comparisons wait for completion of the remaining contract.
