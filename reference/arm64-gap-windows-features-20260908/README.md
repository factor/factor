# Windows ARM64 optional feature detection

Verified 2026-09-08 in isolated worktree based on `3c430ff2fc8d4e658bda985a0e5f412f1836930d`.

## Independent mapping and contract

Microsoft documents `IsProcessorFeaturePresent(DWORD)` returning a nonzero `BOOL` for support, zero for absent features or detection unavailable in the HAL. It is provided by Kernel32.dll. The existing Factor declaration returns an integer, so the mapper explicitly converts zero/nonzero; Factor's truthiness alone would incorrectly accept zero.

| Factor feature | Microsoft constant | ID | First documented OS support |
|---|---|---:|---|
| dotprod | PF_ARM_V82_DP_INSTRUCTIONS_AVAILABLE | 43 | Windows 11 / Server 2022 |
| fp16 | PF_ARM_V82_FP16_INSTRUCTIONS_AVAILABLE | 67 | Windows 11 24H2 / Server 2025 |
| bf16 | PF_ARM_V86_BF16_INSTRUCTIONS_AVAILABLE | 68 | Windows 11 24H2 / Server 2025 |
| i8mm | PF_ARM_V82_I8MM_INSTRUCTIONS_AVAILABLE | 66 | Windows 11 24H2 / Server 2025 |

These are NEON feature IDs. SVE BF16 52 and SVE I8MM 57 are different queries and cannot establish support for the kernels used here. A failed individual query conservatively removes only that feature. No probing opcode, CPU-generation inference, or version-number inference is used.

Sources: [Microsoft API contract and OS availability](https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-isprocessorfeaturepresent), [Microsoft SDK header at pinned commit](https://github.com/microsoft/win32metadata/blob/29896383c51d9dd6a2ea0ec6304d095baca9418c/generation/WinSDK/RecompiledIdlHeaders/um/winnt.h). `sdk-feature-ids.txt` records the independently retrieved header lines and revision.

## Changes and checks

`cpu.arm.64.features` loads the new Windows probe on Windows. The portable mapper accepts an injected query; the Windows-only `kernel32` child supplies the existing FFI function. The `windows-processor-feature` hook's default returns zero, allowing cross-platform loading without a foreign DLL. All four names and the existing startup memo invalidation remain intact.

`windows-tests.factor` asserts literal SDK IDs, all 81 combinations of zero, nonzero, and thrown error across four queries, negative BOOL, the exact query sequence, rejection of unrelated/SVE flags, Windows method registration, native adapter platform isolation, and invocation of the actual registered startup hook. Expected results are derived from independent test profiles, not the production table.

The initial implementation was caught by these checks passing literal constant words instead of numeric IDs; the correction evaluates the constants in the mapping. Its failure log is retained as additional test sensitivity evidence.

`before.factor`/`before.log` were executed before adding the implementation and show the missing Windows method. `dispatch-regression.factor` compares the actual Windows method against those same independent 81 query profiles. Its `-legacy-windows-probe` mode removes the newly introduced Windows method in that isolated process, reproducing the old dispatch to the unchanged `object` method. The baseline matches only the 16 profiles having no present features (65 failures); the new method matches all 81. This is a dispatch-removal differential on macOS, not a native prepatch Windows run.

`save-dispatch.factor` seeds the memo with a synthetic feature and verifies a compiled caller selects its optional branch, then saves an image. `reload-dispatch.factor` runs in a second process, verifies the same compiled caller selects fallback, the synthetic feature disappeared, and detection equals a fresh native probe. This demonstrates real image startup persistence, beyond directly calling the reset hook.

## Reproduction

Run from the worktree root with its own Factor runtime and image:

```sh
./factor -q -no-user-init -run=tools.test cpu.arm.64.features
./factor -q -no-user-init -disable-neon-extensions -run=tools.test cpu.arm.64.features
./factor -q -no-user-init -legacy-windows-probe reference/arm64-gap-windows-features-20260908/dispatch-regression.factor # expected failure: 16 versus 81
./factor -q -no-user-init reference/arm64-gap-windows-features-20260908/dispatch-regression.factor
./factor -q -no-user-init reference/arm64-gap-windows-features-20260908/save-dispatch.factor
./factor -q -no-user-init -i=reference/arm64-gap-windows-features-20260908/dispatch.image reference/arm64-gap-windows-features-20260908/reload-dispatch.factor
```

The feature suites and image persistence checks passed on macOS ARM64, using a cloned local runtime whose `resource:` resolves inside this worktree. Log files capture the runs; the generated image is ignored by Git. The portable suite is reachable through the CI agent's recursive `cpu.arm.64` load/test, including Windows. The persistence commands have been provided to that agent.

## Remaining verification limits

No native Windows runtime was executed. `runtime-environment.txt` records available tools; the installed system QEMU has no discovered Windows installation. Attempting to load the native adapter on macOS was rejected by its `platforms.txt`, as recorded in `adapter-load.log`. Native DLL calls and the Windows image lifecycle need the Windows ARM64 CI runner. All four features now have documented API IDs; older Windows installations remain conservatively fallback-only for queries they do not detect.
