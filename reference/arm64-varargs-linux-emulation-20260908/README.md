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
`/tmp/factor-varargs-linux-boot-source/`. The previous boot image lacked the new core `alien-callback-varargs` word.
A separately tested bootstrap compatibility layer now upgrades older version-5
seeds; see `../arm64-varargs-bootstrap-compat-20260908/README.md` for the distinct
preexisting official version-4 seed limitation.

## Factor runtime results

The complete Linux ARM64 bootstrap under QEMU passed with exit 0 and saved a
111 MB `factor.image`. It took 41 minutes 18 seconds. `bootstrap-unbounded.log`
and `.exit` record the run, including successful compiler and tools loads.
The test source was then synchronized through the final implementation
`44dd4f9d99` and alignment fix `f730b1a03c`.

`update-final.factor` reloads the promotion/union reader and compiler definitions
and saves `current.image`; `update-final.log` and `.exit` show success with zero
compiler errors. The alignment fix arrived after the SIMD vocabulary reload,
so `tests.factor` applies its exact `align-first = 16` metadata to all 12 loaded
SIMD c-types before loading any test aggregate definitions. The final builder
and boxing source was synchronized before their reload. The on-disk SIMD source
also contains the final fix; the test image was not published as a release image.

The final C fixture library was rebuilt with Clang 21:

```sh
clang-21 --target=aarch64-linux-gnu --gcc-toolchain=/usr -O2 -fPIC -shared vm/ffi_test.c -o libfactor-ffi-test.so
```

The initial focused Factor runs passed **133 unit checks and 15 expected-failure
checks**, with zero compiler errors and exit 0. The normal and
`-disable-neon-extensions` lanes both required positive Clang half/BF16 controls.
They cover incoming and outgoing varargs, register/stack exhaustion, nested
callbacks and GC, aggregate/HFA/union handling, promotions, native `va_list`,
formatting, and the final aggregate/SIMD alignment fixtures. Logs are
`tests-final.log` and `tests-portable-final.log`, with their `.exit` files.

From the isolated remote `factor/` directory:

```sh
../qemu/usr/bin/qemu-aarch64 -L /usr/aarch64-linux-gnu ./factor -i=current.image -no-user-init -no-monitors -require-varargs-small ../tests.factor
../qemu/usr/bin/qemu-aarch64 -L /usr/aarch64-linux-gnu ./factor -i=current.image -no-user-init -no-monitors -disable-neon-extensions -require-varargs-small ../tests.factor
```

Four actual `printf` subprocess checks also passed: direct and indirect calls,
each with normal and disabled-extension execution. `printf-final.log` records
exit 0, empty stderr, and the exact stdout bytes
`value:-42:  1.250:-1234567890123\n`. Each Factor script also asserts the C return
count and `fflush` result. The scripts are
`basis/compiler/tests/varargs/printf.factor` and `printf-direct.factor`; they
were invoked explicitly through QEMU because the host has no ARM64 binfmt entry.

`gcc-controls-final.log` and `clang-controls-final.log` also record the final
independent C HFA spill and 0xff general controls. Clang's half/BF16 controls
pass positively; GCC explicitly reports them unavailable.

These results establish a passing **Linux ARM64 emulation** lane. They do not
establish native Linux ARM64 qualification. Host and installed Factor trees,
preexisting temporary workspaces, and root checkout images were not modified.


## Complete compiler matrix, including promotions and unions

The final `tests.factor` additionally loads the two dedicated promotion and
union drivers. Its exact compiler test files are:

- `basis/compiler/tests/alien-varargs.factor`
- `basis/compiler/tests/alien-varargs-outgoing.factor`
- `basis/compiler/tests/alien-varargs-promotions.factor`
- `basis/compiler/tests/alien-arm64-unions.factor`

It also runs the `alien.varargs`, `alien.parser`, `stack-checker.alien`, and
`compiler.cfg.builder.alien` vocabulary tests. The union driver includes
ordinary/variadic callbacks and the conditional half/BF16 union cases.

| C fixture compiler | Execution | Unit checks | Expected failures | Small-float capability |
| --- | --- | ---: | ---: | --- |
| Clang 21 | Normal | 189 | 15 | Required, present |
| Clang 21 | Disabled extensions | 189 | 15 | Required, present |
| GCC 15.2.0 | Normal | 177 | 15 | Both queries explicitly 0 |

All three runs exit 0 with zero compiler errors. Their complete logs and exit
files are `tests-complete-clang`, `tests-complete-clang-portable`, and
`tests-complete-gcc`. `coverage.factor` makes the GCC capability exclusion
explicit with `-expect-varargs-small-unavailable`; Clang instead passes
`-require-varargs-small`. GCC's 12 absent checks are compiler-gated half/BF16
fixtures, not counted as successes.

After rebuilding the final fixture with GCC, all four actual printf subprocess
checks passed again. `printf-complete-gcc.log` and `.exit` record exact stdout,
empty stderr and zero exits; `printf-checks.py` reproduces the checks from the
isolated `factor/` directory. The earlier Clang printf results remain in
`printf-final.log`.

## GCC C-only vector-union control discrepancy

The expanded GCC run initially failed the independent `au_c_controls` check;
all Factor calls and callbacks for the same unions passed. The compiler was
`aarch64-linux-gnu-gcc (Ubuntu 15.2.0-16ubuntu1) 15.2.0` (`union-gcc-version.log`).
The C-only call receiving a variadic union containing two 16-byte vectors
returned 17 instead of 53 at `-O2`. Ordinary C calls returned 46 correctly.
`tests-complete-gcc-before.log` and `union-gcc-before.log` retain the failure;
`union-debug.c` is the isolated instrumented reproduction.

The discrepancy disappeared at `-O0`, at `-O2 -fno-strict-aliasing`, and with a
narrow GCC-only `may_alias` annotation on that union. Making the local union
volatile did not resolve it (`union-gcc-optimization.log`). The observed optimized assembly saved Q0/Q1 but
loaded the copied union from different, uninitialized stack slots. This records
an optimization discrepancy, not a conclusively diagnosed compiler bug.

Patch `a67b21a9f8` applies the annotation only to the C oracle union; it retains
all expected control values and changes no Factor ABI implementation or global
compiler flags. Before and after checks both show size 32 and alignment 16
(`union-layout-before.log`, `union-layout-after.log`). The final GCC C control
passes (`union-gcc-after.log`), the expanded Factor GCC matrix passes, and final
Clang normal/portable runs pass after rebuilding the same source. The annotation
is excluded when compiling with Clang.

Reproduce the independent GCC control from the final source:

```sh
aarch64-linux-gnu-gcc -O2 -DUNION_CONTROL_MAIN vm/ffi_test_arm64_unions.c -o union-control
../qemu/usr/bin/qemu-aarch64 -L /usr/aarch64-linux-gnu ./union-control
```

To run the GCC Factor lane, rebuild `libfactor-ffi-test.so` with
`aarch64-linux-gnu-gcc -O2 -fPIC -shared vm/ffi_test.c -o libfactor-ffi-test.so`, then pass
`-expect-varargs-small-unavailable` in place of `-require-varargs-small` to the
runner command above. The Clang lanes rebuild with the previously recorded
Clang cross command and retain the required-small flag.
