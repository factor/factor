# Linux ABI work, 2026-09-08

Status: three reproducible defects fixed and verified on native Linux x86-64/glibc with the C++ VM. **The Linux AArch64 completion criteria are not yet met.** No native ARM64 or macOS execution, Clang 18 reduced-type execution, or Zig VM qualification is claimed.

The subsequent [commit review](REVIEW.md) records a fresh-image integration run on a newer source snapshot and the final harness corrections. The original evidence below remains preserved.

The host is an AMD Ryzen 9 7950X3D running glibc 2.43. C fixtures were built separately with GCC 15.2.0 and Clang 21.1.8, without LTO or fast-math. Both compilers produced the results below. Each row has an independent C source, a separately compiled C-only control, and an ordinary compiler-suite regression. The identical Factor test and shared C fixture were used for both images.

| Fix | Independent C source | Baseline exit | C-only exit | Candidate exit |
| --- | --- | ---: | ---: | ---: |
| x86 `uint` conversion retained unspecified high register/stack bits when boxing callback arguments | [ffi_uint_callback.c](../../vm/tests/ffi_uint_callback.c) | 1 | 0 | 0 |
| SysV x86-64 classified an array field as a pointer instead of recursively classifying its elements | [ffi_array_struct.c](../../vm/tests/ffi_array_struct.c) | 1 | 0 | 0 |
| `vm-error-exception-flag?` applied the error decoder to its flag argument | [ffi_fp_status.c](../../vm/tests/ffi_fp_status.c) | 1 | 0 | 0 |

The unsigned callback returned `18446744072414584320` instead of `3000000000` on the GCC baseline. The float-array result was corrupted instead of `{ 11.0 22.0 33.0 }`. The FP regression trapped successfully but its predicate failed with a method-dispatch error. The third fix is an error-predicate correction, not a discovered C++ signal-context defect. No historical ARM64 failure is inferred from these x64 results. Encoded C strings retain pointer classification in the recursive struct implementation; the existing FFI suite covers that case.

[GCC evidence](gcc/summary.json), [Clang evidence](clang-21/summary.json), and [integration results](results.json) record exits and commands. [evidence.tar.gz](evidence.tar.gz), checked by [SHA256SUMS](SHA256SUMS), contains source manifests and patches, image/VM/library hashes, compiler assembly, controls, logs, generated negative controls, and coverage/skip summaries. The baseline and candidate both start from snapshot commit `32b5b3e458204bc12c630e2c2689db162719aebe` plus the recorded patches. The baseline source was preserved in `/tmp/factor-abi-baseline-233db947`; the candidate is `/tmp/factor-abi-candidate-233db947`. Directory names retain the commit observed before the snapshot; the manifest identifies the actual snapshot.

Both VMs were built from the snapshot, and both images were freshly bootstrapped from source. The supplied older image initially lacked `global-value-numbering?`; that diagnostic run is classified as a stale-image failure and excluded from qualification. An initial compiler run also encountered an unwritable shared `/tmp/factor-temp`; the retained successful runs use private `TMPDIR` directories. Intermediate candidate failures are retained separately from the final passing runs.

| Integration check | Result on this host |
| --- | --- |
| Baseline full compiler suite with SSA/allocation verification | Exit 0; 3,253 logged experiments |
| Candidate full compiler suite with SSA/allocation verification | Exit 0; 3,288 logged experiments; zero compiler errors |
| GVN FFI matrix: linear-scan, greedy, backtracking, chordal | All pass with both C compilers; zero test failures/compiler errors |
| Portable general ABI fixtures | 27 Factor cases per allocator and 12 C-only controls per compiler pass |
| Nested callbacks, allocation/compacting GC, synchronous borrowed-pointer lifetime | Pass with both C compilers |
| Nine-argument indirect large returns and C-driven callback returns with GC | Existing suite passes; qualification coverage |
| Native FP status, effective trap-mask check, trapped C division and recovery | Pass; zero-divide trap was effectively enabled |
| VM-owned OS-thread startup | `start_standalone_factor_in_new_thread` runs callback/GC/pointer/FP tests successfully |
| Valid C-backed assertion / wrong assertion / assertion injected into the ordinary allocator suite | Exits 0 / 1 / 1 |
| Required but unavailable half/BF16 fixture | Exit 1 |
| Native ARM64 acceptance gate on x64 | Exit 1 |
| ARM64 GCC and Clang shared fixtures, Clang reduced-type C control, C++ FPSIMD context test | Cross-compile/link only; no execution claim |

