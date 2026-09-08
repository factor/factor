# ARM64 scalar half/BF16 C ABI — 2026-09-08

Scalar `half` and `bfloat` now support direct and indirect C calls, parameters,
results, and callbacks. Previously they were storage-only C types and failed
while building a scalar FFI call. Values use Factor's existing numeric
binary16/BF16 conversions (nearest, ties to even, canonical NaNs), then carry
raw low16-bit payloads in FP registers. Baseline FMOV S/W and H loads/stores
avoid requiring optional FP16 or BF16 instructions in the Factor bridge.
The generic C helper functions used for integer boxing remain unchanged.

The backend handles spilled intermediate values, masks unspecified upper
result-register bits, and recognizes mixed binary16/BF16 homogeneous aggregates.
Apple variadic scalar values promote to double; private promoted types retain
the declared half/BF16 rounding before widening. Linux AAPCS64 keeps scalar
half/BF16 varargs in their original format. Normal register overflow follows the
shared ABI changes (natural2-byte macOS slots, 8-byte AAPCS64 slots).

## Evidence

Native platform: macOS ARM64; Apple Clang21 (see toolchain.txt). Local Clang
accepts both `_Float16` and `__bf16` parameters/results and arithmetic.
`probe.s` is independently compiled from the C fixture with a macOS11 target;
`probe-linux.s` cross-compiles it for aarch64-linux-gnu. The Apple oracle uses
H0-H7 and H0 results, spill offsets0/2; the Linux oracle uses offsets0/8.
`moves.s` supplies four independent load/store encoding expectations.

- `before-suite.log`: the unmodified baseline storage type fails a scalar identity call against the same
  fixture while compiling `unbox-parameter`; process exits1.
- `after.log`: all24 scalar tests pass (exit0), including direct/indirect calls,
  mixed integer/FP parameters, C-driven callbacks, ten-argument register
  overflow in both directions, rounding, signed zeros/subnormals/infinities,
  mixed half/BF16 HFA, poisoned upper result bits, and Darwin varargs rounding.
  Two checks each iterate all65,536 raw result payloads, including NaNs.
- `final-suite.log`: fresh image source refresh followed by scalar tests,
  math.floats.small recursively, ARM64 assembler, compiler/tests/alien.factor,
  and compiler.cfg.builder.alien recursively. Zero test failures and compiler
  errors across433 checks; process exits0. The first line records the isolated resource path.
- `build.log`: normal `make factor-ffi-test` builds the integrated oracle cleanly.
- `x86-capability.log`: x86 cross-compilation builds only the capability export;
  unsupported C toolchains do not parse the reduced scalar declarations.

## Reproduction

The C fixture lives in `vm/ffi_test_small.h`, included by `vm/ffi_test.c`, with
GNUmakefile and Nmakefile dependencies. The normal Factor driver calls an
always-available capability export before loading supported-only declarations.
The fixture conservatively enables AArch64 Clang18+; older or other compilers
skip these C tests. That guard is a tested-toolchain boundary, not a claim that
all other compilers lack these types.

In an isolated source checkout, copy Factor.app and clone factor.image from a
compatible ARM64 image, then run:

```sh
make factor-ffi-test CONFIG=vm/Config.macos.arm.64
./factor -no-user-init -no-monitors \
  reference/arm64-gap-reduced-ffi-20260908/run.factor
```

`refresh.factor` gives the exact working reload sequence, including all generated
register-renaming consumers required by the shared ABI stack tuple changes.
It writes only the isolated `reduced.image`. To reproduce the negative test
against the unmodified initial image, run `before.factor` instead; it loads the
captured baseline c-types source and scalar identity calls from the same C-driven fixture.

## Scope and limitations

Native execution covered macOS ARM64 only. Linux received independent compiler
ABI cross-checks; no Linux or Windows scalar runtime execution is claimed. Windows fixed scalar
signatures match the Clang compiler oracle. Variadic signatures containing a
scalar half/BF16 parameter are explicitly rejected, including named parameters:
Windows allocates these values in integer-register slots, which this backend
does not implement.
Other Factor architectures retain an explicit scalar-ABI-unsupported error;
the storage accessors remain available. Older Clang BF16 storage support is not
sufficient evidence of a scalar calling convention. The implementation targets
IEEE binary16 and Brain BF16, not Arm's alternative half format. Numeric calls
canonicalize NaNs; preserving arbitrary NaN payloads requires raw memory access.
The Factor conversion policy is nearest-even regardless of ambient FP rounding;
C code itself may honor the active FP environment differently.

## Primary sources

- [AAPCS64, half formats and parameter/result rules](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst)
  §§5.3,5.10.5,6.8: half formats have2-byte size/alignment and share a fundamental
  type for homogeneity; scalar FP parameters use low FP-register bits.
- [Clang language extensions](https://clang.llvm.org/docs/LanguageExtensions.html#half-precision-floating-point)
  distinguishes `_Float16`, arithmetic `__bf16`, and older storage-only BF16.
- [Apple ARM64 ABI](https://developer.apple.com/documentation/xcode/writing-arm64-code-for-apple-platforms)
  describes platform-specific stack/variadic conventions. Concrete reduced-type
  promotion behavior here is established by local Clang assembly and C tests.

## Windows follow-up

`probe-windows.s` was generated with Apple Clang21 targeting
`aarch64-windows-msvc -ffreestanding -O2`. Fixed identity/bit/mixed/overflow and
callback fixtures confirm the expected FP-register convention and8-byte overflow
slots. In contrast, `half_varargs` and `bfloat_varargs` read low16-bit values from
saved X1/X2 slots. The earlier fixed-function allocation would be incorrect for
these signatures. `check-windows-small-float-varargs` now rejects direct and
indirect variadic signatures containing either scalar small type, while keeping
fixed signatures accepted. The guard applies to named parameters too.

`windows-guard-after.log`: all9 stack-checker.alien checks pass, including named
and unnamed rejection and fixed-signature acceptance. The negative control
`windows-guard-before.factor` replaces only the guard with the prior unchecked
behavior; the identical guard checks fail twice (`windows-guard-before.log`,
exit1). No native Windows execution is claimed.
