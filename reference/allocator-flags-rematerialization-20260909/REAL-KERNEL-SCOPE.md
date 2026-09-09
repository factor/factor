# Interpreting unchanged rematerialization kernel metrics

This is a static source audit at `ad0fc337de`, not a new execution result. The
parent reported unchanged ARM static reports for the twelve metric targets when
only rematerialization was toggled. An observer probe was deferred before timing
started because setup plus twelve OFF/ON compilations was not guaranteed to fit
the available 30-second correctness window. No Factor process was launched for
this followup and no timing harness was changed.

The executed synthetic witness already disproves broken activation in linear
scan and the three alternative allocators. It does not establish that every real
kernel contains eligible spilled constants. Identical code-size/spill/reload
counts alone do not establish zero recipe emissions: instruction identity or
literal choices could differ while aggregate counts remain equal.

The actual `metric-workloads` list lives in
`reference/allocator-speed-crossarch-20260908/pressure.factor`. Its pressure
fixtures stress substantially different values from the synthetic witness:

| Targets | Main live values in source | Relation to supported recipes |
| --- | --- | --- |
| float-pressure, ffi-pressure, branch-pressure | Thirty-two runtime `x + floating literal` results | Neither floating constants nor arithmetic expressions are eligible. |
| integer-pressure | Forty runtime `x + small integer` results | Arithmetic results are not eligible. Small operands can become immediate instruction fields and need no live constant register. This is not forty independently loaded constants. |
| simd-pressure | Thirty-two computed SIMD vectors | Vector constants and vector arithmetic are outside the recipe set. |
| gc-pressure | Thirty-two newly allocated arrays kept live across collection | Tagged objects and GC-visible homes are explicitly excluded. |
| spectral-norm, nbody, nbody-simd, struct-arrays-bench | Floating/vector computation with dynamic arrays and objects | Their primary data and constants are excluded; incidental integer constants still require instruction-level examination. |
| fannkuch, binary-trees | Runtime counters, permutations, recursive allocated trees | Dynamic values/objects are not cheap constant recipes; incidental eligible constants remain possible. |

This explains why high pressure does not imply opportunity for this restricted
integer-constant transformation. It is a source-level inference, not a proof of
zero emissions in any particular generated kernel. A later short diagnostic can
count `rematerialization-observer` calls around each `measure-compilation`, while
forwarding the existing observer so strict provenance checking remains enabled.
The per-CFG `rematerialization-count` alone is insufficient for a multi-procedure
word unless it is accumulated at every allocation; preparation resets it.

The timing harness separately recompiles the whole selected helper closure and
then reports twelve individual kernel compilations. The scope list is much
larger than those twelve targets. Unchanged twelve-kernel static reports do not
exclude changed helper code, additional recipe-analysis compilation overhead, or
helper-closure runtime effects. Whole-closure effects must come from the actual
factorial measurements or an explicitly scoped observer, not extrapolation from
the synthetic spill reduction.
