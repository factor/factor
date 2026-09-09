# ARM64 variadic C ABI implementation

Baseline: `233db947df`.

## Implemented

- Direct and indirect outgoing variadic calls, including Windows GP transport
  of floating-point/vector payloads and aggregate register/stack boundaries.
- `CALLBACK: ... ( named, ... )` with a runtime argument cursor, and callbacks
  whose anonymous tail is declared explicitly after the ellipsis.
- `va-arg`, independent `va-copy` positions, native `va_list` callback parameters,
  and repeated or partially consumed forwarding to C. Cursors expire on normal
  and exceptional callback exit and reject another callback or Factor thread.
- Dedicated ARM64 callback capture in both C++ and Zig VMs, preserving integer
  and SIMD argument banks, stack arguments, hidden results, and moving GC.
- C default promotions retain source bool/enum conversion, narrow integer
  wrapping, and binary32 rounding before widening.
- Natural alignment is retained for indirect copies, hidden return buffers,
  SIMD first members, and macOS anonymous aggregate groups.
- Shared layout-based HFA/HVA classification handles overlapping unions,
  padding, arrays, mixed vector lane types, and concrete half/BF16 carriers.
- Raylib, libudev, curses, and GObject use the canonical native list type.
- Native compiler-qualified CI lanes on Linux, macOS, and Windows; genuine
  printf/snprintf/vsnprintf coverage; required fixture/capability checks.
- Older compatible version-5 seed images receive the new compile-only word and callback
  template during stage2. Existing ordinary callback template items are retained.

The cursor reads the C API's caller-specified protocol; it cannot discover a
missing argument, its type, or the end of a list. These changes cover existing
supported FFI C types on ARM64, not an expansion to every possible C type.

## Verification

The final validation image is `final.image` in this directory, used with the
rebuilt C++ VM at `/Users/erg/factor.worktrees/arm64-varargs-entry/factor` and
`-resource-path=/Users/erg/factor`. Generated images and libraries are deliberately
excluded from the commits. Production builds use the normal bootstrap path.

- Full compiler suite: zero test failures and compiler errors with SSA and
  register-allocation validation. `compiler.factor` pins subprocess tests to the
  same isolated runtime/image/source via `verified-factor`; otherwise those two
  tests accidentally launch the worktree's older default image.
- All four allocators, with global value numbering enabled: zero failures and
  compiler errors across the old and new native FFI matrix.
- Clang 23 CI check: normal and disabled optional extensions pass, including
  required half/BF16 controls and exact real printf bytes/counts.
- Help lint passes for alien, the cursor vocabulary, and FFI syntax.
- Six intentional CI/printf failures return exit 1; see `negative-controls/`.
- Complete native macOS stage2 from an older compatible version-5 seed, restart checks, and subsequent
  C-backed incoming/outgoing tests pass; see the bootstrap compatibility evidence.

Additional final platform and suite results are recorded in `RESULTS.md`.

## Regression evidence

- `README.md`: independent C callers/readers, parser and missing-feature baseline,
  zero anonymous arguments, spills, aggregates, GC, nested callbacks, formatting.
- `unions/`: 19 numeric baseline failures, a cursor fault for a large vector union,
  and additional half/BF16 carrier regression; corrected cases pass native C FFI.
- `../arm64-varargs-promotions-20260908/`: 15 of 18 checks fail before promotion
  repair; all 18 pass afterward.
- `../arm64-varargs-entry-20260908/`: capture and relocation failure before the
  dedicated entry stub, then native register capture and compacting GC pass.
- `../arm64-varargs-outgoing-20260908/`: executable Windows ABI/compiler oracles,
  incoming and outgoing cases, and actual PE DLL export-table checks.

## Qualification limits

Native macOS ARM64 execution and Linux ARM64 under QEMU are verified here.
Both Clang Linux modes pass 189 unit reports and 15 expected-failure reports,
including the dedicated promotion/union drivers, final alignment changes, and
required half/BF16 controls. GCC passes 177 unit reports and 15 expected-failure
reports, with half/BF16 explicitly unavailable. Four actual printf subprocess
checks pass for each compiler. Native Linux and Windows remain unverified here;
CI defines native lanes. See `RESULTS.md` for the exact qualification limits.
Windows Clang has independently reproduced C-to-C defects for an aggregate split
at X7 and a standalone vector variadic caller. The split C control is explicitly
gated for that compiler, while the Factor-to-C split assertion remains enabled on
ARM64. The 32-byte vector aggregate control is independently passing. See the
outgoing evidence for exact cases and compiler versions.

GCC 15 at `-O2` produces 17 instead of 53 in one independent C-only vector-union
variadic control. Disabling strict alias optimization or annotating that fixture
union with GCC `may_alias` restores 53; size 32 and alignment 16 are unchanged.
The Factor callbacks pass even before this fixture annotation. The narrow
GCC-only annotation keeps the C control enabled with its original expectation;
the Linux evidence records the discrepancy and the final compiler runs.

On x86, new callbacks/cursors are outside this ARM64 implementation. A pre-existing
SysV aggregate-varargs boundary defect was reproduced in the untouched old image;
the new ARM64-specific boundary assertion is scoped accordingly, with baseline
evidence retained. This is not an unqualified claim of complete C ABI support on
all architectures.

The current official master download was also checked and is still version 4;
this repository already requires version 5. Consequently default download-based
CI remains blocked before source loading until a compatible seed is supplied.
The implemented callback compatibility upgrade does not bypass image version
checks. Exact artifact hashes and the released-host experiment are recorded in
`../arm64-varargs-bootstrap-compat-20260908/README.md`.
