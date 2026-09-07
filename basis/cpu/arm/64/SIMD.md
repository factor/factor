# ARM64 SIMD coverage

All public operations have portable Factor implementations. Ordinary compiled
code targets baseline Advanced SIMD. Optional instructions are isolated in
private, non-inline kernels in `math.vectors.simd.extensions.arm.64`, with
`required-arm64-features` metadata and runtime dispatch at their entry points.
Multiplication and addition are never implicitly fused; use `vfma` explicitly.

## Baseline Advanced SIMD

| Operation | Native lane types | Implementation |
| --- | --- | --- |
| Byte and immediate lane shuffles | All twelve 128-bit types | TBL/INS; indices wrap at the appropriate lane count |
| Two-input immediate shuffles | All twelve types | INS; indices address the concatenated vectors |
| Saturated multiply `vs*` | Signed/unsigned 8, 16, 32-bit | Widening multiply and saturating narrow |
| Pairwise multiply-add `v*hs+` | 8, 16, 32-bit | Widen, multiply, permute, saturated add |
| Sum of absolute differences `vsad` | 8, 16, 32-bit | SABD/UABD followed by widening UADDLV |
| Low multiply and rounded average | Signed/unsigned 64-bit | Scalar lane MUL/INS; overflow-safe vector average |
| Runtime scalar shifts | All integer types | Clamp the full count before DUP and SSHL/USHL |
| Signed per-lane shift `vshift` | All integer types | Clamp signed counts to ±lane width before SSHL/USHL |
| `vbit-count`, `vclz`, `vctz`, `vbit-reverse` | All integer types | CNT/UADDLP, CLZ, RBIT/REV; scalar CLZ for 64-bit lanes |
| `vmul-wide` | Signed/unsigned 8, 16, 32-bit | SMULL/UMULL and their upper-half forms; returns low then high vector |
| `vabsdiff` | All integer types | SABD/UABD, or subtract/compare/select for 64-bit; returns unsigned lanes |
| `vfma` | float-4, double-2 | FMLA with a separate accumulator; one rounding at lane precision |
| Floor, ceiling, truncate, round, round-to-even | float-4, double-2 | FRINT variants; round uses ties away, round-to-even uses ties to even |
| `vmin-element`, `vmax-element` | 8, 16, 32-bit integers; float-4, double-2 | Ordered lane reduction using native min/max |
| Mask blend and unordered comparison | Baseline types | BSL and ordered self-comparison masks |
| Float to unsigned integer conversion | float-4 to uint-4; double-2 to ulonglong-2 | FCVTZU; truncate, saturate out of range, NaN becomes zero |

`vshift` takes a count vector of the corresponding **signed** type: for example,
`uint-4 int-4 vshift`. Positive counts shift left; negative counts shift right.
Large counts produce zero, or sign fill for signed right shifts. `vclz` and
`vctz` return the lane width for zero. Bit operations inspect only the lane's
fixed-width two's-complement bits.

The existing unusual byte `v*hs+` contract is preserved: the first input is
interpreted as unsigned bytes and the second as signed bytes. Wider unsigned
inputs retain the existing signed saturation limit in the widened result.

## Reduced floating-point types and optional instructions

`half-8` stores IEEE binary16 and `bfloat-8` stores BF16. They are numeric
sequences of eight Factor floats, with their own representations, constructors,
literal syntax, raw casts, memory accessors, and vector ABI support. Numeric
conversion rounds to nearest, ties to even; preserves signed zeros, infinities,
and subnormals; and canonicalizes NaNs. Boolean literals and comparison results
use raw all-one or all-zero lanes. Shuffles preserve raw lane bits.

Use `vconvert` with these types. Packing two `float-4` values produces one small
vector; unpacking produces the low and high `float-4` values. Same-width
half/BF16 conversion is numeric; `half-8-cast` and `bfloat-8-cast` reinterpret
bits. Scalar half/BF16 C parameters and return values are not supported.

