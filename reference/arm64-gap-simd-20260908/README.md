# ARM64 SIMD gap verification — 2026-09-08

Source baseline: `3c430ff2fc8d4e658bda985a0e5f412f1836930d`.
All work ran in the isolated `arm64-gap-simd` worktree, using a copy of
`Factor.app` and a cloned `factor.image` from the root workspace. The runtime
resource path explicitly selected this worktree.

## Changes and semantics

* Signed and unsigned 64-bit vector `vmin`/`vmax` now lower to a lane comparison,
  bit-select, and register move. The separate scratch mask permits either source
  register to be reused as the destination.
* `float-4` to `int-4` now reconstructs the integer from binary32 bits. This
  truncates and wraps modulo 2^32, matching typed-array storage. It does not use
  saturating FCVTZS. NaNs, infinities, and magnitudes below one produce zero.
* Binary64 and unsigned conversions remain portable. Their semantics are not
  changed to gain an instruction.

The binary32 significand is the low 23 bits with its implicit leading one. The
raw sign/exponent shifted right 23, minus 150, provides the shift count. USHL
ignores the sign's added 256. For the otherwise problematic exponents whose
negative counts wrap, the resulting counts are still outside the lane width,
so they correctly produce zero. A signed comparison against 106 recovers the
original sign, then XOR/subtract applies modular negation. No floating-point
operation or range-dependent slow-path call is involved.

## Regression evidence

`before-tests.log` records 111 checks against the baseline backend: exactly
three failures, all missing desired lowering (`##min-vector`, `##max-vector`,
`##float>integer-vector`), and zero compiler errors. Semantic checks passed.

`after-tests.log` records 116 checks in `cpu.arm.64` and
`math.vectors.conversion`: zero failures and zero compiler errors. Coverage
includes signed/unsigned extrema, overflow wrapping, signed fractions, NaNs,
infinities, subnormals, and largest finite binary32 values. Differential tests
compare the native conversion to the portable implementation for all 512
sign/exponent combinations at four fraction patterns, plus 16,384 deterministic
mixed raw bit patterns. Binary64 exceptional-value regressions remain covered.

Run from this worktree:

```sh
./Factor.app/Contents/MacOS/factor -i=factor.image \
  -resource-path="$PWD" -no-user-init -no-monitors \
  reference/arm64-gap-simd-20260908/focused.factor
```

## Actual compiled benchmark

`bench.factor` compiles evolving vector loops, warms each loop once, and records
seven samples of one million iterations. The conversions feed accumulated
results; each iteration also changes the floating-point input. Results match
before and after, including the lanes outside the signed integer range.

`run-bench.factor` completes backend reloads in a separate compilation unit
before parsing `bench.factor`. This avoids stale availability decisions from
the copied image and from dependency loading during benchmark compilation.
`run-baseline.factor` reconstructs the baseline's three representation methods
in another completed compilation unit before compiling the same benchmark.
The new emitters are unreachable with those baseline representation lists.

```sh
./Factor.app/Contents/MacOS/factor -i=factor.image \
  -resource-path="$PWD" -no-user-init -no-monitors \
  reference/arm64-gap-simd-20260908/run-bench.factor
python3 reference/arm64-gap-simd-20260908/decode-code.py after

./Factor.app/Contents/MacOS/factor -i=factor.image \
  -resource-path="$PWD" -no-user-init -no-monitors \
  reference/arm64-gap-simd-20260908/run-baseline.factor
python3 reference/arm64-gap-simd-20260908/decode-code.py before
```

The harness records representation lists and CFG lowering checks and dumps the
live compiled loop bytes. `decode-code.py` embeds these exact bytes in a
synthetic object for LLVM decoding. Addresses change, and inline literal data
also appears as instructions; the executable instruction regions provide the
native-code evidence. This avoids Capstone's default stop at inline literal data.

Machine: Apple M5 Max, 18 CPUs, macOS 26.6.2. Concurrent work produced high host
load and substantial timing variance. These are workload observations, not a
claim that every caller receives the same speedup. The logs preserve all samples
and results; timings include loop overhead and any allocation required by the
compiled implementation.

## Floating-point environment: a measured difference

`fp-env.log` records a separate native/portable probe. Native CFG selection was
confirmed and the invalid+inexact trap mask was read back as active. Numeric
lane equivalence does **not** imply floating-point-environment equivalence:

| Inputs | Native flags | Portable flags | Native with traps | Portable with traps |
| --- | --- | --- | --- | --- |
| Fractions, infinities, subnormals, large wrapping finite values | none | inexact | returns | inexact trap |
| Quiet NaNs | none | invalid + inexact | returns | inexact trap |
| Signaling NaNs | none | invalid + inexact | returns | invalid trap |

The bitwise path executes no floating-point arithmetic and leaves FPSR unchanged.
The portable path also converts fixnum range boundaries to floating-point while
checking the scalar value, which explains inexact even for some integral inputs.
The public `vconvert` help promises truncated lane values but specifies no FP flag
or trap contract. This optimization therefore preserves numeric results and
changes this observable environment behavior. It is explicitly documented in
`SIMD.md`; it is not claimed to be a complete equivalence under enabled traps.

Run with `run-fp-env.factor` using the same Factor options as above. The probe
collects flags and catches VM floating-point exceptions to print their kinds.


## Final measured results

Seven samples, milliseconds per one million iterations (median; range):

| Compiled workload | Baseline | Native |
| --- | --- | --- |
| Signed 64-bit min + increment | 5.005; 4.789–6.377 | 4.994; 4.828–5.658 |
| Unsigned 64-bit max + increment | 4.717; 4.666–6.738 | 5.159; 4.483–5.601 |
| Float32 increment, wrapping conversion, integer accumulation | 25.893; 23.891–29.007 | 6.225; 6.081–6.330 |

The conversion workload measured about 4.16× faster. The min/max changes have
**no demonstrated runtime improvement** in these overlapping timing ranges:
baseline fallback already synthesizes CMGT/CMHI and BSL; the new direct lowering
removes one scratch-mask move. The CFG tests establish that direct lowering was
missing, not that baseline lacked native SIMD instructions. Earlier preliminary
measurements without completed reload/compilation boundaries were discarded.

Both final processes ran at Darwin priority 31; `/usr/sbin/taskpolicy -B -p PID`
was applied only to owned processes after startup. Before/after loop result
vectors match. The `.bin` artifacts are exact code ranges from `word-code`;
`.disasm` artifacts show the native USHL binary32 reconstruction versus baseline
scalar FCVT, integer range tests, and potential bignum paths.

The two permanent floating-environment regression checks confirm that native
conversion raises no flags for signaling NaNs/fractions, and preserves an
existing divide-by-zero flag.
