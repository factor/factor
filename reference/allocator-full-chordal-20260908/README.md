# Decoupled SSA chordal validation

This directory records correctness evidence, not ranked timing measurements.
The default allocator remains linear scan; global value numbering remains off.

The implementation is in commits `1456b9c741`, `8c1bb505b0`, `7f040dd1fa`
and `b24a9fde54`, with shared SSA mechanics and operand-phase fixes supplied by
the other allocator workstreams. `ab2fdc5e38` repairs synthetic test setup when
running the whole CFG suite with rematerialization globally enabled.

## Actual stages

1. Compute CFG minimum next-use distances, translating phi uses separately on
   each incoming edge and penalizing exits from any enclosing natural loop.
2. Choose block-entry residency, reserving loop capacity before retaining
   values that are unused inside the loop. Track register residency W and
   valid memory homes S while evicting values by farthest next use.
3. Insert real stores and fresh SSA reload definitions before instructions;
   split at GC/ABI clobbers. Repair register versions with entry phis and edge
   reloads. Nonresident phi values use distinct fixed memory names and parallel
   memory-phi resolution. Edge stores precede reloads.
4. Recompute liveness while preserving precise GC root/base maps. Build the
   register graph from the rewritten SSA instructions, excluding fixed memory
   names. Check its PEO before assigning any physical register.
5. Assign only colors in the supplied physical bank, using shared affinity
   chunk preferences and loop-weighted copy/phi preferences. The graph remains
   unchanged throughout assignment. No interval allocator, interval splitting,
   or alternate allocation policy is invoked.
6. Apply the selected colors through paired early/late operand phases and
   destroy phis using the shared parallel transport mechanism.

The detailed primary-reference/feature/test matrix is
`basis/compiler/cfg/register-allocation/chordal/algorithm-audit.md`.

## Recorded checks

| Evidence | Result |
| --- | --- |
| `linear-native` | Unknown runtime input under two integer registers: results 27 and -6 match `3*x+6`; two actual stores and two fresh reloads, nine certified assignments, no fallback. |
| `reduced-corpus` | 33 generated CFGs and 225 independent native answers, repeated with rematerialization off and on. Includes diamonds, phi permutation loops, and GC inside loops. |
| `cfg-off` | Whole `compiler.cfg` subtree, chordal selected, SSA/interval/final-value-flow checking enabled, global rematerialization off: zero failures. |
| `cfg-on` | Same subtree with global rematerialization on: zero failures. |

The early native corpus record predates the positive rematerialization fix;
it proves execution under both flag settings, not recipe activation. The later
whole-CFG records include the rematerialization fixture that requires positive
recipe emission and strictly fewer spills, reloads, spill bytes and code bytes
for all four allocators, as well as executed rematerialization fixtures.

The globally enabled run initially exposed synthetic interval fixtures reusing
vreg numbers from an earlier, unrelated constant CFG. Resetting that fixture's
recipe map restores its intended independent allocation problem; the feature
flag stays enabled. The sync-point fixture now supplies an explicit empty GC
map. No production tests are excluded and no production collector check is
disabled.

Each result includes the runner's source/image/executable metadata and exit
status. Some measurements were captured with the working changes subsequently
committed above; `source_status` preserves that fact. Durations are validation
run durations and must not be interpreted as allocator performance comparisons.

## Reproduction

Use a VM and prepared image matching the source's native architecture. Always
pass an explicit resource path. The committed `cfg-suite.factor` refreshes the
changed compiler vocabularies before selecting the allocator:

```sh
factor -i=/absolute/path/prepared.image -no-user-init \
  -resource-path=/absolute/path/worktree \
  reference/allocator-full-chordal-20260908/cfg-suite.factor chordal off off
```

Change the second positional argument to `on` for the globally enabled recipe
run. On the macOS benchmark host these checks were launched through the existing
`run-command.py` parent wrapper to maintain the requested process policy.

The generated corpus implementation and arithmetic oracle are in
`reference/allocator-full-integration-20260908/reduced-bank.factor`; invoke
`validate-reduced-corpus` with `chordal-allocator` and the explicit quotation
`[ chordal-allocation-with-registers ]` after refreshing the compiler.

Set `chordal-witness?` to retain graph, PEO, color map, register capacities and
actual source spill/reload counts before coloring. The comparison workstream's
independent witness checker validates graph symmetry, every interference edge,
the PEO clique condition, legal colors and the uniform-bank optimum. Witnesses
do not replace final symbolic checking or executed native results.

Matched whole-closure compilation, runtime, code-size and cross-architecture
measurements belong to the parent comparison report. No speedup is claimed by
these local validation records.

The independent x86 recipe audit (`f45deed012`) separately measured the same
constant-pressure fixture with recipes off/on: 28/0 spills, 28/0 reloads,
224/0 spill bytes, 240/0 frame bytes and 736/512 code bytes, with 28 actual
recipe emissions when enabled. This compares the optional recipe setting
within the new allocator; it is not a before/after allocator benchmark.
