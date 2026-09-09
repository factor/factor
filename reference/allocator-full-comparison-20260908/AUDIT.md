# Independent mechanism audit before final timing

The reviewed source now contains distinct allocation policies, not renamed queue
orders. This assessment covers Factor's whole-register IR contract. It does not
claim that these ports implement every LLVM target facility or every regalloc2
API constraint. Performance and general correctness are separate gates; no final
source is accepted while a checked whole-compiler closure failure remains unresolved.

## LLVM-style greedy

Reviewed `50b11a026e` plus urgent-cascade correction `6537edf3f6`, against LLVM
`9851e4f8979b8b57557d03cd98b54f57287a128f`'s
[greedy allocator](https://github.com/llvm/llvm-project/blob/9851e4f8979b8b57557d03cd98b54f57287a128f/llvm/lib/CodeGen/RegAllocGreedy.cpp),
[eviction advisor](https://github.com/llvm/llvm-project/blob/9851e4f8979b8b57557d03cd98b54f57287a128f/llvm/lib/CodeGen/RegAllocEvictionAdvisor.cpp),
and [spill placement](https://github.com/llvm/llvm-project/blob/9851e4f8979b8b57557d03cd98b54f57287a128f/llvm/lib/CodeGen/SpillPlacement.cpp).

The production kernel has large-first priority, monotone assignment/region/local/
spill/terminal stages, hint-aware eviction costs, cascades, occupancy-indexed
interference, actual CFG residency splitting, local free-window refinement, and
bounded recursive recoloring with full occupancy rollback. Urgent minimal uses
can break a younger spillable cascade with a penalty; same-cascade and terminal
products remain protected. The earlier hint-only eviction of mandatory minimal
uses was corrected during audit.

`global-split-plan` constructs edges only where the value crosses both CFG
boundaries, applies physical interference as a hard memory constraint, and uses
static loop-weighted memory-use and transition costs. `apply-global-split`
installs resident fragments, including transparent blocks, and advances memory
blocks to local refinement. Local windows include the spill point after their
last selected use. The independent native solver audit matches exhaustive binary
optimization on 122 graphs. The owner's lowered hot-loop/bypass fixture also
checks final machine value flow; solver correctness alone does not certify
network construction or lowering.

The residency objective is a deterministic binary minimum cut, bounded to 128
live blocks, with local refinement beyond that bound. It differs from LLVM's
iterative placement solver. Conservative post-SSA interval phases, static
frequency estimates, and the absence of lane masks, ML advice, target folding,
and subregister units are explicit target boundaries. No alternate allocator
policy is called.

## SSA backtracking / ION

Reviewed the actual SSA bundle integration `1234c3f9b0`, bounded split completion
`ec5efcbe68`, and first-input/phase-cost refinement `90a2b6d590`, against pinned
[regalloc2 ION source](https://github.com/bytecodealliance/regalloc2/blob/2fe490bc9dda433f70c54f90f7633ed929f693d9/src/ion/process.rs).

Compatible distinct SSA values form real atomic bundles with exact union ranges,
affinity hints, and common typed spillsets. The allocation queue probes physical
occupancy, evicts lower-weight conflicts, and splits at the obstruction with
cooler loop-boundary choices. Splits retain compatible groups and original
spillsets. Initial-use obstruction has a minimal-piece progress case; it does
not promise that the first piece is immediately free in every case. A canonical
no-use second-chance bundle tries compatible holes after mandatory allocation,
and local split moves use parallel transport.

Audit identified an increment-only spillset split count: termination by shrinking
use sets did not bound repeated long-vector rescans. The accepted correction
caps directed splits at 16 per original spillset and then directly partitions
remaining instruction-sized use clusters. A 400-use/one-register regression
reaches this path. The independent checker accepts the owner's exported actual
bundle, exact eviction, typed spillset, and split-partition witnesses. Their
producer/native log provenance is separate from the mathematical checker.

The shared SSA extraction contains interval construction, assignment, and edge
transport; inspection found no dispatch to another allocation policy. The
prototype's post-destruction bundle approximation is no longer the new kernel.
Factor still lacks regalloc2's complete fixed/pinned/reused-input API and target
register-unit model; those are not implied by this mechanism assessment.

## Decoupled SSA chordal

Reviewed completed kernel `7f040dd1fa` and rematerialization correction
`b24a9fde54`, in the context of
[Braun/Hack spill-before-color allocation](https://pp.ipd.kit.edu/uploads/publikationen/braun09cc.pdf)
and [SSA graph coloring](https://compilers.cs.uni-saarland.de/papers/ssara.pdf).

The new pipeline rewrites source pressure/clobbers into explicit memory homes,
fresh reload definitions, and edge/entry phis before building its register graph.
It then verifies a perfect-elimination certificate and assigns colors; the old
post-color interval-repair engine is absent. Natural-loop membership, rather
than nesting depth alone, now identifies exits into sibling loops. Fixed memory
values remain separate from register vertices.

Independent native x86 evidence covers nine four-register pressure diamonds and
45 arithmetic formula answers. Every case contains actual stores/reload defs;
all exported graphs, conventional PEOs, legal colors, and optimal four-color
bounds pass independent checks. Concrete-body instrumentation observes source
pressure rewriting and certified coloring, with no LS policy entry. The ON
option originally failed to discover recipes before identity leaders and lost
activity counts during numbering; the correction now has a positive native
recipe/code-reduction gate for every allocator.

## Shared correctness and remaining acceptance

The comparison baseline `c84535b24a` is the corrected prototype: snapshot and
operand checker repairs, boundary expiration, and shared derived-phi GC base
provenance. It does not include the new phase API or allocator policies. Native
x86 runs pass 384 fresh object identity pairs across all original backends,
raw/tagged phi forms, and rematerialization OFF/ON. Unchanged `0b52875640` fails
the same native raw-derived-phi check. Exact final prototype/core source hashes
are retained independently of Python harness revisions.

Completed source `1c1f8ea479` likewise passes 384 native x86 moving-object pairs.
The callback/alien-large-return failure discovered in that source was corrected
by `036a178ab5`; native x86 passes the real C ABI fixture with both rematerialization
settings and the final checker. Parent full-compiler acceptance subsequently
passed candidate `29b4551bb3`.

The larger native x86 frozen closure then rejected `29b4551bb3`: greedy created a
transparent resident fragment with no local operand uses, and GC assignment could
not determine its representation while compiling `:SSL=>struct-slot-values`.
Correction `0045c5586f` preserves the original incoming representation in fragment
metadata. The exact native method now passes final checked compilation with both
rematerialization settings. A fresh integrated image and all four full closures
are still required before accepting the corrected candidate. Failed source29
records are retained in `native-x86-64/candidate29-rejected`.

The repaired prototype baseline passes all four full checked closures on both
architectures: 27,289 frozen word objects on x86 and 26,212 on ARM64, with all 26
outputs independently checked. Earlier successful targeted witnesses remain
scoped evidence; they do not override a failing whole-closure acceptance gate.
Final fresh-image checks, the matched two-architecture matrix, and separate
default bootstrap budget assessment remain required before speed claims.
