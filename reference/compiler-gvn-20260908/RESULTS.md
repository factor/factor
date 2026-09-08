# Compiler GVN and folding worktree

Branch: `compiler-gvn`, based on `57f9c97a4f`. The allocator work is independent in `../compiler-allocator`.

## Changes

- `69124d4433`: move exact integer-to-float folding into the existing CFG folder; preserve target integer wrapping and runtime SIMD narrowing semantics. Remove the separate tree float-conversion pass.
- `d884c27a6e`: verify SSA definitions, phi edges and dominance after the relevant passes, enabled with `check-ssa? on`.
- `e311c04c1a`: integrate global numbering with the existing local rewrite rules. Fix phi comparison to respect predecessor/value associations. Replace the experimental GVN rule copies with a compatibility entry point.

Global reuse remains opt-in (`global-value-numbering? on` while compiling). This is a deliberate performance-gate decision: the implementation is useful in a cross-branch example, but the representative corpus does not yet justify enabling it by default.

## Compiler measurements

`measure-bodies.factor` compiles each word body through the frontend, production CFG optimizer, finalization and code generation, without installing code. It warms the corpus and collects garbage before each measured compilation. CPU time and retired instructions are measured separately from the per-pass snapshots. Five fresh-process pairs alternate local/global order. Raw final samples are `matching-vm-{local,global}-{1..5}.jsonl`. Earlier samples are exploratory and are superseded by these final samples.

Sum of per-word medians over 13 words:

| Metric | Local | Global | Change |
|---|---:|---:|---:|
| Retired instructions | 3,926,567,080 | 4,024,658,365 | +2.50% |
| Thread CPU seconds | 0.26245 | 0.29155 | +11.09% |

The machine had other work running, including bootstrap validation; CPU timing is less reliable than instruction counts. These final measurements use the VM rebuilt from this worktree. All 13 generated code sizes are unchanged. The typed bitwise example in `example.factor` goes from 96 to 80 ARM64 code bytes. That is a constructed example, not evidence of a broad application speedup.

The corpus includes sequence mismatch, hashtable rehash, CFG traversal, tree def-use, frame building, linear scan, propagation, tree building, code generation, spectral norm, nbody, fannkuch and binary trees. Before literal-load elimination was excluded, spectral norm grew by 32 bytes. The final implementation keeps literal loads local while still numbering their values.

The measurement vocabulary is pinned from `effb512aa1` in `metrics-root/` so allocator experiments cannot change the GVN measurement pipeline. Run from this worktree:

```sh
./factor -q -no-user-init -i="$PWD/factor.image" reference/compiler-gvn-20260908/measure-bodies.factor local
./factor -q -no-user-init -i="$PWD/factor.image" reference/compiler-gvn-20260908/measure-bodies.factor global
./factor -q -no-user-init -i="$PWD/factor.image" reference/compiler-gvn-20260908/example.factor
```

## Validation

- Compiler suite passes with SSA checks enabled in both local and global modes; see `matching-vm-compiler-local-tests.log` and `matching-vm-compiler-global-tests.log`.
- Regression coverage includes CFG diamonds and loops, phi-edge associations, call barriers, literal lifetime preservation, actual execution, wrapping arithmetic, runtime rounding modes and inexact exception flags.
- Help lint passes for the checker and value-numbering vocabularies.
- Fresh ARM64 bootstrap with the VM built from this worktree passed in 155.66 seconds; see `stage1.log`, `bootstrap.log`, and `validation-times.txt`.
- Fresh-image `load-all` with global numbering enabled passed on the rebuilt VM: 3,388 vocabularies and zero compiler errors in 737.17 seconds; see `load-all.log`.
- Full suite on that loaded image, with global numbering enabled: passed, 1,252 test-file executions, zero remaining test failures and zero compiler errors (`test-all.log`). Elapsed time was 4,868.97 seconds on the contended host; this is validation duration, not a compiler performance measurement. Long deployment tests were included.

Validation uses the C++ VM built from this worktree, its standard macOS app bundle, and absolute image paths. Earlier runs with the copied executable or relative image paths are superseded and archived in `exploratory/`. The copied executable lacked floating-point primitives present in this source revision; rebuilding the VM resolved those failures without compiler changes.

Final measurement samples, pinned tooling and a compact `validation-summary.json` are versioned. Verbose validation and exploratory logs remain available locally.
