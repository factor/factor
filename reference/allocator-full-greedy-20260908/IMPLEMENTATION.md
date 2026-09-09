# LLVM-style greedy allocation in Factor

Reference revision: LLVM `9851e4f8979b8b57557d03cd98b54f57287a128f`
(main fetched 2026-09-08). This is a port of the allocation mechanisms to
Factor's live intervals and ABI, not a claim that Factor implements every LLVM
target facility.

Primary sources:

* [RegAllocGreedy.cpp](https://github.com/llvm/llvm-project/blob/9851e4f8979b8b57557d03cd98b54f57287a128f/llvm/lib/CodeGen/RegAllocGreedy.cpp)
* [RegAllocEvictionAdvisor.cpp](https://github.com/llvm/llvm-project/blob/9851e4f8979b8b57557d03cd98b54f57287a128f/llvm/lib/CodeGen/RegAllocEvictionAdvisor.cpp)
* [SplitKit.cpp](https://github.com/llvm/llvm-project/blob/9851e4f8979b8b57557d03cd98b54f57287a128f/llvm/lib/CodeGen/SplitKit.cpp)
* [SpillPlacement.cpp](https://github.com/llvm/llvm-project/blob/9851e4f8979b8b57557d03cd98b54f57287a128f/llvm/lib/CodeGen/SpillPlacement.cpp)

## Audit and completion matrix

All code below is in `compiler.cfg.register-allocation.greedy`, unless noted.
The tests exercise state and generated machine flow as well as diagnostics.

| LLVM mechanism | Factor implementation | Behavioral evidence |
| --- | --- | --- |
| Priority advisor / enqueue | Large intervals first, loop-weighted density, stable vreg tie-break; initial assignment tier precedes retry stages | Long sparse interval initially allocated, then displaced by dense interval |
| RS_Assign, RS_Split, RS_Split2, RS_Spill, RS_Done | `interval-progress`, monotone `advance-stage`; initial failure defers; successive region/local/spill stages; terminal minimal products | Stage regression fixture; eviction/split fixture preserves all required uses |
| Eviction cascade and hint-aware cost | `cascade-safe?`, `eviction-cascade`, `evictable-victim?`, lexicographic `candidate-cost`; victims inherit cascade; urgent mandatory uses may break a newer spillable cascade with a cost penalty, but never the same cascade | Equal/younger cascade rejection; actual eviction transfers cascade and queues victim; hinted physical register order; hint-only eviction cannot displace an infinite-weight mandatory interval; actual urgent eviction and the executed 40-constant rematerialization loop |
| Last-chance recoloring | `last-chance-recolor`, recursive `recolor-interval`; depth 5, max 8 interferers, budget 64; fixed choices; full state rollback | Two-move augmenting chain; impossible coloring restores union order, occupancy serials and register fields; insufficient depth fails and rolls back before a deeper search succeeds |
| Interference-directed local splitting | `register-free-windows`, `local-split-plan`, `apply-local-split` select weighted use clusters inside actual physical interference windows, including the post-use spill position | A long interference forces selection of the final four uses, independently of the largest use gap |
| Global region splitting / SpillPlacement | `global-split-plan` constructs a per-register CFG residency network; `greedy.regions:solve-residency` computes a minimum cut; `apply-global-split` assigns resident blocks and sends blocked blocks to local refinement | Hard-interference, transparent-loop, cold-use and exhaustive 32-network minimum-energy tests; `region-lowering-fixture` selects the actual physically free loop, lowers transfers on edges, and passes the original-SSA/final-machine verifier including a zero-iteration bypass |
| Spill products / rematerialization | `memory-region-products` refines blocked blocks; `spill-to-minimal-ranges` is the final stage, using shared spill/rematerialization/edge lowering | Native 32-float pressure also checked against original SSA; libc ABI; loops and allocation/GC tests |
| No alternate allocator escape | Complete `greedy-allocation-with-registers ( cfg registers -- )`; zero fallback count | Full method uses greedy work queue and raises impossible pressure instead of invoking another allocator |

The previous implementation already had an indexed physical-register occupancy
map and cached interval weights. It did **not** have the stage machine, cascade
ordering, hint cost, recoloring, or a CFG spill-placement solver. Giving its
queue an LLVM name would not implement those algorithms.

## Target boundary

Factor currently exposes whole integer and floating-point register banks.
Tagged and integer representations alias the integer bank; scalar/SIMD floating
representations alias the floating bank. The shared post-SSA-destruction live intervals conservatively
encode input/output/temporary interference, clobbers and implicit GC roots.
Their inclusive instruction positions keep surviving copy operands and outputs
separate; this limits realizable copy hints and dying-first-input reuse compared
with LLVM SlotIndex phases. Existing SSA coalescing runs before this allocator.
Migrating its splitting/mandatory-use endpoints to Factor’s new paired phases
is a separate optimization, not claimed by this implementation.
This implementation retains those intervals and the established spill/ABI/GC
lowering. The public kernel accepts a legal reduced bank for independent tests.

LLVM subregister lane masks, register units, target-specific register classes,
callee-saved activation costs, instruction folding, profile-driven frequencies,
ML eviction advisors and target-specific split hooks are not represented by this
Factor IR interface. Static loop depth supplies bounded frequency estimates.
The default allocator remains linear scan; this work changes only explicit
greedy selection.

## Algorithm choices and termination

The Factor region objective is weighted memory-use traffic plus disagreement
costs on actual CFG edges, with hard per-register interference constraints.
LLVM SpillPlacement uses an iterative weighted residency network; Factor solves
its binary, whole-register version by an exact deterministic minimum cut.
This handles transparent blocks and cycles without relying on layout adjacency.
The global solver is limited to 128 live blocks. Larger regions advance to the
same allocator's interference-directed local stage. Recoloring is limited to
depth 5, 8 interferers per candidate, and 64 searched intervals per attempt.
These are search limits, not a fallback to a different allocator.

Region products advance to local refinement, local products advance to spill,
and minimal spill products are terminal. Eviction cascades prevent two peers
from repeatedly displacing each other; split stages never regress. A genuinely
impossible mandatory use reports `greedy-register-pressure` after recoloring.

Per-block resident products retain register locations at entry and exit.
The shared edge resolver emits stores/reloads/copies only where locations change.
The accompanying shared assignment fix expires old products before block-entry
activation. It leaves boundary stores to that resolver, since an overflowing
arithmetic terminator can define the value being spilled. The explicit
`defining-terminator-fixture` checks both outgoing edge stores and original-SSA
value flow. Ordinary within-block spills retain the established insertion path.

Diagnostics include `algorithm="llvm-style-greedy"`, `fallback-count=0`, each
processed stage, assignments/evictions, hint assignments/breaks, global/local
splits, block products, resident blocks, cut cost, and recoloring attempts,
successes, search steps and rollback counts. Tests can inspect plans and full
occupancy state directly; no trace collection is enabled in the allocation loop.

Validation so far is correctness validation on native ARM64 using the matching
integration VM and image with explicit source reloads. No speed claim or ranking
is made for this algorithm before the independent frozen-candidate benchmarks.

## Broader validation

The loaded `compiler.cfg` suite also passes with greedy selected and
`check-allocation?` enabled, including the final original-SSA value-flow hook.
This includes the existing executed 40-constant diamond, loop and explicit-GC
fixtures with rematerialization both off and on. That broader loop initially
exposed the missing urgent-cascade exception; the fix follows the pinned LLVM
DefaultEvictionAdvisor rule and has a focused state-transition regression.
