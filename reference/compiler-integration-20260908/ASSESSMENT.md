# Compiler and allocator assessment

The implementation now covers serious contemporary allocator families, but does not yet match the engineering or demonstrated performance of LLVM's greedy allocator or regalloc2. Algorithm family is not evidence of state-of-the-art performance. Keep linear scan as the default and global value numbering opt-in.

## What the measurements say

Native ARM64 corpus, 13 word bodies / 19 generated procedures, identical loaded implementations:

| Allocator | Code bytes | Spills | Reloads | Copies | Interpretation |
|---|---:|---:|---:|---:|---|
| Linear scan | 24,384 | 42 | 42 | 17 | Best demonstrated default tradeoff |
| LLVM-inspired greedy | 24,384 | 42 | 42 | 17 | Most promising next contender |
| regalloc2-inspired backtracking | 24,384 | 42 | 42 | 17 | Useful bundle experiment, no broad quality win |
| SSA chordal | 25,584 | 60 | 60 | 155 | 4.92% more code, 42.86% more spill pairs, much more copying |

Greedy and backtracking reduce the 32-live-float example from 12 spill/reload pairs to 11 and 848 to 832 bytes. Greedy matches the 40-live-integer baseline (24 pairs / 560 bytes), while backtracking and chordal need 25 / 576. These constructed examples establish local quality differences; they do not establish application speedups.

GVN similarly has a useful constructed example (96 to 80 ARM64 bytes), but its 13-word corpus had unchanged code size and +2.50% compiler retired instructions. It remains opt-in. The floating-point and machine-integer folding correctness fixes are independent of that option.

The raw observations and harnesses are in `reference/compiler-allocator-20260908` and `reference/compiler-gvn-20260908`. Their original measurements predate this integration with later master-candidate changes. Revalidation of the combined source is recorded separately here.

## Gap to production implementations

Our linear scan already handles holes, splitting, coalescing and next-use spilling. Its age does not imply that replacing it will improve a JIT's overall tradeoff.

Our greedy has real eviction/requeue, loop-depth-weighted costs and split choices at loop transitions. LLVM's implementation also has frequency-based region costs, staged allocation, register hints/costs and bounded recoloring. LLVM uses specialized interference and spill-placement infrastructure. [LLVM greedy implementation](https://llvm.org/doxygen/RegAllocGreedy_8cpp_source.html)

Our backtracking bundles disjoint fragments sharing a coalesced SSA leader. regalloc2 goes further with operand-constraint-aware bundles, register hints, second-chance spill bundles, indexed occupancy and spill-slot reuse. Our whole-vector conflict queries and median-use splits are simpler. [regalloc2 ION design](https://github.com/bytecodealliance/regalloc2/blob/main/doc/ION.md)

Our chordal allocator certifies the graph it actually colors and preserves SSA through phi lowering. Optimal coloring of an ideal uniform-register SSA graph does not mean optimal spill placement, coalescing, ABI handling or code quality. We use shared interval repair, not a complete implementation of Hack's pressure reduction and register targeting. [Hack's thesis](https://publikationen.bibliothek.kit.edu/1000007166/6532)

## Recommended next work, in order

1. **Check final value flow and fuzz it.** Current checkers establish valid intervals, noninterference, required-use preservation and SSA invariants. They do not establish that each physical move/reload/ABI slot has the correct value. Add symbolic dataflow checking after allocation and edge resolution, then generated SSA/phi/call/parallel-copy tests with shrinking. Preserve GC-specific relocation tests. This directly addresses the kinds of defects exposed during these experiments. [regalloc2 symbolic checker](https://github.com/bytecodealliance/regalloc2/blob/main/src/checker.rs)
2. **Build a wider speed and quality gate.** Use ARM64 and x86-64, cold compiler throughput, warmed application execution, larger procedures, pressure-heavy loops, SIMD, FFI and GC. Validate with checks on, time with them off. Alternate allocator order in fresh processes; record code size and executed spill traffic as well as wall time. Do not choose a default from these two pressure examples.
3. **Improve the greedy core and shared cost model.** Cache range sizes/weights and index per-register interference. Cost proposed splits using block/edge frequency estimates, copies, spills/reloads and code size; add persistent register preferences. Use the measurements to decide whether each sophistication pays for its compile-time cost.
4. **Add conservative rematerialization and spill cleanup.** Start with cheap integer constants: recompute instead of storing and reloading when target cost justifies it. Later consider safe address expressions, preserving GC root semantics. Reuse compatible nonoverlapping spill slots, eliminate redundant reloads, and use target memory operands where legal. LLVM integrates rematerializability into weights and its spiller. [Spill weights](https://llvm.org/doxygen/CalcSpillWeights_8cpp_source.html), [LLVM spiller](https://llvm.org/doxygen/InlineSpiller_8cpp_source.html)
5. **Improve chordal coalescing and spill decisions.** Its 155 versus 17 copies are an immediate deficit. Add costed affinity/recoloring and pressure reduction while keeping the graph certificate's meaning explicit. Faster MCS alone cannot repair poor generated code.
6. **Make GVN pay for itself.** Profile fixed-point and availability costs; broaden redundancy opportunities only with correct alias/effect and floating-point semantics. Track register-pressure effects, since extending lifetimes can undo an apparent optimizer win. Keep the existing local rewrite layer shared.

A fifth algorithm family, PBQP, or ML-guided eviction is not the first missing piece. The current contenders provide enough choices to expose the important quality and throughput tradeoffs. Improve them against executable evidence before adding another selector option.
