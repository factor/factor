# macOS ARM64 FFI ABI gap — 2026-09-08

This work reuses and extends the prior unmerged stack-packing and variadic
commits, preserving the newer X8 structure-result and native-stack callback
fixes in snapshot `3c430ff2fc8d4e658bda985a0e5f412f1836930d`.

## Changes

- Preserve the natural size of scalar stack arguments and emit narrow integer
  loads/stores; callbacks recover arguments from the saved native stack.
- `FUNCTION:` and `FUNCTION-ALIAS:` accept `...` between named and unnamed
  arguments. Each declaration still lists concrete argument types. `open`,
  `openat`, and `fcntl` now declare their actual variadic boundary.
- Allocate the named argument area normally, then align each variadic argument
  to eight-byte stack slots. Aggregate members retain their layout. This works
  after named register exhaustion and for named/variadic HFAs.
- Add `alien-indirect-varargs` with an explicit literal named-parameter count.
  Apply C float/integer default promotions, validate the count, reject duplicate
  markers, and reject variadic `CALLBACK:` declarations. Legacy boolean `t` is
  rejected on macOS ARM64 because it cannot identify the boundary.
- Spill ARM64 aggregates wholly when their register class lacks enough registers.
  Recognize HFA fields containing C arrays, including return values. C-string
  pseudo-arrays continue to classify as pointers.
- Re-enable the previously skipped packed-stack and variadic compiler tests.

## Independent native evidence

The permanent fixture is [vm/ffi_test_arm64.c](../../vm/ffi_test_arm64.c), included
by the ordinary `factor-ffi-test` build on macOS ARM64. The permanent
[basis/compiler/tests/alien-arm64-abi.factor](../../basis/compiler/tests/alien-arm64-abi.factor)
is discovered by the normal compiler test suite and gated to macOS ARM64.
The reference copy [fixture.c](fixture.c) is compiled by Apple Clang, separately from Factor. It
uses real C signatures, `va_start`/`va_arg`, native function pointers, and native
callers of Factor callbacks. [native.c](native.c) independently checks eleven
C-to-C results. The unused eighth register is explicitly poisoned in boundary
callback fixtures so stale registers cannot produce a false pass.

[abi-tests.factor](abi-tests.factor) contains 27 checks covering direct and
indirect calls; signed/unsigned 1-, 2-, 4-, and 8-byte integers; mixed integer and
floating register exhaustion; float spills; native callbacks; named argument
spills before variadic arguments; default promotions; HFA arguments/returns;
HFA C-array fields; and integer/HFA aggregate register boundaries.

The baseline uses a separate untouched worktree at the snapshot above, the
same VM/image copies and the same C library. Its
[baseline-tests.factor](baseline-tests.factor) only translates unsupported new
syntax to the old fixed-signature declaration/indirect entry point. Direct
`alien-invoke` tests retain their integer named counts; the old compiler ignores
them. Thus failures exercise native ABI behavior, not merely parser rejection.
Two ordinary structure-stack controls pass on both revisions.

| Check | Before | After |
| --- | --- | --- |
| Independent native ABI checks | 25 failures, 2 controls pass | 27 pass |
| Native C-only controls | — | 11 pass |
| Existing parser, stack-checker, alien CFG, full alien and large-return suites | — | 243 pass, zero compiler errors |
| ARM64 backend suite | — | 344 pass, zero compiler errors |

Logs: [before.log](before.log), [after.log](after.log),
[native.log](native.log), [regressions-final.log](regressions-final.log),
[backend.log](backend.log). All successful Factor runs also require zero
compiler errors and process exit status zero. [fixture.s](fixture.s) records
Clang's independent ARM64 assembly; compiler/platform versions are recorded
alongside it.

## Reproduction

Run in this checkout with a native macOS ARM64 Factor VM/image. An existing image
must reload changed compiler modules and every generated renaming consumer;
the runners do this in a single compilation unit.

```sh
clang -Wall -Wextra -Werror -O2 -dynamiclib reference/arm64-gap-abi-20260908/fixture.c -o reference/arm64-gap-abi-20260908/libfixture.dylib
clang -Wall -Wextra -Werror -O2 reference/arm64-gap-abi-20260908/native.c -o reference/arm64-gap-abi-20260908/native
reference/arm64-gap-abi-20260908/native
./factor -no-user-init -no-monitors reference/arm64-gap-abi-20260908/run.factor
make factor-ffi-test CONFIG=vm/Config.macos.arm.64
./factor -no-user-init -no-monitors reference/arm64-gap-abi-20260908/regressions.factor
./factor -no-user-init -no-monitors reference/arm64-gap-abi-20260908/backend.factor
```

For the negative run, create a detached worktree at the snapshot, copy the VM,
image and compiled fixture into it, copy `baseline-tests.factor` as
`reference/arm64-gap-abi-20260908/abi-tests.factor`, then reload only the snapshot's
`cpu.architecture`, `cpu.arm.64.assembler`, `cpu.arm.64`, and
`compiler.cfg.builder.alien` before running that file. Point `-resource-path` at
the baseline worktree. Do not load patched parser or compiler files there.

## ABI references and limits

Apple's [Writing ARM64 code for Apple platforms](https://developer.apple.com/documentation/xcode/writing-arm64-code-for-apple-platforms)
defines compact scalar stack arguments and eight-byte variadic stack slots.
The [AAPCS64](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst)
parameter allocation rules C.2/C.3 and C.12/C.13 require whole aggregate register
allocation. Array fields participate in HFA classification. Both primary
references were checked on 2026-09-08; C compiler output serves as the independent
executable ABI oracle.

This task executes macOS ARM64. It does not certify Linux/Windows ARM64, every
possible C type, or variadic callbacks. Variadic callbacks are explicitly
rejected because their runtime argument types cannot be inferred from this API.
The supplied Factor float is used as the promoted double value. To model an
intermediate float32 expression, explicitly quantize with `float>bits bits>float`
before the call. Half/BF16 scalar support is a separate coordinated change. No shared worktree,
installed image, or remote environment was modified.

## Unsupported-platform declaration isolation

The permanent driver now conditionally loads
`basis/compiler/tests/fixtures/arm64-abi.factor`. `vocabs.files:vocab-tests-dir`
only discovers the immediate `.factor` files, so it cannot independently run the
nested cases on another platform. Merely putting declarations in a false
quotation still defines the words during parsing.

`gate-smoke.factor` tests the old false wrapper with a nonexistent native
library and asserts that `abi_narrow` was not defined. It **fails**, observing
the word despite the false gate (`gate-before.log`, exit 1).
`gate-smoke-after.factor` tests the new false driver with a nonexistent cases
file: no declarations load, the assertion passes, and compiler errors remain
zero (`gate-after.log`, exit 0). `gate-native.factor` runs the real supported
platform driver: all 27 native tests pass with zero compiler errors
(`gate-native.log`, exit 0). This is a simulated unsupported condition, not
execution on a Linux or Windows host.
