# SSA bundle backtracking allocator

Select `backtracking-allocator` through `register-allocator`.
The default remains linear scan. `backtracking-allocation-with-registers
( cfg registers -- )` accepts a reduced register bank for validation and never
calls another allocation policy.

Original SSA identities survive allocation. Copy, phi and dying first-input
operand affinities request noninterfering bundle merges. Merging never asserts
that the member values contain equal bits. Spillsets retain complete original
ranges, typed homes and register hints through splitting; nonoverlapping
spillsets can reuse a stack slot.

The queue probes exact physical occupancy, evicts strictly lower-weight
conflicts and splits at actual obstruction positions. Static loop costs guide
split boundaries. A per-spillset split budget bounds repeated peeling, then
partitions the remaining uses directly into mandatory instruction fragments.
Paired early/late phases model Factor's two-operand constraints and prevent
reloads from overwriting a dying early input.

After mandatory allocation, canonical no-use spill bundles get one
non-evicting second chance. Clobber and GC points remain barriers. Local
register transitions, stack reloads and constant recipes form simultaneous
parallel moves. Shared SSA transport resolves CFG edges, phi inputs and cycles.
Stack-capable phi fragments do not require all phi outputs in registers.

[ALGORITHM.md](ALGORITHM.md) maps the pinned Ion reference to implementation
and behavioral tests, and lists target features absent from Factor's lowered
IR. [Recorded witnesses](../../../../../reference/allocator-full-backtracking-20260908/README.md)
expose actual bundle membership, spill homes, eviction and split partitions.

`allocator-statistics` reports `algorithm = ssa-bundle-backtracking`, zero
`fallback-count`, bundle merges, evictions, directed/minimal splits, exhausted
split budgets, loop-cluster splits, hint reuse, second-chance attempts and
successes, shared homes and register transitions. The optional `evidence`
vocabulary captures small fixtures without instrumenting production runs.

Native tests include forty-value pressure, distinct phi results on both branch
paths, productive copy/arithmetic merging, parallel register swaps and reduced
register banks. The compiler CFG suite passes with original-value checking.
These are correctness and mechanism results; benchmark results belong to the
separate frozen-source comparison.
