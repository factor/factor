# Rebased Linux integration validation — 2026-09-08

Source: `2bff152061ab859d9b75aad774783b4b0e37cf67`, the clean linear rebase onto agent1/master-candidate `2e42c46e631340a4a95bd6ce9f8e61f9aa624bf6`, plus the narrow fixes recorded below. The fetched eight commits had explicitly not been tested before this integration pass.

All runs used a new isolated agent1 tree at `/home/erg/factor-rebase-validation-20260908.A0tnYX`; neither its main checkout nor another agent's worktree was changed. Source was copied from a separate local worktree. Native Linux is x86_64, GCC 15.2.0; the native VM/image pair was copied from `/tmp/factor-abi-current-review`. ARM64 uses the previously bootstrapped C++ VM/current.image under QEMU 10.2.1 with `/usr/aarch64-linux-gnu`; no bootstrap was repeated. Local Zig is 0.16.0.

## Corrections demonstrated by tests

- `finder-before.log`: importing both `endian` and `alien.data` makes the incoming unqualified `little-endian?` ambiguous. The former is the generated predicate for the endian singleton; the latter detects native byte order. Qualifying all four uses as `alien.data:little-endian?` resolves the parser error.
- `linux-native-errno-before.log`: incoming `unsupported-ioctl?` compared the numeric errno with an array of constant *words*, so EINVAL returned false. Evaluating the four errno constants before constructing the array fixes it. The regression now checks EINVAL, ENOTTY, ENOSYS and EOPNOTSUPP, alongside unrelated EBADF/EACCES and a non-error object. Other incoming array literals were reviewed; the event-mask table intentionally stores alien enum words and converts them through `enum>number`.
- Both fixes are committed as `cf93253f36`. `linux-native.log` records all 20 unit tests and 8 expected-failure tests passing, including existing libudev callback-signature coverage preserved by conflict resolution. This runner tests `linux.input-events` recursively, so its FFI tests run once.

## Native runtime controls

`native-controls.log` contains five passing tests with PATH=/nonexistent and only a private directory in LD_LIBRARY_PATH. Discovery selects version 10 over 2, rejects a linker script at the unversioned name and an ELF with ARM64 machine metadata at version 999, and leaves the DSO constructor marker absent. Actual libudev exposes udev_new and permits allocation/unref without inspecting or changing devices. `native-dlopen-control.log` independently loads the C fixture, checks return 97, and proves the constructor does write its marker when explicitly loaded.

`build-library-probe.log` passes the Python runtime-library probe with the new exit-status assertions: valid DSO, absent DSO, unresolved dependency, and unusable compiler. This verifies build.sh's separate runtime probing behavior.

## SIMD and signal records

The full SIMD intrinsic suite passes after reloading the compiler emitter, runtime intrinsics, and SIMD vocabulary: 75 unit tests and 2 expected-failure tests per SSE2 (20), SSSE3 (33), SSE4.1 (41) lane. These final logs include root's strengthened regression exercising every byte index through explicit compile-call, as well as the existing generic-path check. The extra regression was copied from root after the initial source snapshot; root owns its source commit. `simd-sse33-before.log` replaces only the emitter with its exact definition from before d550dc352e in one process, reloads the SIMD vocabularies, and runs the identical tests. The generic test passes, but the explicit compiled all-256 test fails (exit 1); the current emitter passes (exit 0). `simd-before.factor` and `simd-before-driver.factor` reproduce this baseline without changing source files.

`zig-fpsimd-macos.log` and `zig-fpsimd-arm64-qemu.log` each pass both standalone FPSIMD tests: extension-record traversal and clearing only exception bits, plus malformed/missing/truncated/nonprogressing record rejection. ARM64 executable was cross-built with `zig test src/linux_arm64_fpsimd.zig -target aarch64-linux-musl -femit-bin=/tmp/factor-rebase-fpsimd-aarch64-llvm --test-no-exec` then executed using qemu-aarch64. This is synthetic record-parser coverage, not actual native ARM64 signal delivery.

The full Zig VM initially failed Linux ARM64 cross-compilation because image mapping requested macOS MAP_JIT on every ARM64 OS (`zig-vm-linux-arm64-before.log`). This predates the fetched commits. Commit `7dcad4a2e6` restricts the flag to macOS ARM64; the identical command then exits 0 (`zig-vm-linux-arm64-build.log`). The produced ELF has SHA256 `b7f8b90b0d03c156dfd9dfa088e79d1c291cb2d94619eb154f29e3ad1d2068d8`. Under QEMU, that newly built Zig VM successfully loads the existing ARM64 image, prints the startup marker, and exits 0 (`zig-vm-linux-arm64-startup.log`).

## ARM64 emulation boundary

`linux-arm64-qemu.log` runs the same Factor integration tests. The20 ordinary unit tests pass; three of 8 expected-failure tests differ because QEMU returns ENOTTY 25 for these input ioctl requests before validating fd=-1, whereas a native Linux kernel returns EBADF 9. The first optional ioctl therefore correctly returns false under emulation; the other two propagate ENOTTY. `ioctl-control.c` reproduces the exact three requests directly in C; `ioctl-native-c.log` and `ioctl-arm64-qemu-c.log` establish this distinction independently of Factor. The correct native expectations were preserved. No input device or graphical session was opened.

## Reproduction

From the isolated source tree (drivers are stored under evidence there):

```sh
./factor -i=factor.image -no-user-init evidence/linux-tests.factor
./factor -i=factor.image -no-user-init -sse-version=20 evidence/simd-tests.factor
./factor -i=factor.image -no-user-init -sse-version=33 evidence/simd-tests.factor
./factor -i=factor.image -no-user-init -sse-version=41 evidence/simd-tests.factor
# Expected exit 1: compiled-path regression against original emitter
./factor -i=factor.image -no-user-init -sse-version=33 evidence/simd-before-driver.factor
python3 vm/tests/library_probe.py -v
PATH=/nonexistent LD_LIBRARY_PATH="$PWD/fixture" FACTOR_FINDER_MARKER="$PWD/fixture/constructor-ran" ./factor -i=factor.image -no-user-init evidence/native-controls-driver.factor
python3 evidence/native-dlopen-control.py
/tmp/factor-varargs-entry-linux.eAGr27/qemu/usr/bin/qemu-aarch64 -L /usr/aarch64-linux-gnu ./factor-arm64 -i=arm64.image -no-user-init evidence/linux-tests.factor
```

Fixture sources and complete test drivers accompany the logs. Native controls use `gcc -shared -fPIC evidence/finder-fixture.c -o fixture/libfactor-rebase-probe.so.10`, a copy at .so.2, a text linker script at .so, and a copy whose ELF e_machine field is 183 at .so.999. The C ioctl oracle is compiled normally and with aarch64-linux-gnu-gcc, then the latter runs under the same QEMU/sysroot.