The generated wrong assertion and unavailable fixture are **negative controls**, not discovered bugs. Their sources live in evidence output. The production assertion is correct, and the lane restores its original shared library even on failure. Compiler changes are not manufactured to create baseline failures.

The ARM CI job retains its normal, disabled-extension, image-save and restart entry points. It now rebuilds a boot image from source, keeps GCC, adds an explicit Clang 18/compiler-rt lane with independently built fixtures, requires reduced-type availability and execution counts, runs compiler/allocator verification and runtime checks, and uploads evidence with `if: always()`. Linux x86 and both macOS jobs also run the allocator and compiler verification harnesses. These workflow changes have been parsed locally; no GitHub Actions or macOS success is claimed here.

The Linux driver now loads the portable ABI fixture. The reduced-type suite retains its 131,072 raw-result comparisons and adds named-FP/interleaved-integer varargs crossing both register banks and the stack. These reduced-type tests are deliberately unavailable on x64: the C control exits 77 and the optional driver reports zero execution. Only native ARM64 execution with the required capability assertion can qualify them. A host architecture check alone does not establish hardware provenance; record the native runner/hypervisor before acceptance.

Remaining work and exclusions:

- Run native glibc Linux AArch64, including the required Clang 18 lane, optional-extension disablement, image restart and C++ FPSIMD signal-context behavior. Cross-compilation does not satisfy this gate.
- Complete the broader declared ABI inventory: all requested integer extrema/pointer positions, exceptional FP transport, 1–4-member HFA/HVA variants, aggregate alignment/exhaustion combinations, variadic transition combinations, and audited callee-saved-register/stack-alignment sentinels. The 27 portable cases are a concrete subset, not the whole proposed matrix.
- Run the macOS ARM64/x86 shared-code jobs. Only native Linux x86-64 was executed locally.
- Variadic callbacks are rejected by `scan-c-args`, with the existing parser rejection test retained. Foreign-thread calls into an existing VM callback are excluded and were never invoked; runtime enforcement of that exclusion is not qualified. The supported new-VM OS-thread entry API is tested separately.
- No width substitution or ABI claim is made for Linux `long double` or `__int128`; no public mapping was added. Packed/over-aligned aggregates, the complete vector surface, and retained pointers beyond their documented owner lifetime are not newly qualified.
- Zig remains a separate port task. `src/signals.zig` still returns zero from Linux AArch64 `getFPUStatus` and does nothing in `clearFPUStatus`. Those stubs must be implemented and independently qualified before including Zig in a release claim.
- musl, Windows ABI changes, variadic callback implementation, SVE and SME remain outside this qualification.

Reproduce the independent comparisons from the candidate checkout:

```sh
python3 .github/ffi-compare.py \
  --baseline /tmp/factor-abi-baseline-233db947 --baseline-image abi-fresh.image \
  --candidate /tmp/factor-abi-candidate-233db947 --candidate-image abi-candidate-r2.image \
  --cc gcc --out logs/reproduce-gcc
python3 .github/ffi-qualify.py --cc gcc --image abi-candidate-r2.image --out logs/gcc --full
python3 .github/ffi-qualify.py --cc /usr/lib/llvm-21/bin/clang --image abi-candidate-r2.image --out logs/clang
```

On the freshly built native ARM64 CI image, use `--native-arm64`, and add `--require-small --cc clang-18` for the required reduced-type lane. Logs and manifests remain available when a process fails.
