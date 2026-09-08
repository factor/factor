# master-candidate x64 audit — 2026-09-08

Scope: the 142 commits in `origin/master..3f94e11027`, reviewed by their final
source changes, plus the committed fixes listed in `fix-commits.txt` and the local
`final-working-tree.patch`. The source hashes in `final-source-manifest.json`
match both final validation worktrees. `commits.txt`
records the history and `audit-files.tsv` maps all 346 changed files to review
areas, with hashes for both the original `3f94e11027` snapshot and the final
`c458cd1558` code snapshot. This is an audit of the net patch set, not a proof that every behavior
is correct.

This Mac is ARM64. x64 macOS tests run through Rosetta; native ARM64 checks
provide parity comparisons. The user's ARM64 executable and image are retained.
The baseline worktree is `/Users/erg/factor-x64-validation`; the initial fixed
worktree is `/Users/erg/factor-x64-fixed`. Final float work is validated in
`/Users/erg/factor-floats-validation` (x64) and
`/Users/erg/factor-arm-validation` (native ARM64).

## Findings fixed

- SIMD nearest rounding: preserve infinities, signed zero, halfway behavior,
  values immediately below a half, and already integral doubles above 2^52.
- SIMD extrema: use minimum/maximum-number semantics in float/double vectors,
  half-vector fallbacks, and reductions. Equal opposite signed zeros select
  negative zero for minimum and positive zero for maximum. NaN payloads remain
  unspecified. Integer min/max retain their native lowering.
- SIMD lowering: ordered comparisons and integer bitwise masks keep floating
  extrema in vector code. Tests verify native vector instructions are present.
  Reductions preserve numeric lanes even beside signaling NaNs.
- Native stack entry: probe 4 KiB of x64 callstack headroom in generated Factor
  code before entering C. This prevents Rosetta from faulting midway through
  a translated native prologue. The C++ callstack has a 64 KiB guard reserve
  unlocked during GC; a single 4 KiB page was insufficient for dyld symbol
  lookup during compacting GC. Segment allocation/free/guard ranges agree on
  Unix and Windows, and the exposed three-field segment prefix is preserved.
- Mach exceptions: read/write floating-point register state only for FP traps.
  Rewriting unchanged FP state at sampling safepoints triggered Rosetta's
  `host_fpr_state_from_guest_state` assertion.
- Zig code-block snapshots: initialize the result before a possible retry so
  discarded tenured arrays have valid pointer slots. The new regression forces
  collection and code-count shrinkage with poisoned reclaimed storage. It
  fails before the fix and passes after it, then exercises an aging GC.

## Float issue follow-up

All 15 open `floats` issues were inventoried. `FLOATS-ISSUES.md` records the
implementation, commit, tests, and limits for each. Fixes include Dragonbox
cache/rounding boundaries, NaN encoding transport, ordered comparison
primitives, indeterminate powers, integer range membership, nested shaped
arrays, complex literals, and exact literal conversion folding. Documentation
clarifies object equality and signed zero. The proposed Box–Muller normal
generator is already present. Windows UCRT and Linux32 regressions have
portable tests here but still need native platform validation.

## Audit areas

C++ and Zig runtime review covered moving-GC roots, derived pointers and retries,
code-block and object snapshots, PIC miss/resume frames, integer normalization,
unaligned alien access, immediate decoding, image version/layout, and context
and guard lifetimes. The snapshot initialization fix had been applied only to
C++ and was missing from Zig.

Compiler review covered hidden structure return parameters and nested callback
result areas, vector ABI boxing, derived-root liveness through copies/parallel
copies, atomic spill ranges, register coalescing, instruction/helper refresh,
conditional dependency invalidation, literal bignum preservation, checked call
effects, and row constraints across recursion and quotation boundaries.

SIMD review covered feature dispatch, unsupported-operation fallbacks, integer
shift boundaries, widened products, mask predicates, two-vector shuffle bounds,
FP16/BF16 storage and conversions, fused arithmetic, and optional dot/matrix
kernels. The independent integer corpus in `integer-parity.factor` uses Python
integer arithmetic and a fixed RNG seed for expected results across signed and
unsigned lane sizes, with ordinary and forced intrinsic compilation.

Core/library review covered callable words versus quotation sequences, fried
quotation parsing and lexical substitution, nested compilation units and cache
invalidation, file endings and executable search, regexp captures/lookaround,
Cocoa input/display-scale/resource invalidation, debugger/walker integration,
and the remaining library/tooling changes. Host UI tests do not substitute for
interactive multi-display testing or execution on Windows/Linux/Intel hardware.

## Validation

Final results are recorded in `RESULTS.md`. The first complete corrected x64
sweep finished in 2,725.95 seconds with zero compiler errors and 26 FP-trap
failures, all explained by the Rosetta limitation below. The later float fixes
receive a separate fresh-image validation; the earlier sweep does not stand
in for those results.
The baseline load-all passed (3,401 loaded vocabularies, zero compiler errors).
Its test-all stopped at the reproduced Rosetta sampling assertion; it was not
a completed green sweep. Missing libraries and database configuration in that
baseline were supplied for the final run.

Libraries are isolated under `libraries/` with downloaded bottles checked
against Homebrew SHA256 metadata. PCRE2 and libjpeg-turbo were compiled for x64;
universal Postgres.app libraries supply several remaining dependencies. The
validation PostgreSQL cluster is local, bound to 127.0.0.1:64578.

The independent SSE C probe `fp-trap-probe.c` enables division-by-zero traps
but returns infinity under this Rosetta installation instead of SIGFPE. It
confirms a host limitation separately from Factor. FP trap failures are not
removed from the standard test suite or reported as passing.
