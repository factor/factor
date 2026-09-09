# Derived-pointer phi bases

A derived pointer can arrive at a phi from different heap objects. The
collector needs the tagged base selected on the same incoming edge; choosing
one predecessor's base or omitting the derived entry leaves an unrelocated
address. A caller keeping the original objects rooted does not repair that
stale derived spill.

`prepare-allocation-bases` constructs companion tagged-base phis before the
allocator dispatcher takes the value-flow snapshot. This makes the base phi,
its incoming values, and the derived/base obligation part of the independent
specification. The no-phi path inspects block headers only. The no-GC path
skips derived-definition analysis and adds no companion phis.

The dispatcher preserves an immutable `initial-base-pointers` seed map for
that CFG. Liveness resets clone those seeds before filling their cache. The
mapping remains valid when CSSA introduces copies: the original virtual
values still identify the derived result and selected tagged base. The
SSA allocators' `construct-ssa-bases` helper recognizes the active CFG and
reuses its preparation, preventing duplicate companion phis.

Context restoration uses `finally` and restores only the two context
variables. It does not introduce a namespace that would discard allocator
statistics. With no preparation and no enclosing active context, allocation
takes the direct dispatch path.

The compatibility vocabulary `compiler.cfg.register-allocation.chordal.bases`
re-exports the shared helper names. It contains no allocation policy.

Tests execute both tagged-base phis followed by an offset and phis of already
derived addresses from distinct bases, using four integer registers and both
rematerialization settings. Fresh caller-rooted heap objects provide the
native identity oracle. A separate mutation removes the final derived map
and must fail symbolic verification; the snapshot is also checked to contain
the selected base and derived obligation before allocation.
