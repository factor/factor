# x86-64 SIMD audit — 2026-09-08

Native Linux x86-64 audit on an AMD Ryzen 9 7950X3D. The scope is Factor's
128-bit SIMD implementation: the SSE backend and feature selection, assembler
mappings, shared intrinsic expansion, propagation and value numbering,
integer/float/half/bfloat vector operations, conversions, cords, matrices,
and SIMD consumers exercised by the tests. This is a source review plus
targeted execution, not a proof of correctness for every input or platform.

## Fixes

| Commit | Finding and correction |
| --- | --- |
| `58b68acc0a`, `721578f477` | Literal lane shifts such as 256 were truncated to an imm8 count of zero. Clamp the backend count to 64, including signed arithmetic right shifts. |
| `2467c0b351` | `short-8 v*hs+` wrapped to INT_MIN for pairs of minimum signed words. Correct PMADDWD's unique overflow result to INT_MAX, matching the saturating fallback. Mixed lanes and unsigned-byte/signed-byte multiplication have regression coverage. |
| `df94ce43f2` | The documented byte-array form of `vshuffle` had no implementation. Dispatch 16-byte permutations to the byte shuffle, retaining the input vector type; reject wrong-sized masks. |
| `9607565e14` | Bignum lane-shift counts were truncated by `>fixnum`. Clamp before conversion; test all eight integer representations, literal and dynamic counts, including values above 2^64. |
| `a1492b4f5e` | Floating high-half extraction used UNPCKHPD without initializing a distinct destination. Copy first, as the integer path already does. Explicit-register encoding regressions cover both floating representations and the in-place case. |
| `c5c80f7d37` | Integer dot products were inferred as fixnums even when their results were bignums. Infer `integer` for integer vectors while retaining `float` for floating vectors. Two inferred-type checks and two compiled `bignum?` checks failed before the correction and pass afterward. |

Intel documents both the exceptional PMADDWD wraparound and the saturating
shift-count behavior in its [instruction-set reference](https://cdrdv2-public.intel.com/774492/325383-sdm-vol-2abcd.pdf).
UNPCKHPD reads both input operands, including the old destination, as described
in [Volume 2B](https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-vol-2b-manual.pdf).

## History

Fetched `origin`, then replayed the candidate-only merge history as ordinary
commits. A subsequent remote ARM64 update was preserved and replayed too.
The committed tree was checked byte-for-byte against the pre-rebase tip;
there are zero merge commits in `origin/master..HEAD` after the rewrite.
The ARM64 update is `cc2670a56f`; the preceding Linux issue fixes are
`3bca452fff`. No push was performed. Backup branches retain both pre-rewrite
histories, including `backup/master-candidate-before-relinear-20260908`.

## Validation

The scripts explicitly refresh compiler/CPU/FFI source against the existing
runtime image. Final runs disable automatic import repair before refreshing.
The VM/image came from the matching Linux validation checkout, as described
in [the Linux issue report](../linux-issues-20260908/README.md).

`suite.factor` enables SSA and register-allocation verification. It exercises
the x86/assembler/x86-64 tests, SIMD and its child vocabularies, conversions,
matrices, SFMT, intrinsic expansion, propagation, and SIMD value numbering.
The allocator and global-GVN settings apply to code generated during the run.

The fuzz harness intentionally captures two failing cases in `fake-unit-test`;
their printed failure markers are expected. The final test/compiler-error
counters and process exit status determine whether a suite passed.

`edges.factor` performs 11,600 reproducible native-versus-forced-fallback
comparisons per run: eight integer representations, 29 operations, and 50
full-width random-byte inputs per operation. It covers signed and unsigned
arithmetic, saturation, comparisons, bitwise operations, reductions, and bit
counting; deterministic unit tests separately cover exact extrema.

Before-fix evidence includes unchanged vectors after a literal shift by 256,
two failing multiply-add regressions (zero compiler errors), and high-half
extraction emitting only `66 0f 15 c1` for distinct XMM registers. The chordal
allocator exposed the corresponding float-to-double unpacking error.

The initial default-allocator suites passed at SSE versions 20, 30, 33, 41,
and 42. The full-width differential runs passed at versions 20 and 42.
The chordal unpacking failure was reproduced in isolation before its fix;
all four allocator configurations passed afterward. The subsequent
dot-product propagation regressions failed before that separate fix.

Final validation is against the source tree at `c5c80f7d37`, checked with
`git diff --exit-code` in `/tmp/factor-simd-final-20260908-VuKrlv`.
All final runs passed:

| Configuration | Result |
| --- | --- |
| Local GVN, linear-scan, SSE 20 / 30 / 33 / 41 / 42 | Five suites; zero test failures and zero compiler errors in each. |
| Global GVN, SSE 42, linear-scan / greedy / backtracking / chordal | Four suites; zero test failures and zero compiler errors in each. |
| Full-width integer differential checks, SSE 20 / 42 | 23,200 comparisons total; no mismatches or compiler errors. |

Final logs use the `logs/simd-x64/dot-final-` prefix. The standalone output
type regressions also passed in `dot-type-after.log` after four failures
in `dot-type-before.log`.

The matching runtime SHA-256 checksums are:

```text
factor       91420f956f0df1289a8d4c72ee89f25a32af1e97c70551c8abcb787485d15f2b
factor.image 7d5f6792c659aa68a87b50234e9593c96a3dfbe134958ab6aaa3fb11b3b0c347
```

Reproduce from a checkout with a matching VM/image:

```sh
mkdir -p logs/simd-x64/tmp
./factor -q -no-user-init -sse-version=20 reference/simd-x64-audit-20260908/focused.factor
./factor -q -no-user-init -sse-version=42 reference/simd-x64-audit-20260908/suite.factor linear-scan
./factor -q -no-user-init -sse-version=42 reference/simd-x64-audit-20260908/suite.factor chordal global
./factor -q -no-user-init -sse-version=42 reference/simd-x64-audit-20260908/edges.factor
```

Other allocator arguments are `greedy` and `backtracking`; omit `global` for
local value numbering. Logs are kept locally under ignored `logs/simd-x64/`.
Final validation uses an isolated snapshot because unrelated ABI/CI edits
were being made concurrently in the shared checkout.

## Limits and follow-up

- Feature caps select lower-SSE code generation on this modern host. They
  do not establish that the supplied precompiled image boots on old hardware.
- This does not validate native Windows x64, Linux32, ARM64, or another
  floating-point environment beyond the cases in the existing suites.
- Valid shuffle indices were tested. Out-of-range byte indices still differ
  between PSHUFB (high-bit zeroing) and the fallback (index masking); this
  audit does not choose a new public contract for invalid permutations.
- Unsafe raw-vector primitives were not tested with invalid pointers or
  deliberately misaligned SIMD fields. No safety guarantee is added to them.
- Concurrent, unrelated uncommitted ABI/FFI/CI changes are outside the
  isolated snapshot and are deliberately not included in these commits.
