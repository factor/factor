# Compiler tuning: validated worktree integration

Frozen source: `a7f554b613bd763fb7fbfc520643b75b321a6e16`, based on
`c1f7e4d34cd604bbdf22576b237406b39758896d`.
Production is identical to `c6948a99de5ebfb7251c322382dba66d6f8050df`;
the later change corrects a forced-memory test fixture to use runtime inputs.

Linear scan remains the default. GVN and rematerialization remain off by
default. Existing images and already compiled code retain their behavior
until the affected source is loaded and compiled again.

## Changes and isolated attribution

- Identical named-class union/intersection operations bypass allocation of a
  structural cache key. Anonymous classoids retain cache canonicalization.
  Native paired compiler CPU improves 1.32%, retired instructions 1.20%.
- Greedy queries one register's current hint score directly and skips empty
  hint sorts. Native compiler instructions improve 0.45%; the CPU pairs
  straddle zero, so no CPU speedup is established.
- Chordal scans ascending free colors instead of sorting score/color pairs,
  preserving the exact tie rule. Native paired compiler CPU improves 3.01%,
  retired instructions 3.06%.
- Backtracking delegates eligible block-entry transport to the existing SSA
  parallel-edge resolver. The final policy retains a shared successor reload
  when every predecessor already has the value in that reload's spill home.
  Mixed incoming locations can avoid memory round trips. It decides from
  actual post-assignment locations and removes only recorded instruction
  identities, preserving later equal reloads and spill obligations.

These isolated comparisons use two fresh-process B/C/C/B pairs on native
x86 CPU 2. They measure compilation workloads, not bootstrap. Full attribution
and the original backtracking regression are retained in
[the pre-fix report](../compiler-next-20260909/PRE-FIX-RESULTS.md).

## Final validation

The loaded compiler-vocabulary suite passes under all four ARM allocators
with SSA, interval and final-value-flow checking. Linear scan uses
rematerialization off; greedy/backtracking/chordal use it on. The linear-scan
run is retained from production-identical c694; the fixed backtracking fixture
is additionally checked with both flags. This is coverage of loaded compiler
vocabularies, not every test file in the repository.

The ARM selected closure has 27,367 words versus 27,356 at baseline:
13 added helpers/accessors and two replaced phase-assignment wrappers.
The wrappers remain public APIs but are no longer dependency-selected because
the new recording APIs own those call paths. All 26 benchmark entrypoints
remain included. Compiler timing includes the actual changed dependency
closure; it is not an identical-word-list microbenchmark.

ARM backtracking and chordal full benchmark closures pass final checking;
all four allocators pass callback and moving-GC gates. Paired ARM runs retain
all 26 outputs and three measured batches per case in each fresh process.
Native x86 backtracking and chordal checked closures also pass, as do all-four
allocator callback and moving-GC gates. The new backtracking tests are
explicitly loaded and run in the native unit gate.

ARM backtracking against its original baseline: runtime retired-instruction
geomean improves 0.0722%; compiler instructions improve 0.1182%. This is
practically flat overall. FFI improves 1.2854%, integer pressure 1.1451%, and
branch pressure is flat (−0.0378%). Remaining retired-instruction regressions
include SIMD pressure +0.3229% and CSV +0.1825%. Runtime CPU geomean is +5.48%
with opposing rounds (−0.47%/+11.79%); compiler CPU is +9.17%. There is no ARM
CPU-speedup claim.

Native backtracking against its original baseline: runtime retired-instruction
geomean improves 0.0554% and measured CPU geomean improves 1.43%. Compiler
instructions improve 1.315%, CPU 1.651%. FFI improves about 1.55% in retired
instructions and branch pressure is flat. Integer pressure still regresses
1.1264% in both rounds. Untimed checked-compilation captures establish that
both its 208-byte/49-IR-instruction wrapper and its 704-byte arithmetic kernel
have identical emitted bytes, relocations and physical IR at baseline/final.
The difference is almost exactly two retired instructions per inner iteration;
the wrapper also calls generic addition per iteration. The fixnum addition
method and math-generic non-overflow fast path also match. A second pair using
the exact timing compiler flags, with zero measured samples, confirms those
same results. Installed wrapper disassembly after the output checks directly
calls the captured kernel and addition entry addresses. GC relocates code,
so raw installed-address hashes are not stable. Masking only recorded relocation
operand fields establishes that all five captured targets retain their installed
bytes across the output checks; wrapper calls still target the captured kernel
and addition entries. This rules out replacement in those diagnostic processes,
not in the earlier timing processes. The two-instruction-per-iteration
retired-count difference remains unattributed; the entry-transport change is
not established as its cause. Aggregate figures do not erase the measured regression.

A separate native chordal compilation bracket compares pre-correction ecc /
final a7 / ecc. Final retired work is 0.775% above the bracketing baseline
mean; CPU is 0.248% higher with visible baseline variation. The closure also
includes newly introduced helpers, so this measures the correction's overall
compilation cost rather than isolating steady-state assignment-hook overhead.

The first final attempt caught a fixture error with rematerialization on:
its constants became recipe locations and violated its forced-memory premise.
The corrected fixture uses runtime inputs; allocator and verifier were unchanged.
The old fixture fails as a negative control; the corrected explicit backtracking
test subtree passes under both rematerialization settings.

Full final ARM records and per-case tradeoffs are in
[the ARM audit](../compiler-next-final-arm-20260909/RESULTS.md).
Native records and the exact-configuration diagnostic are in
[the native audit](../compiler-next-20260909/corrected-native/final-a7/README.md).

## Default bootstrap: two-minute target unmet

The final source bootstraps and verifies a separate default linear-scan image:
**3:19 core / 203.912 seconds whole process / 202.502 CPU seconds**.
It retires 1.80515 trillion instructions. The earlier accepted 1:52 bootstrap
retired 1.80021 trillion, only 0.274% fewer, while its CPU time was much lower.
This result does not identify the cause of the changed execution rate and
does not meet the requested wall-time budget. The unchanged contemporary
baseline previously took 3:07 core, also above budget.

The final image is `compiler-next-integration/compiler-next-final.factor.image`
in the separate worktree. The root `factor.image` remains unchanged.

## Remaining opportunities

These are unpromoted follow-up targets, not measured gains from this round:

- Investigate compilation-local reuse of class information in tree propagation,
  after proving mutation and class-redefinition lifetimes are safe.
- Skip chordal spill-victim sorting when pressure has no excess, while retaining
  mandatory-capacity checks. Measure frequency and exact output equivalence.
- Improve chordal loop-phi affinity assignment. An unpromoted recoloring
  diagnostic reduces spectral-norm IR copies from 92 to 58, but still needs
  actual emitted-code and runtime validation on both architectures.
