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

Required stage | Planned Factor code | Behavioral acceptance
--- | --- | ---
CFG-global next-use distances, loop-exit penalties | chordal.spilling | A use after a loop loses to a nearer in-loop use; diamonds take minimum successor distance.
Register-resident and memory-valid block state | chordal.spilling | A join with differing incoming residency emits coupling on precisely the necessary edges.
Pressure reduction before coloring | chordal.spilling | Reduced-bank pressure witnesses contain actual stores/reloads before graph construction, with pressure at most the bank size.
SSA repair after reload insertion | chordal.spilling | Reloads have fresh definitions; entry phis join incoming register versions; loops and diamonds execute correctly.
Memory-valued phis | shared SSA mechanics plus spilling | More simultaneous phi values than registers remains allocatable; stack-to-stack cycles preserve all values.
GC and ABI constraints before coloring | chordal.spilling | Clobbers split live values; required memory inputs/outputs and root/base slots are explicit and remain verifier-valid.
Colorability certificate after rewriting | chordal | Rebuilt graph has a checked perfect elimination order and per-class pressure/color bounds.
Preference-guided physical assignment | chordal | Affinity chunks propagate color preferences; every original interference edge remains satisfied.
Assignment and SSA destruction honor chosen colors | shared SSA mechanics | All assigned registers equal the chosen colors; symbolic final-value verification and executed cyclic phi tests pass.
No allocation-time fallback | chordal | `algorithm` identifies decoupled SSA; `fallback-count` and `repair-assignments` are zero; no interval allocation/splitting policy is called after coloring.

Factor-specific constraints
---------------------------

The physical bank excludes reserved/frame registers. Scalar FP and SIMD values
share their register class. Operands, results and temporaries conservatively
interfere at their instruction; this preserves late-input and def-is-use rules.
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

Completion is gated on the behavioral matrix, whole allocator/compiler tests,
executed cross-architecture pressure workloads, and measured compile/runtime
comparisons. The default allocator and optional feature defaults are unchanged.
