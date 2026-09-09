# ARM64 homogeneous unions and padding

The existing classifier concatenated union alternatives, counting overlapping
floating-point members more than once. It also accepted padded homogeneous
structures and rejected vector unions whose lane types differed. These errors
changed argument registers, tail positions, and aggregate return conventions.
The independent C fixtures expose actual numeric corruption.

The shared `cpu.arm.64.abi` helper models members as byte offset, size, and
representation. It validates each nested composite, merges equivalent overlapping
members, and requires a contiguous homogeneous layout of one to four members.
Half/BF16 formats share a representation; vector lane types share the 128-bit
vector representation. Both the ordinary ARM64 classifier and variadic cursor
use that result.

The governing rules are the [AAPCS64 homogeneous aggregate definition](https://github.com/ARM-software/abi-aa/blob/main/aapcs64/aapcs64.rst#5105homogeneous-aggregates)
(uniquely addressable members, fundamental vector size) and
[Clang's ABI implementation](https://github.com/llvm/llvm-project/blob/main/clang/lib/CodeGen/ABIInfo.cpp)
(maximum union member count, recursive homogeneity, and padding rejection).
Validating children before merging is necessary: an unpadded union alternative
must not hide padding in another alternative.

## Native fail-before/pass-after

The standalone C fixture was built separately from Factor with Apple Clang:

```
clang -std=c11 -O2 -shared vm/ffi_test_arm64_unions.c -o libfactor-ffi-test.dylib
```

- `before.log`: 25 C-backed fixed-signature/outgoing-varargs checks, **19 numeric
  failures and six passing controls**, exit 1. Uses the pre-varargs verified image
  and its unchanged classifier.
- `after.log`: the same **25 checks pass**, zero compiler errors, exit 0. The
  only compiler change was replacing `homogeneous-float/vector-aggregate?` with
  its new shared-helper implementation. `classifier-before.factor` and
  `classifier-after.factor` record the runners.
- `callbacks-before.log`: retain the corrected ordinary classifier but keep the
  original variadic cursor classification. Reading a 32-byte homogeneous vector
  union from a real C variadic caller faults at `0x400000003f800000`, the first
  two float payloads interpreted as an indirect pointer. This isolated process
  exits 1. It uses the new callback VM and the pre-union `current.image` snapshot.
- `callbacks-after.log`: after changing cursor metadata to use the same helper,
  **all 29 checks pass**, zero compiler errors, exit 0. This adds runtime and
  declared-tail callbacks for two-float and 32-byte vector unions.
- `callbacks-portable.log`: the same **29 checks pass** with optional ARM64
  extensions disabled, exit 0.

Fixtures cover `union {float,float}`, scalar versus two-float alternatives,
four-float alternatives, nested unions, mixed float/double controls, explicit
member alignment and padding, a union whose other alternative covers padding,
the last two available FP argument registers, scalar/HFA/HVA returns, fixed
callbacks, and anonymous arguments. Vector unions mix float and integer lanes
and include aggregates larger than sixteen bytes.

The tests require no application libraries. MSVC runs the standard C union and
padding cases. GCC/Clang additionally run short-vector cases; their availability
is exported and required in the existing capable-Clang CI lane. The shared CI
runner executes `alien-arm64-unions.factor` for each compiler fixture rebuild.

## Compiler oracles and C controls

`c-controls-apple.log` and `c-controls-llvm.log` are independent native C-to-C
controls built with `-std=c11 -Wall -Wextra -Werror -O2
-DUNION_CONTROL_MAIN`; both pass. Compiler versions are recorded in the sibling
`bindings-ci/compilers.log`.

The three `.ll` files were generated with Homebrew Clang 23 using:

```
clang -std=c11 -O2 -DUNION_ORACLE -target TARGET -S -emit-llvm \
  vm/ffi_test_arm64_unions.c -o OUTPUT.ll
```

Targets are `arm64-apple-macos11`, `aarch64-linux-gnu`, and
`aarch64-pc-windows-msvc`. All classify the ordinary float unions as one, two,
or four float elements and padded composites as integer carriers. All classify
mixed-lane vector unions as one or two 128-bit vector elements. The Windows
anonymous two-vector aggregate is indirect; Linux and macOS use the aggregate
value according to their respective variadic calling conventions.

These are compiler oracles, not native Linux/Windows execution. Native platform
qualification remains pending CI.

## Concrete half/BF16 carrier regression

The full allocator/FFI run exposed a new-helper defect: normalizing half/BF16 to
`small-float-rep` produced the union class word, then `rep-size` had no applicable
method. The fix uses the concrete `half-rep` carrier for the shared 16-bit ABI
fundamental type; raw BF16 bits remain unchanged.

`small-before.log` independently reinstates the incorrect normalizer. Both the
new homogeneous small-union fixture and the existing half/BF16 aggregate suite
fail with `rep-size` dispatching on the `small-float-rep` word, exit 1.
`small-after.log` uses the concrete carrier: **all 62 checks pass**, zero compiler
errors, exit 0. This comprises 38 union checks (nine new half/BF16 checks) and 24
existing half/BF16 checks, including mixed small HFAs and exhaustive raw-result
bit patterns. `small-portable.log` repeats those 62 checks with optional ARM64
extensions disabled. The two `small-*.factor` runners preserve the isolated
before/after normalizer change.

The new cases test half-first and BF16-first homogeneous unions, named arguments,
returns, a two-member mixed-format HFA, fixed callbacks, and both runtime and
declared-tail variadic callbacks. `au_c_controls` now includes independent C
small-union controls. Apple Clang and Homebrew LLVM both pass these expanded C
controls (`c-small-controls-*.log`). Required Clang CI lanes assert the new
`au_small_available` capability before executing the tests. The three LLVM
oracles have been regenerated to include these exact C fixtures.
