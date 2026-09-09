# Linux ARM64 emulation environment

Host `agent1` is Ubuntu 26.04 **x86_64**, not native ARM64. All work is isolated
under `/tmp/factor-varargs-entry-linux.eAGr27`; pre-existing Factor checkouts and
other temporary work were not modified. No packages were installed globally.

Downloaded `qemu-user` with `apt-get download`, extracted with `dpkg-deb -x`.
QEMU 10.2.1's `qemu-aarch64 -L /usr/aarch64-linux-gnu` runs ARM64 Linux ELF files
against the existing cross libc. Existing GCC 15 and Clang 21 both compile the
independent C ABI fixtures. `gcc-controls.log` and `clang-controls.log` show all
8 general C controls passing; Clang also passes the half/BF16 controls. GCC's
half/BF16 fixture is explicitly unavailable, not counted as passing.

```
aarch64-linux-gnu-gcc -O2 -DFACTOR_VARARGS_CONTROL_MAIN ffi_test_varargs.c -o varargs-controls
clang-21 --target=aarch64-linux-gnu --gcc-toolchain=/usr -O2 -DFACTOR_VARARGS_CONTROL_MAIN ffi_test_varargs.c -o varargs-controls-clang
qemu/usr/bin/qemu-aarch64 -L /usr/aarch64-linux-gnu ./varargs-controls
qemu/usr/bin/qemu-aarch64 -L /usr/aarch64-linux-gnu ./varargs-controls-clang
```

The current C++ VM also cross-builds successfully. Cross G++ was absent, so
`g++-15-aarch64-linux-gnu` and `libstdc++-15-dev-arm64-cross` packages were
extracted into the isolated `toolchain/` directory. Build command:

```
CC=aarch64-linux-gnu-gcc \
CXX='/tmp/factor-varargs-entry-linux.eAGr27/toolchain/usr/bin/aarch64-linux-gnu-g++-15 -B/usr/aarch64-linux-gnu/bin/ -B/usr/lib/gcc-cross/aarch64-linux-gnu/15/ -B/usr/aarch64-linux-gnu/lib/ -isystem /usr/aarch64-linux-gnu/include' \
make -j8 linux-arm-64
```

Fresh image bootstrap exercises source dependency ordering that refresh of an
already loaded image does not cover. Its first failure exposed the new eager
`alien.parser -> alien.varargs -> libc -> alien.syntax` cycle (`LIBRARY:` was
not defined yet). A lazy parser import resolves that cycle. The next failure
exposed `classes.struct -> combinators.smart -> stack-checker.alien ->
alien.varargs -> classes.struct` (`struct-c-type` was not defined yet).
These failures were reported to the root implementation agent for fixes.

A new ARM64 boot image was successfully generated from current source using the
verified macOS host image, with output restricted to
`/tmp/factor-varargs-linux-boot-source/`. The previous boot image lacked the new
core `alien-callback-varargs` word and must not be used to qualify fresh builds.

These C controls and cross-builds establish a usable **emulation** lane. They do
not establish native Linux ARM64 qualification or Factor-level test success.
