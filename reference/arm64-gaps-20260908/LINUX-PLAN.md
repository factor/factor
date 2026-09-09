# Linux ARM64 ABI completion plan

Status: proposed work; no Linux execution is claimed by this document.

Target: qualify the supported Factor C FFI on native, little-endian Linux AArch64 with glibc, starting with the existing Ubuntu ARM64 CI environment. Preserve the verified macOS behavior. Every implementation fix must have an independent failing C regression that passes with the fix.

## 1. Establish a reproducible native baseline

Use a native Linux ARM64 machine or VM backed by ARM64 hardware. QEMU can help reproduce problems, but native execution is the acceptance gate. Record the CPU, kernel, distribution, libc, compiler versions, enabled features, source commit plus dirty patch, and hashes of the VM, image, and fixture library.

Create isolated baseline and candidate workspaces from the same source snapshot. Build the VM and bootstrap an image from that source; do not reuse the macOS image or rely on selectively refreshed definitions. Keep the baseline unchanged while fixing failures in the candidate.

Run the existing normal and disabled-extension suites first. Save output and exit status even when a process fails. Classify each failure as an ABI defect, fixture/toolchain problem, stale build, or unrelated runtime issue before editing the backend.

Required toolchain coverage:

| Lane | Purpose | Required result |
| --- | --- | --- |
| GCC / normal Linux build | Existing supported C types and ordinary runtime compatibility | Native build and general ABI fixtures pass |
| Pinned Clang 18+ with working runtime libraries | Independent compiler comparison and actual half/BF16 execution | Fixture compiles, links, loads, reports support, and executes reduced-type tests |
| Optional musl lane | Establish whether a separate libc claim is justified | Separate results; glibc success does not qualify musl |

