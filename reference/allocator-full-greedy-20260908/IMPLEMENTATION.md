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
Rows marked pending are explicit implementation work remaining in this branch.

| LLVM mechanism | Factor implementation | Behavioral evidence |
| --- | --- | --- |
| Priority advisor / enqueue | Large intervals first, loop-weighted density, stable vreg tie-break; initial assignment tier precedes retry stages | Long sparse interval initially allocated, then displaced by dense interval |
| RS_Assign, RS_Split, RS_Split2, RS_Spill, RS_Done | `interval-progress`, monotone `advance-stage`; initial failure defers; successive region/local/spill stages; terminal minimal products | Stage regression fixture; eviction/split fixture preserves all required uses |
| Eviction cascade and hint-aware cost | `cascade-safe?`, `eviction-cascade`, `evictable-victim?`, lexicographic `candidate-cost`; victims inherit cascade | Equal/younger cascade rejection; hinted physical register order |
| Last-chance recoloring | `last-chance-recolor`, recursive `recolor-interval`; depth 5, max 8 interferers, budget 64; fixed choices; full state rollback | Two-move augmenting chain; impossible coloring restores union order, occupancy serials and register fields |
| Interference-directed local splitting | Pending replacement of widest-gap heuristic | Pending |
| Global region splitting / SpillPlacement | Pending replacement of linear loop-boundary heuristic with CFG residency network and edge lowering | Pending |
| Spill products / rematerialization | `spill-to-minimal-ranges` and shared spill, rematerialization, assignment and edge resolution | Native 32-float pressure; libc ABI; loops and allocation/GC tests |
| No alternate allocator escape | Complete `greedy-allocation-with-registers ( cfg registers -- )`; zero fallback count | Full method uses greedy work queue and raises impossible pressure instead of invoking another allocator |

The previous implementation already had an indexed physical-register occupancy
map and cached interval weights. It did **not** have the stage machine, cascade
ordering, hint cost, recoloring, or a CFG spill-placement solver. Giving its
queue an LLVM name would not implement those algorithms.

## Target boundary

Factor currently exposes whole integer and floating-point register banks.
Tagged and integer representations alias the integer bank; scalar/SIMD floating
representations alias the floating bank. The shared live intervals conservatively
encode input/output/temporary interference, clobbers and implicit GC roots.
This implementation retains those intervals and the established spill/ABI/GC
lowering. The public kernel accepts a legal reduced bank for independent tests.

LLVM subregister lane masks, register units, target-specific register classes,
callee-saved activation costs, instruction folding, profile-driven frequencies,
ML eviction advisors and target-specific split hooks are not represented by this
Factor IR interface. Static loop depth supplies bounded frequency estimates.
The default allocator remains linear scan; this work changes only explicit
greedy selection.
