# Allocator tuning acceptance

## Greedy terminal-store repair and backtracking range index

Integrated source `63eb14ba87` passes the full compiler suite with greedy,
rematerialization and backtracking loop spilling enabled, GVN off, and SSA,
interval and final-machine value-flow checks active: zero test failures in
65.74 seconds. Exact command, original root VM/image hashes and output are
in [the retained run](full-compiler-greedy/status.json). This is a correctness
validation duration, not a benchmark measurement. The driver uses `refresh-all`
to load the coherent newer compiler and ABI definitions.

The greedy change preserves the original trailing memory obligation unless a
local product already ends exactly at its last use without an existing spill.
Independent owner tests cover mandatory definitions/uses, explicit spill homes,
live-through tails, forced expiry and outgoing edges including a loop backedge.
The backtracking index changes how occupied ranges are found, preserving the
resulting complement and allocation policy; an independent occupied-point
oracle covers partial/full/empty/holey ranges and clobber barriers.

## Final combined compiler gate

Frozen source `5c848c90f63cea092191b70e1678bec4441e0238` includes greedy terminal
stores, the backtracking range index and interior-gap policy, and both chordal
entry-residency and guaranteed-home join changes. The complete compiler suite
passes with backtracking, rematerialization and loop spilling enabled, GVN off,
and SSA, interval and final-machine value-flow checks active: zero failures,
exit 0 in 58.00 seconds. This is validation time, not a benchmark comparison.
The retained [status](full-compiler-backtracking/status.json) identifies the clean
source, exact command and unchanged baseline VM and original image.

The independent chordal tests cover known-empty versus unknown predecessor
states, phi source identity, mixed saved homes, and store-before-reload behavior.
The narrow backtracking policy preserves entry/exit and multiblock gaps, including
register transport across the fast edge around an out-of-line GC block.

## Cross-architecture gates

Both frozen revisions pass all four checked 26-workload closures on native
ARM64 and x86-64. Real C ABI callbacks pass for every allocator with
rematerialization off and on. Raw/tagged phi moving-GC probes pass with the final
value-flow verifier active. Across both hosts and sources the explicit gates
cover 160 C ABI assertions and 1,536 fresh object pairs. Exact preparation,
matched VM/image assets, commands and outcomes are retained in
[gate acceptance](gates/acceptance.json).

The broad two-round timing matrix and unprofiled saved-image bootstrap remain
pending. The diagnostic
[bootstrap profile](bootstrap-profile/README.md) is not an unprofiled bootstrap
or fresh-image acceptance run.
