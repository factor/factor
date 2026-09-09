# Compiler flag safety matrix

Base: `ad0fc337de`. These scripts change no production implementation or defaults.
Both enumerate all four allocators × GVN off/on × rematerialization off/on,
with SSA, allocation, and final symbolic value checking enabled. Backtracking
loop spilling is enabled consistently. These are correctness runs, not timings.

`callback-matrix.factor` executes the actual C ABI fixture under every setting,
explicitly recompiles its entire vocabulary, then executes the large-return,
compact-GC callback and nested callback cases again. ARM passes all 16 settings
with an empty test-failure vector. The native test library must match the VM
and be available at the resource root (`libfactor-ffi-test.dylib` on macOS,
`libfactor-ffi-test.so` on Linux).

`moving-gc.factor` creates fresh SSA graphs for tagged and raw derived-pointer
phis. It explicitly runs checked value numbering before inserting the synthetic
collector call, matching production optimizer-before-GC-check ordering. It does
not apply GVN to an already finalized GC graph. After allocation it asserts one
collector and nonempty derived-pointer GC metadata, then executes both paths
with 12 independently checked heap objects. ARM passes all 16 settings, 32
freshly generated native words and 768 native answers. The synthetic graph gate
complements the ordinary source callback pipeline; it is not a claim of complete
source-compiler coverage.

Run each script in a fresh process from the worktree with matching assets:

```
ABS_VM -i=ABS_IMAGE -no-user-init -resource-path=ABS_WORKTREE reference/compiler-flags-safety-20260909/callback-matrix.factor
ABS_VM -i=ABS_IMAGE -no-user-init -resource-path=ABS_WORKTREE reference/compiler-flags-safety-20260909/moving-gc.factor
```

Both scripts call `refresh-all`. The retained ARM environment files contain
exact commands and VM/image hashes; `scripts.json` hashes the final scripts.
`arm64/callback` and `arm64/moving` retain successful raw runs. The callback
script is unchanged since its recorded source commit. Two intermediate GC
insertion harness errors (setter stack order and constructing an array rather
than the instruction vector) are retained as `harness-failure-*`; neither is a
production compiler failure. The unasserted moving run is retained separately;
the final run includes collector/derived-root coverage assertions.

This gate establishes safety for these fixtures, not optimization benefit.
GVN/rematerialization performance and emitted-code benefits require the separate
matched feature matrix. Native x86 reproduction is handed to the measurement
owner; no x86 result is claimed here.