| Feature | Public operation | Native instructions |
| --- | --- | --- |
| FP16 | half-8 add, subtract, multiply, divide, square root, FMA, min/max and comparisons | Half-precision Advanced SIMD arithmetic |
| FP16 | float-4 pair to half-8 | FCVTN/FCVTN2 |
| DotProd | `vdot4+` with matching signedness | SDOT/UDOT |
| I8MM | Mixed unsigned/signed `vdot4+` | USDOT (inputs commute) |
| I8MM | `vmatmul2x8+` | SMMLA/UMMLA/USMMLA; signed A with unsigned B uses the reference path |
| BF16 | `vbdot2+` and `vbmatmul2x4+` | BFDOT/BFMMLA |
| BF16 | float-4 pair to bfloat-8 | BFCVTN/BFCVTN2 |

`vdot4+` takes two byte vectors and four 32-bit accumulators. Each result adds
four adjacent products. The accumulator is `uint-4` when both inputs are
unsigned, and `int-4` otherwise. Accumulation wraps modulo 2^32.

`vmatmul2x8+` uses a 2×8 row-major A, an 8×2 column-major B, and four row-major
accumulators/results. `vbmatmul2x4+` uses the analogous 2×4 and 4×2 layout, with
BF16 inputs and `float-4` accumulation. `vbdot2+` adds two adjacent BF16 products
per float-4 lane.

The BF16 accumulation APIs use baseline Arm BFDotAdd semantics: every product,
pair sum, and accumulator sum rounds to odd in binary32; subnormal inputs and
intermediates flush to signed zero; NaNs canonicalize. Matrix accumulation applies
two such pair operations in order. This is different from ordinary BF16
arithmetic, which computes in binary32 and rounds the stored result to BF16.
The reference implementation uses exact rational intermediates. Native kernels
temporarily select the required FPCR behavior, including EBF=0, and restore FPCR
before returning. Half FMA likewise rounds its exact product-plus-sum once.

## Dispatch and saved images

`cpu.arm.64.features` probes Apple `hw.optional.arm.FEAT_*` sysctls or Linux
`AT_HWCAP`/`AT_HWCAP2`. Failed or unsupported probes advertise no extensions.
Detected capabilities are memoized per process and invalidated at image startup.
No optional kernel is selected solely because the image-building machine had
the extension.

Set `disabled-arm64-features` to a sequence of feature names in a namespace scope,
or start Factor with `-disable-neon-extensions`, to force portable paths. These
controls only remove capabilities. Names are `dotprod`, `fp16`, `bf16`, `i8mm`.
Kernel requirements can be inspected with `arm64-kernel-requirements`.

## Validation and measurement

The assembler tests include encodings independently produced by Clang targeting
`armv8.6-a+fp16`. SIMD tests compare compiled intrinsics, forced reference
implementations, and ordinary calls. Extension tests compare native and disabled
dispatch byte for byte, including random raw floating-point encodings. Both
16-bit conversion formats have exhaustive 65,536-pattern round-trip tests.

Run `"math.vectors" test`, `"cpu.arm.64" test`, and
`"math.floats.small" test`. `benchmark.neon` measures representative operations
with native dispatch and with all optional extensions disabled. Timings include
dispatch and allocation costs; short kernels are not assumed to be faster merely
because they contain a native instruction.

Architecture references: [Arm Advanced SIMD intrinsics](https://arm-software.github.io/acle/neon_intrinsics/advsimd.html),
[Arm A64 instruction and pseudocode reference](https://documentation-service.arm.com/static/67e40f3398aa3c3b6eea6a85),
and [Linux ARM64 hardware capabilities](https://www.kernel.org/doc/html/latest/arch/arm64/elf_hwcaps.html).
SVE/SME, cryptographic extensions, and new x86 instruction selection are outside
this implementation.
