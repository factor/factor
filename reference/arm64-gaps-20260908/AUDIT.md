# ARM64 port work — verification record

The six workstreams were developed in isolated Astra agent worktrees and combined without committing or replacing the original working tree. Initial baseline: `3c430ff2fc`. Concurrent allocator/GVN work was subsequently preserved via snapshot `5c67055ef9`; multiply-negate runs as a checked SSA pass after copy propagation.

| Workstream | Change | Fail-before / pass-after evidence |
| --- | --- | --- |
| macOS ARM64 FFI | Natural stack packing, explicit named-argument boundary, default variadic promotions, indirect variadic calls, grouped aggregates and array HFAs | Same independent C oracle: 25 baseline failures and 2 controls; all 27 pass after. C-only controls: 11 pass. Existing FFI/parser regressions: 243 pass. |
| Native ARM64 CI | Shared Linux/macOS/Windows suites with optional extensions enabled and disabled; permanent C fixtures; saved-image CPU feature reset | Native runner exits 0; injected failing test exits 1 with exactly that failure. Deleting startup reset makes saved-image check fail; working reset passes. Workflow lint passes. |
| SIMD lowering | Direct signed/unsigned 64-bit min/max; wrapping binary32 integer conversion | Three missing-lowering checks fail before; 116 checks pass after, including 18,432 raw binary32 cases. Verified conversion loop median 25.893 to 6.225 ms per million iterations. Min/max removes a move but shows no meaningful timing gain. |
| Windows CPU features | Documented Kernel32 feature IDs for DotProd, FP16, BF16 and I8MM | Legacy dispatch matches 16/81 injected profiles; new probe matches all 81, including absence and query errors. Saved-image restart and platform isolation pass. Native Windows remains unexecuted. |
| Baseline ISA/compiler | MNEG selection, shifted ADD for multiply by 2^n+1, 26 atomic-access/barrier/scalar fused-FP assembler words | Two missing-codegen failures before; 168 independently assembled Clang cases match. Focused 323 unit/65 negative checks and compiler regression suites pass. x86 executes the portable MNEG fallback correctly. |
| Scalar half/BF16 FFI | Numeric scalar calls, returns, callbacks, register/stack assignment, mixed-format HFAs and quantized Darwin varargs | Original storage-only type fails scalar C-call compilation. After: 24 scalar cases and every 16-bit C result pattern for both formats (131,072 total); broader 433 checks pass. |

## Combined validation

- Fresh native VM and normal FFI library built in the integration worktree.
- All six source sets refreshed into one image with zero compiler errors.
- First combined native normal and disabled-extension runs: exit 0, 35,005 log lines each, including permanent ABI and reduced-float fixtures.
- x86/Rosetta baseline FFI and after ABI/MNEG changes: zero test failures and compiler errors. Final shared half/BF16 type/storage changes: exit 0; unsupported scalar fixture skips explicitly.
- Saved-image feature-cache save/restart: both exit 0. Deliberately removed startup reset: exit 1.
- Final full compiler suite after concurrent allocator/GVN integration, with SSA and allocation checks enabled: **3,078 unit checks, zero failures, zero compiler errors, exit 0** (`verified-compiler.log`). The first attempt found three stale copied-image helper definitions; reloading CFG builder and SIMD propagation/intrinsics from the unchanged source resolved all three.
- Global value numbering plus each of linear-scan, greedy, backtracking and chordal allocation: **816 unit checks, zero failures, zero compiler errors, exit 0** across MNEG and C FFI fixtures (`final-allocator-ffi.log`).
- Final normal and disabled-extension suites, including the Windows scalar-varargs guard: **both exit 0**, 35,085 lines each (`verified-normal.log`, `verified-portable.log`). All final code was exercised; test failures and compiler errors are both zero.

## Semantic and platform limits

The binary32 integer-only SIMD conversion preserves numeric lane results, including truncation and modulo wrapping. It raises no floating-point flags or traps; the prior scalar fallback can raise invalid/inexact and trap. This is documented in `basis/cpu/arm/64/SIMD.md`, measured in `fp-env.log`, and covered by permanent tests, including preservation of existing flags. Numeric compatibility is not floating-environment equivalence.

Native execution here covers macOS ARM64 and x86/Rosetta. Linux has compiler ABI cross-checks; Windows probing has exhaustive injected tests and documented API mappings. Neither is claimed as native platform validation. CI now runs native coverage on all three ARM64 platforms. A Windows Clang oracle confirms fixed half/BF16 FP-register signatures but different integer-register assignment for variadic signatures. Windows ARM64 variadic signatures containing scalar half/BF16 are therefore explicitly rejected, including named parameters; implementing those remains a gap. Two guard regressions fail with prior unchecked behavior and pass with the rejection.

The assembler additions are bounded baseline A64 support. SVE/SVE2, SME, LSE/RCpc atomics, optional crypto/CRC families, and dedicated rotate/byte-reverse/scalar-FMA compiler IR remain separate work; see the ISA scope report. This work does not advertise those extensions as implemented.

## Detailed evidence

- [ABI](../arm64-gap-abi-20260908/README.md)
- [CI](../arm64-gap-ci-20260908/README.md)
- [SIMD](../arm64-gap-simd-20260908/README.md)
- [Windows feature detection](../arm64-gap-windows-features-20260908/README.md)
- [ISA](../arm64-gap-isa-20260908/REPORT.md) and [remaining scope](../arm64-gap-isa-20260908/SCOPE.md)
- [Reduced-precision scalar FFI](../arm64-gap-reduced-ffi-20260908/README.md)

## Delivery

Initially applied to `/Users/erg/factor` without making a main-tree commit. The source, tests, audit evidence, and Linux plan are now committed on `master-candidate`; see Git history for the delivery commit. All 181 delivered source/evidence files exactly match the verified integration worktree. SHA-256 comparison found no changes to the other 12,187 tracked files; the staging index is unchanged. See `delivery-verification.json`. Existing ARM64 edits and concurrent allocator/GVN work are preserved.

The verified VM and `verified.image` remain in `/Users/erg/factor.worktrees/arm64-gaps-integration`; the main working tree's existing runtime/image were not replaced. Source tests should be run against a freshly rebuilt/bootstrap image or using the recorded refresh scripts. Exact VM/FFI build, refresh, test and exit logs are retained here. Raw test logs preserve their original output, including expected failure-control text and whitespace.
