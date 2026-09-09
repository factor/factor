# Decoupled SSA chordal allocation

This experimental allocator reduces register pressure in SSA form **before**
coloring. It then certifies the rewritten interference graph, assigns physical
registers using copy and phi preferences, and lowers SSA edges into parallel
physical transfers. Linear scan remains the default allocator.

Load `compiler.cfg.register-allocation.chordal` and select it with
`chordal-allocator register-allocator set`. The public
`chordal-allocation-with-registers ( cfg registers -- )` kernel accepts an
explicit admissible bank for constrained validation.

## Allocation pipeline

1. **Prepare SSA liveness and GC provenance.** Phi operands are uses on their
   incoming edges. Derived-pointer phis receive companion tagged-base phis so
   the selected address and its GC base follow the same edge. Shared allocation
   preparation runs before the final value-flow verifier's snapshot, and the
   chordal kernel reuses that context.
2. **Place spills and repair SSA.** `spilling.next-use` computes CFG-wide next-use
   distances, translates phi uses per predecessor, and penalizes exits from
   natural loops. The source spiller tracks register-resident values and valid
   memory homes separately. It evicts values with distant uses, protects an
   instruction's required operands and temporaries, and emits actual stores
   and fresh reload definitions. Block-entry selection accounts for common
   predecessor residency and loop-local pressure. Register repair phis join
   incoming versions; memory phis permit more live phi values than registers.
   Edge coupling emits required stores before reloads. Proven constant recipes
   can replace stores and reloads when rematerialization is enabled.
3. **Certify and color the rewritten graph.** Phase-aware intervals describe
   the resulting SSA program, excluding fixed memory tokens. Graph construction
   intersects complete range lists, preserving holes and register classes.
   Maximum-cardinality search produces an order whose earlier-neighbor cliques
   are checked explicitly; its reverse is a perfect elimination order (PEO).
   Coloring selects only registers in the supplied bank. A nonchordal graph,
   impossible mandatory operand demand, or insufficient bank raises an error.
4. **Prefer matching physical locations.** Copy and phi affinities carry loop
   weights, with weaker preferences for first-input/result reuse. Affinity
   groups share color preferences, while every interference edge remains
   authoritative. This coalesces transfers by choosing equal legal colors;
   it does not merge graph vertices or discard conflicting edges.
5. **Apply the chosen assignment and destroy SSA.** Shared `ssa` and
   `ssa.phases` helpers rename operands and resolve incoming edges. Phi
   transfers retain simultaneous semantics, including cycles and stack-to-stack
   copies. Scratch preservation uses the widest representation in the borrowed
   register class. Transfers whose source and destination are already the same
   physical location need no move.

The final coloring is never repaired by interval splitting or another
allocator. Shared intervals and assignment routines transport the source
spiller's homes and the certified colors; they do not choose an allocation
policy. The production path does not call the legacy copy-leader or bounded
recoloring helpers retained for direct tests.

## ABI, GC, and target constraints

Clobber instructions end resident register versions and use explicit memory
homes for ABI operands and live values. GC maps retain both derived pointers
and their tagged bases after source rewriting; provenance is not reconstructed
from opaque reloads. A plain integer input to a derived-pointer phi selects an
immutable false base. The existing arithmetic provenance rules remain in
force, and inconsistent cyclic provenance raises an error.

Factor call, prologue, and epilogue kill blocks receive no resident entry values
or register repair phis. In particular, a callback's raw hidden result pointer
stays in its ABI-created memory home across Factor calls, with reloads on
ordinary blocks or edges. This preserves the existing callback contract; it
does not introduce support for arbitrary tagged virtual values live across
Factor calls without GC metadata.

The admissible bank excludes reserved and frame registers. Scalar floating
point and SIMD values share their physical register class. The first ordinary
input occupies the early instruction phase; other inputs and results occupy
the late phase. All inputs of `def-is-use-insn` are late, and temporaries span
both phases. Distinct block-boundary endpoints avoid artificial interference
between unrelated layout neighbors. Backend-specific two-address moves remain
necessary.

The certificate establishes chordality of the **actual rewritten graph** and
legal uniform coloring within each admitted register class. It does not prove
optimal spill placement, minimum copies, or optimal constrained machine-code
assignment. Factor has no generic descriptor for arbitrary precolors and tied
operands, so this implementation does not claim the full register-targeting
model of the papers. Dense graphs still need quadratic adjacency storage and
can require quadratic candidate work.

## Diagnostics and validation

`allocator-statistics` reports `algorithm = "decoupled-ssa-chordal"`, zero
`fallback-count` and `repair-assignments`, source pressure stores, fresh reload
definitions, repair/memory phis, edge blocks, and certified color assignments.
`post-spill-chordal?` describes the graph after pressure reduction. Enabling
`chordal-witness?` also retains that graph, its conventional PEO, color map,
register capacities, and source store/reload counts immediately before coloring.
These larger witnesses are omitted during normal compilation.

`check-allocation?` enables interval checks. With
`compiler.cfg.register-allocation.verifier` loaded, the public allocation
dispatcher also checks final symbolic value flow, including phi edges, ABI
operands, GC metadata, and rematerialization provenance. Direct kernel callers
must use the validation wrapper or invoke snapshot/check operations explicitly.

Tests include independent graph-order/clique oracles, rejection of invalid
coloring obligations, source stores/reloads under two-register pressure,
reduced-bank diamonds and cyclic phi permutations, floating-point and SIMD
constraints, forty-result phi joins, and moving derived roots. The actual
`compiler/tests/alien-large-return.factor` C fixture also executes compacting-GC
and nested callbacks with rematerialization off and on. A source regression
checks that a raw live-through value is saved and reloaded around a kill block
without inserting register phis there.

See [algorithm-audit.md](algorithm-audit.md) for the primary-paper and pinned
libFirm source audit and the feature-to-code-to-test matrix. Reproduction
scripts and retained correctness evidence are in
[reference/allocator-full-chordal-20260908](../../../../../reference/allocator-full-chordal-20260908/).
[measurements.md](measurements.md) records the earlier color-first prototype;
its counts and interval-repair descriptions are historical, not measurements
of this pipeline. Matched native runtime, code-size, and bootstrap comparisons
are separate acceptance gates; passing correctness tests is not a speed claim.