Start with baseline instruction-generation flags. A compiler accepting a reduced type does not prove that its generated helper calls link or that its instructions run on the test CPU. Verify both before using its output as an oracle. Clang documents target-dependent support and emulation for these types. [Clang floating-point extensions](https://clang.llvm.org/docs/LanguageExtensions.html#half-precision-floating-point)

Deliverable: native baseline logs and a source/runtime/toolchain manifest.

## 2. Make Linux ABI coverage real

Two current gates prevent a green Linux run from proving the new ABI work:

- `vm/ffi_test.c` includes `vm/ffi_test_arm64.c` only on Apple ARM64. The Factor driver `basis/compiler/tests/alien-arm64-abi.factor` is also macOS-only.
- `vm/ffi_test_small.h` enables its scalar fixtures only for AArch64 Clang 18+. A normal GCC run reports them unavailable and skips them.

Extract portable C signatures and computations from the Apple fixture, retaining platform-specific assembly and expectations separately. Add a Linux driver and nested case file, or extend the existing driver to select explicit platform cases. Resolve the normal Linux `.so` through the existing library mechanism. Keep unsupported declarations behind conditional file loading; the earlier false-platform parsing regression must remain covered.

Add machine-readable coverage reporting: fixtures available, cases executed, skipped groups, test failures, and compiler errors. In the required Clang lane, unavailable half/BF16 fixtures or zero executed cases must fail the job. An optional toolchain may report an explicit skip, but that lane cannot satisfy reduced-type qualification.

Deliverable: Linux actually executes both general and reduced-type C fixtures, with a negative control proving a missing fixture cannot produce a qualifying green job.

## 3. Verify Linux argument and result assignment

Use C callees, C callers invoking Factor callbacks, and a C-only control executable built from the same signatures. Compile general fixtures independently with GCC and Clang, without cross-boundary LTO or fast-math. Expected numeric results and layouts must come from C computations, `sizeof`/alignment/offset probes, and compiler assembly—not Factor's allocation helpers.

The Linux tests must exercise the AAPCS64 rules explicitly. Half/single scalar overflow arguments occupy eight-byte slots; partially exhausted aggregate register banks and alignment need separate cases. Variadic C callees can consume arguments from general-register saves, FP-register saves, and the outgoing stack. The compiler-generated `va_arg` implementation should be the oracle for those transitions. [AAPCS64 parameter passing and variable argument lists](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst)

| Area | Required cases |
| --- | --- |
| Integer and pointer parameters | Signed/unsigned narrow values, extrema, null/non-null pointers, last register and first two stack arguments; use explicit signedness rather than plain C `char` |
| FP parameters | Float/double, independent integer/FP register exhaustion, mixed ordering, spill alignment, signed zero and exceptional values |
| Aggregates | Ordinary structs below/at/above the register-return boundary; nested structs and arrays; one-to-four-member HFAs/HVAs; aggregate just fitting or exceeding remaining registers; nonhomogeneous controls |
| Results | Scalar, register aggregate and indirect large return; direct and indirect calls; C-driven callback returns; poison unspecified register bits so accidental zeroes cannot hide a defect |
| Variadic calls | Ordinary C promotions, mixed integer/FP arguments, named arguments exhausting neither/one/both register banks, named stack arguments, multiple unnamed spills, aggregate varargs, and indirect variadic calls |
| Calling-state preservation | Stack alignment and audited callee-saved register sentinels across calls and callbacks; stress register pressure so the checks cover real spills |

Inventory Linux-specific wide types such as `long double` and `__int128` against the public Factor C-type surface. For each, either verify the advertised mapping and calling convention or document/reject the unsupported signature. Do not silently use a different-width type.

Deliverable: a supported-signature matrix with native results for both call directions and both C compilers where applicable.

## 4. Qualify scalar half/BF16 separately

Run `basis/compiler/tests/alien-small-floats.factor` with the capability assertion enabled. Retain the existing 131,072 raw C-result checks across both formats, rounding boundaries, mixed-format HFA, poisoned upper result bits, ten-argument spills, and callback coverage.

Add Linux-specific variadic tests crossing the FP-register-to-stack boundary, including named FP arguments and interleaved integer values. Use explicit `_Float16` and `__bf16` declarations and compiler-generated `va_arg`; do not apply Darwin's double-promotion rule to Linux. Confirm the selected compiler's concrete ABI with saved assembly and native C-only controls. Clang distinguishes `_Float16` from the promoted `__fp16` extension. [Clang type and variadic semantics](https://clang.llvm.org/docs/LanguageExtensions.html#half-precision-floating-point)

Separate bridge behavior from C arithmetic: Factor's conversion policy and NaN canonicalization are already documented, while arithmetic inside C may depend on compiler settings and the FP environment. Use raw-bit identities for transport tests and explicit rounding controls for arithmetic comparisons.

Verify the Factor bridge with optional extensions disabled. Also inspect the C fixture's instructions: Factor's disable flag does not disable instructions independently generated by Clang. Use an appropriate baseline CPU or generated code that does not require unavailable extensions.

Deliverable: genuine native reduced-type coverage, plus explicit unsupported-toolchain outcomes.

## 5. Prove fixes and runtime integration

For every defect, preserve the smallest independent C reproducer and run identical tests against baseline and candidate. Record baseline failure, passing C-only control, candidate success, process exit codes, and source hashes. Keep the permanent test in the ordinary suite.

If a case already passes on the baseline, record it as qualification coverage. Do not manufacture a historical failure. An intentional wrong-offset or missing-capability mutation can demonstrate test sensitivity, but must be labeled as a negative control rather than a discovered bug.

Exercise nested callbacks, callback allocation and GC, large returns under pressure, pointer lifetime, and the runtime's supported thread-entry behavior. Run the variadic callback and native `va_list` suites, including copying, forwarding, and expired-cursor rejection. Foreign-thread entry must follow the existing runtime's supported entry contract.

Run the full compiler suite with SSA and allocation verification. Repeat the FFI matrix with global value numbering enabled across linear-scan, greedy, backtracking, and chordal allocators, using `final-allocator-ffi.factor` in this directory as the starting harness. Re-run macOS ARM64 and x86 shared-code regressions for changes to parameter metadata, boxing, renaming, or common compiler logic.

Include native FP exception/status and signal-recovery tests around supported call boundaries. Check the effective trap mask before claiming trap coverage. The C++ Linux implementation reads FPSIMD context records in `vm/os-linux-arm.64.hpp`; test behavior rather than assuming its context traversal is sufficient.

Keep Zig VM qualification explicit. In `src/signals.zig`, Linux AArch64 `getFPUStatus` currently returns zero and `clearFPUStatus` does nothing. Implement context-record access and native fail/pass tests if Zig is included in the release claim; those stubs are then completion blockers. A successful C++ VM run cannot qualify the Zig runtime. Otherwise report Zig as a separate remaining port task.

Deliverable: baseline/candidate evidence for each fix and a clean native compiler/runtime integration run.

## 6. Make CI enforce the result

Extend the existing `build-linux-arm` job in `.github/workflows/build.yml`; it already invokes `.github/arm64-tests.factor` normally and with optional extensions disabled, followed by saved-image feature-cache checks.

Add or split out the required Clang fixture lane. Build its fixture in a separate output directory or force a clean rebuild when changing compilers; a GCC-built object must not be reused just because Make considers it current. Keep the normal GCC lane.

Retain these entry points on a freshly built image:

```sh
./factor -no-user-init -no-monitors .github/arm64-tests.factor
./factor -no-user-init -no-monitors -disable-neon-extensions .github/arm64-tests.factor
./factor -no-user-init -no-monitors .github/arm64-feature-cache-save.factor
./factor -i=arm64-feature-cache.image -no-user-init -no-monitors .github/arm64-feature-cache-check.factor
```

Add Linux ABI cases to the shared runner and require coverage assertions in the qualifying lane. Keep compiler errors fatal. Inject one failing C-backed assertion and one unavailable-fixture control to prove CI exits nonzero; remove only the injected faults afterward. Upload manifests, compiler assembly, logs, exit codes, and skip/coverage summaries even on failure.

## Completion criteria

- Native glibc Linux AArch64 executes the declared general ABI matrix and the mandatory Clang half/BF16 matrix; no required group is skipped.
- General fixtures agree with GCC and Clang C controls. Every implementation fix has reproducible baseline failure and candidate success.
- Normal and disabled-extension suites, image restart, full compiler verification, allocator/FFI matrix, and applicable runtime boundary checks pass with zero compiler errors.
- Shared changes preserve macOS ARM64 and x86 behavior.
- CI proves failure propagation and fixture execution; evidence identifies the exact source, binary, image, and toolchain.
- Unsupported signatures and platform/runtime exclusions are enumerated. The completion claim is Linux AArch64/glibc for that supported surface, not all C types, libcs, or runtimes.

Work in this order. Once the native baseline and fixture split exist, general ABI, reduced types, and runtime checks can proceed independently; combine their results before the final CI acceptance run. Variadic calls, callbacks, and native `va_list` interoperability now have shared ARM64 regression suites and per-compiler CI checks. Native Linux qualification must include them. Windows platform qualification and SVE/SME remain separate work.
