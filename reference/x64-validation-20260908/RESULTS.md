# master-candidate validation — 2026-09-08

Full-sweep code snapshot: `c458cd155876cf3ec9870e95f6d7de4c476051f2` on `master-candidate`.
The 21 code/test/documentation commits in that snapshot are listed in
`fix-commits.txt`. The later stack-pointer correction is recorded below.
`final-source-manifest.json` verifies that all 49 changed files match the
committed snapshot in both final validation worktrees.

The host is ARM64 macOS. x64 runs use Rosetta; ARM64 runs are native. The user's
original root ARM64 executable and image are retained. No changes were pushed
and no GitHub issues were closed or commented on.

## Scope and findings

`AUDIT.md` describes the review of the 142 incoming commits and 346 changed
files in `origin/master..3f94e11027`. The review covered the final net changes;
it is not a proof of every possible execution of every historical patch.
`FLOATS-ISSUES.md` records the disposition of all 15 open `floats` issues.

Fixes cover SIMD rounding and numeric extrema, native vector lowering,
callstack headroom, Mach sampling safepoints, Zig GC snapshot initialization,
Dragonbox formatting, NaN bit transport, comparison exception semantics,
power edge cases, shaped arrays, range membership, complex literals, and
literal float conversion folding. The existing Box–Muller generator already
implements the algorithm proposed by its issue.

## Final fresh-image validation

| Check | x64 through Rosetta | Native ARM64 |
| --- | --- | --- |
| Fresh boot-image generation and bootstrap | Pass; 401.03 s | Pass; 164.90 s |
| `load-all` | 3,403 vocabularies; 0 compiler errors; 1,080.27 s | 3,397 vocabularies; 0 compiler errors; 531.69 s |
| `help-lint-all` | 0 failures; 26.48 s | 0 failures; 14.22 s |
| Final `test-all` | 1,249 test files; 28 failures (26 FP traps, 2 signal timeouts); 0 compiler errors; 2,020.99 s | **1,247 test files; 0 failures; 0 compiler errors**; 1,583.25 s |
| Final C++ stack safety, including GC at measured stack boundaries | All 5 tests pass; 192.70 s | All 5 tests pass; 104.12 s |

Timings are observations from a shared, busy machine, not controlled performance
comparisons. The full test scripts keep ordinary tests and FP-trap expectations
enabled; they do not skip failures to obtain a green result.

- Final SSE2-only SIMD, conversion, and compiler intrinsic suites: **0 test
  failures, 0 compiler errors** (`final-simd-sse2.log`).
- Final Zig x64 float, parser, math.functions, SIMD, conversion, and compiler
  intrinsic suites using the fresh C++ image: **0 test failures, 0 compiler
  errors** (`final-zig-floats.log`).
- C++ GC unit tests rebuilt from the final code: **pass**
  (`final-cpp-gc-tests.log`).
- Zig unit suite: **61 passed, 1 skipped**, including the forced-GC snapshot
  regression and exhaustive NaN encodings (`comparison-zig-unit.log`).
- Final Zig stack safety: **all 5 tests pass**, 191.19 s
  (`final-zig-stack-safety.log`).

The first ARM64 full-sweep attempt was stopped after its Cocoa launch regression
exposed an executable placed outside the application bundle. That validation
layout was corrected and the complete sweep restarted. Its partial log is
`final-arm-test-all-before-bundle.log`; it is not a completed test result.
The first final ARM help lint found an `fpow` output-name mismatch, fixed in
`c458cd1558`; the recorded passing rerun includes that correction.

The final x64 sweep additionally exposed two `unix.signals` timeouts after
sampling-profiler tests. A focused profiler→signals sequence reproduces these,
and a separate diagnostic reproduced a Rosetta failure restoring general
register state (`unable to set arm gpr state`). Follow-up validation of the
POSIX signal path completed, but did not establish a safe workaround; the
completed sweep above is not green.

### Follow-up signal investigation

- `e063144be6` corrects `UAP_STACK_POINTER` to read the interrupted SP from
  the saved registers. `uc_stack.ss_sp` describes the alternate signal stack.
- An experimental POSIX-only x64 build passed all five stack-safety tests
  (284.99 s, `posix-stack-safety.log`) and one complete profiler→signals run
  (`signals-profile-posix.log`).
