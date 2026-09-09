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

Further chordal and backtracking transport changes require their own targeted
checks and final integrated gates before a frozen comparison. The diagnostic
[bootstrap profile](bootstrap-profile/README.md) is not an unprofiled bootstrap
or fresh-image acceptance run.
