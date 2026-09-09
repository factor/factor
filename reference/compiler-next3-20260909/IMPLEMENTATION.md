# Compiler follow-up worktrees

All changes start from master-candidate `8780b3c0908ba06be2720c5ac0949e3c68b871e4`.
Production defaults remain linear scan, GVN off, rematerialization off, and all
four new policies off. These are bounded implementations with independent
correctness witnesses; none is a claim of a complete LLVM-equivalent optimizer.

| Worktree | Implementation | Opt-in flag | Current limitation |
| --- | --- | --- | --- |
| compiler-next3-loops | Canonical productive preheaders and safe integer LICM | `compiler.cfg.loop-optimization:loop-optimization?` | Rejects loops containing calls/GC/allocation; no induction or load hoisting |
| compiler-next3-representations | Price shared conversions once per original value/representation/block | `compiler.cfg.representations.selection:conversion-aware-representation-costs?` | Existing fixed cost and loop-depth weights remain |
| compiler-next3-memory | Forward must-availability of managed constant-slot loads across blocks | `compiler.cfg.memory-optimization:memory-optimization?` | All writes/calls/GC invalidate facts; no memory phis or store deletion |
| compiler-next3-vectorization | Pack profitable independent raw integer expression trees into two SIMD lanes | `compiler.cfg.slp:automatic-slp?` | Straight-line SLP, no floating-point or loop vectorization |

`compiler-next3-integration` assembles and checks the four changes. The separate
`compiler-next3-native` worktree owns native x86 measurements; ARM uses the
integration worktree. Original worktrees and commits are retained.

The SSA order is construction, existing alias analysis and value numbering,
copy propagation, optional memory reuse, optional LICM, optional integer SLP,
existing multiply-negate fusion and dead-code elimination. Representation
selection, GC insertion, and register allocation follow. No pass is moved past
GC insertion, and no verifier contract is weakened.

Independent review caught and corrected unsafe assumptions in the experiments:
floating-point SLP can change enabled-trap behavior; configurable C unboxing
helpers require a memory barrier; raw derived-pointer arithmetic needs its GC
base provenance preserved. Targeted native oracles are required in addition to
the allocation verifier, whose snapshot occurs after these optimizations.

The standalone evidence directories document exact inputs, supported behavior,
limitations and failed development attempts:

- `../compiler-next3-loops-20260909/README.md`
- `../compiler-next3-representations-20260909/README.md`
- `../compiler-next3-memory-20260909/README.md`
- `../compiler-next3-vectorization-20260909/README.md`

The benchmark harness compares each feature OFF/ON with one prepared candidate
image and identical compilation roots. It retains existing 26 runtime workloads
and 12 metric targets, adding four explicitly labeled witnesses. Measurements
must distinguish static transformation counts, emitted code, allocation bytes,
retired instructions and CPU time. A smaller kernel does not establish a speedup;
a targeted win does not establish a broad corpus gain.
