# Managed-slot must-availability

This opt-in pass reuses a `##slot-imm` result only when the exact SSA object,
slot number, and tag match an available load. Incoming facts must contain the
same defining SSA result on every predecessor; equal address keys with distinct
sibling results are insufficient. No phi is synthesized. Entry facts are empty,
and the existing dataflow framework treats kill blocks as barriers. Analysis
converges before any instruction is replaced. The fixed instruction stream
records each load's original result; replacement copies remain definitions
until subsequent copy propagation.

Every managed or raw store, Factor/alien call, allocation, GC operation, write
barrier, and unknown instruction clears all facts. There is no non-alias claim
for distinct incoming stack objects or SSA object identities. No stores are
removed or forwarded. Arithmetic and representation operations classified as
foldable, read-only slot operations, stack bookkeeping, phis, and control-flow
instructions preserve facts. Allocation and GC classifications override the
foldable classification: several boxing instructions belong to both.

The key includes the tag because it participates in effective addressing.
Only managed tagged slot loads are candidates; raw/volatile/atomic memory and
VM fields are not. The existing managed-slot semantics exclude unsynchronized
external mutation between ordinary non-effect instructions. Calls and unknown
effects do not inherit that assumption.

There is one must-availability analysis followed by a rewrite walk. CFG edges,
object identities, and memory effects are unchanged. The pass does not hoist or
speculate a load: each replacement reads an SSA result already available on
every path. It does not promise elimination at loop headers when different
original load definitions meet. The enabled path skips analysis with fewer
than two candidate loads; the disabled path performs no CFG walk.

The final allocator verifier snapshots after this optimization. It checks
transport of the rewritten values, not equivalence to the original memory
operations. Native alias/mutation oracles are therefore required independently
of SSA and allocation checks. Reusing a load extends a live range and may cost
more spills, so the flag remains off until measurements justify enabling it.