- Native ARM64 with the corrected macro passed profiler→signals, with zero
  test failures and compiler errors (`signals-auto-arm.log`).
- A subsequent POSIX-only x64 run passed signal delivery but failed two
  profiler tests: a callstack overflow and a missing-sample expectation
  (`signals-auto-x64.log`). Another diagnostic run also missed a sample.
  Automatic POSIX selection under Rosetta was therefore **not committed**.
  The existing Mach handler remains enabled.
- The full suites above predate the isolated stack-pointer correction. The
  launchers still use their fully swept VM binaries. No second full sweep
  is claimed for the follow-up.

The two signal timeouts and intermittent Rosetta profiler behavior remain
unresolved. Experiments and logs are retained for further investigation.

## Additional independent checks

- **16,138** binary64 exponent-boundary/random values round-trip to identical
  bits in Factor on both architectures. Before the fix, four values exceeded
  the Dragonbox cache and eight others formatted one ULP away.
- Python independently parses all **16,138** final decimal outputs to their
  original bits. None uses more significant digits than Python's shortest
  representation. ARM64 and x64 produce byte-for-byte identical output
  (`decimal-oracle-{arm,x64}.{txt,json}`).
- The expanded parsing benchmark checks **100,000** unit-range values and
  **100,000** random values from the full finite binary64 range on each
  architecture, using exact bit equality instead of approximate comparison.
- All **16,777,214** signed float32 NaN encodings preserve their sign, payload,
  and signaling/quiet bit through widening and narrowing in C++ ARM64/x64 and
  Zig. Factor tests also exercise compiled and primitive bit transport.
- The independent integer SIMD corpus contains **132** forms across eight
  integer lane types, including extrema, widening multiplication, shifts, and
  absolute differences, using ordinary and forced intrinsic compilation.
  Both architectures pass.
- SIMD floating and signaling-NaN suites pass ARM64, x64 SSE4.2, and x64 SSE2;
  compiler tests assert that native vector instructions are actually emitted.
- Dynamic ordered/unordered comparison primitive tests pass C++ ARM64/x64 and
  Zig x64. Native ARM floating exception flags and sampling-profiler tests pass.

See the issue ledger for focused suite filenames and platform-specific limits.

## Earlier baseline and corrected sweep

| Check | Result |
| --- | --- |
| Original x64 `load-all` | 3,401 vocabularies, 0 compiler errors |
| Original x64 `test-all` | Stopped after reproducing a Rosetta sampling assertion; incomplete |
| First corrected x64 `load-all` | 3,401 vocabularies, 0 compiler errors; 713.44 s |
| First corrected x64 `test-all` | Completed in 2,725.95 s; 26 FP-trap failures, 0 compiler errors |
| First corrected help lint | 0 failures |
| C++ stack safety before the later float work | All 5 tests passed on x64 and ARM64 |

Every failure in the first completed corrected sweep was in
`math.floats.env`'s enabled-trap tests. The independent C probe
`fp-trap-probe.c` enables an SSE division-by-zero trap but returns infinity
under this Rosetta installation instead of delivering SIGFPE. This host
limitation is not hidden by changing or disabling Factor's tests.

## Reproduction and retained artifacts

- x64 checkout: `/Users/erg/factor-floats-validation`.
- ARM64 checkout: `/Users/erg/factor-arm-validation`.
- Local launchers beside this report: `factor-x64` and `factor-arm64`.
- Fresh base images: each checkout's `factor.image`; loaded images:
  each checkout's `loaded.image`.
- Full command lines, exit status, and timings are recorded in
  `final-*.json`; output is in matching `.log` files.
- Drivers: `run-final.py`, `run-final-arm.py`, and `final-*.factor`.
- x64 third-party libraries are isolated under `libraries/`, with Homebrew
  bottle hashes verified and PCRE2/libjpeg source builds retained. Native
  ARM64 uses the existing Homebrew installation.
- Database tests use separate local PostgreSQL clusters on ports 64578 and
  64579 so the two suites do not share test databases. Both test clusters
  were stopped after validation.

Native Windows/UCRT, Linux32/VMware, and physical Intel hardware have not been
executed here. Their regression tests remain enabled for subsequent builders.
