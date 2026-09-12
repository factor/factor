# Profiler issue audit — 2026-09-12

Reviewed the six open issues carrying the profiler label. Three older library/UI
issues were still present and are fixed. Stressing the compiler under sampling
also exposed a GC correctness bug in generated safepoints.

| Issue | Result |
| --- | --- |
| [#685: recursive timing](https://github.com/factor/factor/issues/685) | Fixed in `33ec4c4ea2`. Recursive calls retain their invocation count, while overlapping elapsed time is charged once per thread. Exceptional calls are counted and timed too. |
| [#363: missing listener input](https://github.com/factor/factor/issues/363) | Fixed in `ac75861d23`. Quotation commands carry the editor input into the listener log, before the command name. Operations on other objects retain their existing output. |
| [#385: report percentages/filtering](https://github.com/factor/factor/issues/385) | Fixed in `bc8a9ae526`. Reports show each row's percentage of total sampled time across all threads. `profile-minimum-percent` filters small branches without changing that denominator. Expensive siblings were already sorted first; thread rows are now sorted too. |
| [#2747: Windows compiler/profiler failure](https://github.com/factor/factor/issues/2747) | Found and fixed a related, reproducible compiler/GC corruption bug on Linux in `9ec571b10e`. The original Windows failure still needs a Windows retest; the different reported exception is not proof of an identical cause. |
| [#2444: optimized/unoptimized execution](https://github.com/factor/factor/issues/2444) | Still a feature request. Samples retain code owners but not the optimization state of each recorded frame. The JIT column measures time in the non-optimizing compiler, not time executing its output. |
| [#337: sample data in the Factor heap](https://github.com/factor/factor/issues/337) | Already partially implemented by `0590ebf914` in 2016. Callstack owners live in the Factor heap; sample metadata and thread roots still live in native vectors. The corresponding Zig implementation also retains native sample metadata. |

## GC failure and fix

Recording a sampled callstack grows a Factor array. That allocation can collect.
Compiler safepoints were ordinary instructions with no GC map. A collection at
a loop poll could therefore miss references held in registers, and resumed code
could keep stale references. The compiler also failed to preserve other live
register values around the native handler or clear vacant stack slots before
the poll.

The initial 10,000 Hz compiler/compaction run failed with an invalid object
header. A temporary debug-VM probe forced nursery collection when recording
each nonempty sample, reproducing stack-poison reads, crashes and incorrect
array sums. The same loop and compiler workloads pass with the fix.

Safepoints now carry GC maps, use the GC-call preservation path in register
allocation, and participate in stack-slot clearing. Their maps describe the
faulting instruction itself, rather than the address after it. The affected
SSA, chordal and verification paths use the same instruction classification.
This adds register spills/reloads where values remain live across polls; no
performance benchmark was used to quantify that cost.

The debug probe was removed from the source. No change to the native VM or
image format is required for this fix.

## Rebuilding existing code

Refreshing the compiler does not update all previously compiled application
code. In addition, `all-words` excludes anonymous generic methods and dispatch
words. Recompiling only that list left old hashtable machine code in the first
candidate image, which still failed forced collection.

The prepared image recompiles the dictionary words and 21,625 associated
methods/dispatch words. `73ce728217` updates `compiler.test:recompile-all` to
include these subwords. Compiler-definition refreshes were performed with the
optimizer temporarily disabled to avoid calling new compiler predicates before
their compilation unit had finished.

The final image is prepared for the next server restart. The previous executable
and image, with SHA-256 checksums, are backed up in:

```
/tmp/factor-before-profiler-20260912T023116Z-jgl8uk8r/
```

## Verification

* 1,524 checks pass across `compiler.cfg`, `compiler.codegen`,
  `tools.profiler.sampling` and `memory` (exit status 0).
* Timing/annotation tests and 120 listener checks pass. The recursive timing
  regression fails against the old implementation.
* New regressions cover stack clearing at polls, missing root spills/reloads,
  map placement at the poll address, and a floating-point accumulator plus
  array held across sampling polls.
* The temporary debug VM passes forced-collection loop and compiler workloads
  with the rebuilt image. The unmodified native VM passes 20 compilation,
  sampling and compaction iterations at 10,000 Hz.
* Recompilation leaves no compiler errors. Help lint passes for the changed
  profiler, annotation, instruction and register-allocation documentation.

Logs are under `/tmp/factor-profiler-*.log`; the full compiler/GC suite's status
is recorded in `/tmp/factor-profiler-full-tests-final.status`.

Runtime validation was on Linux x86.64. Windows and ARM execution remain
unverified. The running website was not restarted or sent test signals.
