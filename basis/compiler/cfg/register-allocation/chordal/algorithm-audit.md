Decoupled SSA allocation: implementation and acceptance contract
==============================================================

The former allocator colored original intervals and delegated excess colors to
next-use interval repair. It did not implement a spill-before-color pipeline.
This work replaces that policy; changing its affinity weights is insufficient.

Primary references audited:

- Hack, Register Allocation for Programs in SSA Form, sections 4.2–4.6:
  https://publikationen.bibliothek.kit.edu/1000007166/6532
- Braun and Hack, Register Spilling and Live-Range Splitting for SSA-Form
  Programs, CC 2009, algorithms 1–2 and sections 4.1–4.4:
  https://pp.ipd.kit.edu/uploads/publikationen/braun09cc.pdf
- Braun, Mallon and Hack, Preference-Guided Register Assignment, CC 2010,
  sections 2–4: https://pp.ipd.kit.edu/uploads/publikationen/braun10cc.pdf
- libFirm source pinned at 114012d1d93427e63ba2f2ab51318e8a1b92f06c:
  https://github.com/libfirm/libfirm/tree/114012d1d93427e63ba2f2ab51318e8a1b92f06c/ir/be
  `bespillbelady.c`: displace, decide_start_workset, process_block;
  `bespill.c`/spill utilities: materializing recorded spill decisions;
  `bechordal.c`: separately sequenced spilling and register assignment;
  `beprefalloc.c`: preferences and assignment. The Factor implementation is
  independently written for Factor IR; no libFirm source is copied.

Required stage | Factor implementation | Behavioral acceptance
--- | --- | ---
CFG-global next-use distances, loop-exit penalties | spilling.next-use: compute-next-uses, loop-exit-penalty | Minimum merge, predecessor-specific phi use, and equal-depth sibling-loop exit fixtures.
Register-resident and memory-valid block state | spilling: rewrite-spill-block, couple-spill-edge | W/S eviction and edge-transfer tests; native diamonds with differing residency.
Pressure reduction before coloring | spilling: limit-residents, rewrite-ordinary-insn | Actual two-register source stores/reloads, including dying first-input reuse; impossible operand pressure raises explicitly.
SSA repair after reload insertion | spilling: reload-value, make-entry-versions | Reloads have fresh definitions; entry phis join incoming register versions; loops and diamonds execute correctly.
Memory-valued phis | shared SSA mechanics plus spilling | More simultaneous phi values than registers remains allocatable; stack-to-stack cycles preserve all values.
GC and ABI constraints before coloring | chordal.spilling | Clobbers split live values; required memory inputs/outputs and root/base slots are explicit and remain verifier-valid.
Colorability certificate after rewriting | chordal: assign-certified-colors | Rebuilt graph has a checked perfect elimination order; assignment is limited to the supplied bank, with a negative insufficient-bank test.
Preference-guided physical assignment | chordal: weighted-ssa-affinities, preference-guided-colors | Shared chunk preference vectors, stronger loop-weighted phi/copy preferences and weaker first-input reuse preferences; every original interference edge remains satisfied.
Assignment and SSA destruction honor chosen colors | shared SSA mechanics | All assigned registers equal the chosen colors; symbolic final-value verification and executed cyclic phi tests pass.
No allocation-time fallback | chordal | `algorithm` identifies decoupled SSA; `fallback-count` and `repair-assignments` are zero; no interval allocation/splitting policy is called after coloring.

Factor-specific constraints
---------------------------

The physical bank excludes reserved/frame registers. Scalar FP and SIMD values
share their register class. An ordinary first input is consumed at the early
phase; remaining inputs and results occupy the late phase. All def-is-use inputs
are late, and temporaries span both phases. Block boundaries use distinct phase
endpoints, avoiding false interference between unrelated layout neighbors.
ABI stack operands are modeled as memory tokens, not colors. The backend's
instruction-specific two-address moves remain necessary; Factor has no generic
arbitrary precolor/tied-operand constraint descriptor to claim full register
targeting for. The chromatic certificate applies to the actual rewritten graph
and admitted bank, not an unqualified theorem about every machine constraint.

Memory tokens are distinct from ordinary SSA definition vregs. They name fixed
spill slots or proven constant recipes and are excluded only from register
pressure/coloring. Ordinary definitions still require registers; reloads define
fresh ordinary vregs. Root maps refer to the appropriate memory tokens and are
preserved after spill insertion, so GC provenance is not rediscovered from an
opaque reload instruction. Final machine-value checking remains independent.

The pipeline never calls interval register assignment or interval splitting.
Intervals describe the already rewritten SSA program and carry the certified
physical choices into mechanical assignment. Non-chordal or over-budget output
raises an explicit error; there is no alternative allocator hidden in that path.

The public reduced-bank entry is `chordal-allocation-with-registers`.
`chordal-statistics` records the algorithm name, zero fallback/repair counts,
source stores, fresh reloads, repair and memory phis, edge blocks, and certified
color assignments. Set `chordal-witness?` to retain the graph, conventional PEO
(reverse MCS selection order), and color map for an independent bounded checker.
Large witness maps are omitted during ordinary compilation.

Native validation currently includes the 33 generated reduced-bank CFGs and
225 independent result formulas, repeated with rematerialization off and on.
This covers branch-dependent pressure, cyclic phi permutations and collection
inside loops. The chordal subtree also exercises floating point, FFI, derived
roots and forty simultaneous phi results. Full closure/compiler tests,
cross-architecture results and comparative runtime/code-size measurements are
separate completion gates; passing these local tests is not a speed claim.
The default allocator and optional feature defaults are unchanged.
