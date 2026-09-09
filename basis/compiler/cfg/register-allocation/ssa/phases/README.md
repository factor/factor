# Paired SSA operand phases

`compute-phase-ssa-intervals` and `assign-phase-ssa-registers` must be used
together. They preserve ordinary instruction numbers while distinguishing
an early first input (`n`) from late inputs and outputs (`n+1`). Instructions
in `def-is-use-insn` have all inputs late. Scratch temporaries span both phases.
Phi definitions stay simultaneous at block entry, and outgoing liveness
extends through the final phase of the block.

Clobber instructions, including ABI memory operands, and explicit `##call-gc`
retain the existing indivisible point `n`. Their spill-slot flags, sync points,
and GC save/restore behavior are unchanged. This avoids silently retiming
native call clobbers into the ordinary instruction model.

Assignment captures the first input's incoming physical location before
expiring it and activating late outputs. Other input mappings are captured
at the late phase. The actual machine instruction still reads all its inputs
before any output is available.

Therefore a split fragment with `reload-from` starting at a late phase is
rejected by `unsafe-late-ssa-reload`. Such a reload executes before the machine
instruction and could destroy the captured first input. A splitting allocator
must activate input-bearing reload fragments by the early phase and extend
their ranges accordingly. Final unsplit coloring with explicit source-level
spill/reload instructions satisfies this restriction naturally. This API does
not move unsafe transports speculatively or fall back to another allocator.

The tests check the phase endpoints, scratch overlap, ABI spill flags, a
rejected late reload, and native unknown-input addition using exactly two
integer registers with no spill/reload interval fragments. The explicitly
named test kernel uses the reference interval allocator only to exercise the
mechanical API; it is not an implementation of the chordal algorithm.

The `-with-locations` variants accept the same fixed memory-token map as the
shared SSA mechanics. Fixed tokens are filtered before interval finalization
and seeded after assignment initialization. The block walk expires outgoing
products before activating incoming products, using the shared block-boundary
lifecycle. This prevents an old fragment from deleting its replacement's
pending register mapping.
