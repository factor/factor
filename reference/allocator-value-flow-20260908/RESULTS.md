# Value-flow verification and GC regression

The optional final-machine checker is installed by loading
`compiler.cfg.register-allocation.verifier`, then enabled with the existing
`check-allocation?` flag. Default compilation does not load the vocabulary.

Validated on native ARM64 with explicit reloads of every changed vocabulary:

- All existing register-allocation subtree tests passed before the GC repair.
- The final liveness, SSA interference, verifier, and rematerialization
  subtrees passed together, with an explicit empty `test-failures` assertion.
- 32 generated spill/reload placements and 21 generated resolver permutations
  passed; corresponding deliberately corrupted flows were rejected.
- 96 generated executed branch/loop programs matched a separate arithmetic
  oracle across linear scan, greedy, backtracking and chordal.
- ABI slot uses/definitions, loop phi cycles, partial memory overwrites,
  narrowed vector reloads, missing instructions, temporary overlap, invalid
  rematerialization literals, missing/wrong derived mappings, uninitialized
  roots and unrelocated duplicate pointer spills have adversarial fixtures.
- All four allocators preserved identity for 20 newly allocated objects with
  a plain bitcast across GC and another 20 with a nonzero-offset derived
  pointer: 160 executed moving-GC cases.

The final combined test run used the integration runner's parent-driven
foreground policy. It exited 0 in 8.215 seconds; this is validation elapsed
time, not an allocator benchmark. Logs were recorded at
`/tmp/valueflow-strengthened-verification` during this session.

The checker found a shared GC defect while compiling `spectral-norm` with
linear scan: a tagged phi's deleted integer bitcast remained live after GC,
but its base was absent from the final map. The repaired liveness pass retains
original CSSA definitions through cleanup. Local interference now includes
implicit GC-root uses, including the non-vreg `##call-gc` instruction. A
bit-preserving provenance check omits self-derived pairs, which would otherwise
zero a root during the collector's offset calculation.

The standalone `moving-gc.factor` regression also passed on native x86-64
under all four allocators, independently executed by the cross-architecture
validation task. Its earlier draft failed the offset case before explicit
`##call-gc` interference dispatch was added; that failure was retained by that
task alongside the successful rerun.

Passing finite tests is not a proof. The verifier trusts original instruction
semantics, representation selection, and original SSA base discovery; its
README describes the remaining scope boundaries.
