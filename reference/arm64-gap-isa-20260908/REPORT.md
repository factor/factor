# Verified scalar ARM64 selection and baseline assembler additions

Changes:

- A64 `%mul-imm` selects one shifted ADD for positive `2^n + 1` constants (for example 3, 5 and 9), instead of materializing the constant and multiplying. The independent oracle checks n=1..11 and destination/source aliases.
- Multiplication by -1 becomes `##neg` independently of arithmetic-immediate eligibility. Previously A64's unsigned ADD/SUB immediate constraint prevented that generic algebraic simplification.
- New raw integer `##mneg` instruction and `%mneg` hook. A small CFG pass after copy propagation fuses single-use `##mul` followed by `##neg`; DCE removes the old multiplication. It counts uses across every block, preserves independently used products and never matches overflow-checking `##fixnum-mul`. ARM emits MNEG. The architecture fallback emits MUL followed by NEG, swapping commutative inputs when necessary for a two-operand backend's destination alias rule.
- Added 26 assembler words: 18 acquire/release/exclusive single-register accesses, DMB/DSB/ISB/CLREX and four single/double scalar fused-FP operations. See SCOPE.md for precise exclusions and architectural requirements.

Validation on Apple M5 Max, native AArch64 Factor VM, Apple Clang 21.0.0:

| Check | Result |
| --- | --- |
| Snapshot assembler before additions (`before.log`) | Fails: LDAR absent |
| Controlled before codegen (`before-codegen.log`) | 2 expected failures: no `##mneg`, and multiply-by-3 emits 8 bytes instead of 4; runtime arithmetic still passes |
| Independent Clang/ELF oracle (`encodings.log`) | 168 cases, 28 assembler/backend words, 0 mismatches |
| Focused assembler/compiler/native runtime (`targeted.log`) | 323 unit tests and 65 expected-failure tests; 0 failures, 0 compiler errors |
| Value numbering, representations, linear scan and SSA (`regressions-final.log`) | 429 unit tests and 2 expected-failure tests; 0 failures, 0 compiler errors |

The focused checks include real frontend-to-register-allocation `##mneg` selection and removal of the old `##mul`, destination/source aliases, portable fallback instruction count, shared product use in another basic block, wrapped fixnum extrema, preserved bignum overflow behavior, native acquire/release memory and an exclusive increment loop. Scalar fused FP runtime tests cover all four sign variants and a cancellation requiring single rounding.

Instruction and performance evidence:

- ARM MNEG replaces MUL+NEG: 1 instruction/4 bytes instead of 2 instructions/8 bytes. Ordinary multiplication by -1 previously also required constant materialization on A64; the independent algebraic fix removes that additional overhead.
- Multiply by `2^n + 1` uses 1 instruction/4 bytes instead of MOV+MUL (at least 2 instructions/8 bytes).
- `runtime-benchmark.factor` compares interleaved native assembly loops with 10 million dependent multiplies and confirms equal wrapped results. Seven samples: separate MUL+NEG median 12,667,852 ns; MNEG median 9,503,103 ns (25.0% lower). This is a microbenchmark, not a whole-application claim.
- `compiler-benchmark.factor` alternates disabling/enabling only the fusion pass in one process. Nine pairs, each compiling three small CFG workloads 100 times: disabled median 56,265,407 ns; enabled median 55,342,046 ns. Sample variation is larger than the 1.6% difference; no compile-speed improvement or measurable regression is claimed.
- The pass fast-rejects CFGs without negation without constructing use/definition maps. `benchmark.factor`: 10,000 visits to a cached 200-instruction no-negation CFG take 12,750,631 ns, about 1.28 microseconds per visit on this host.

Reproduction from this worktree:

```sh
cp -R /Users/erg/factor/Factor.app .
cp /Users/erg/factor/factor.image isa-test.image
./Factor.app/Contents/MacOS/factor -i=isa-test.image -no-user-init reference/arm64-gap-isa-20260908/prepare-image.factor
python3 reference/arm64-gap-isa-20260908/check-encodings.py
./Factor.app/Contents/MacOS/factor -i=isa-ready.image -no-user-init reference/arm64-gap-isa-20260908/encodings.factor
./Factor.app/Contents/MacOS/factor -i=isa-ready.image -no-user-init reference/arm64-gap-isa-20260908/targeted.factor
./Factor.app/Contents/MacOS/factor -i=isa-ready.image -no-user-init reference/arm64-gap-isa-20260908/regressions.factor
./Factor.app/Contents/MacOS/factor -i=isa-ready.image -no-user-init reference/arm64-gap-isa-20260908/runtime-benchmark.factor
./Factor.app/Contents/MacOS/factor -i=isa-ready.image -no-user-init reference/arm64-gap-isa-20260908/compiler-benchmark.factor
./Factor.app/Contents/MacOS/factor -i=isa-ready.image -no-user-init -e='USING: tools.test ; "reference/arm64-gap-isa-20260908/before-codegen.factor" run-test-file'
```

The copied VM lives inside this worktree, so resource source paths resolve here. `reload.factor` regenerates instruction-derived access, renaming, representation and codegen methods and reloads value-numbering source changes that the original supplied image predates. Initial broader runs exposed that stale-image difference; after reloading the snapshot's existing graph/folding methods, the broader tests pass. Image files and VM binaries are deliberately not committed.

The portable fallback was validated through its ARM execution/codegen path here. A separate x86 VM execution check is delegated to root integration; this report does not claim an x86 runtime result yet. SVE/SME, optional atomics/crypto and unimplemented expression recognition remain explicitly outside this change, as detailed in SCOPE.md.
