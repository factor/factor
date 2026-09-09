# Integrated compiler checks and default bootstrap

Initial compiler-suite candidate: `29b4551bb3`. Corrected candidate:
`30a50ab0df`. The final full compiler and documentation checks below pass on
the corrected source; fresh benchmark closure checks and paired comparisons
follow this gate.
No allocator is promoted by these correctness results alone.

- Full compiler suite, linear scan selected, rematerialization off: passed with
  SSA, interval and final-machine value-flow checks (62.42 seconds).
- Full compiler suite, chordal selected, rematerialization on: passed with the
  same checks (46.29 seconds), after the callback repair below.
- The shared moving-GC tests cover all four public kernels, both raw-derived and
  tagged-base phis, both rematerialization settings, and reduced register banks.
  An independent caller-rooted object oracle validates relocation. Removing the
  required derived-root map now fails the symbolic checker too.
- Native x86 dispatch, coloring, moving-GC and active-rematerialization artifacts
  are in `../allocator-full-comparison-20260908/native-x86-audit/`.

The initial chordal-on combined run failed in a synthetic greedy fixture whose
rematerialization setting was not isolated, and in actual large-return C callback
compilation. The latter exposed a register-valued repair phi introduced into a
call block that skips register assignment. The live hidden result pointer already
had an ABI memory home; `d2dcefae16` keeps call-block entry values memory-only.
Actual callback tests cover both flags, compacting GC and nested callbacks. The
initial failing log is preserved separately from the corrected passing log.

## Default cold bootstrap

The frozen candidate bootstrapped successfully and its fresh saved image passed
zero-compiler-error, linear-scan/GVN-off/rematerialization-off assertions plus
integer, float, loop and moving-GC smoke tests. The main checkout/image was not
changed, and the saved image is not used as the comparison's common input seed.

| Measurement | Frozen candidate |
| --- | ---: |
| Core bootstrap report | 3:11 |
| Whole process | 195.65 s |
| Final sampled process CPU | 192.66 s |
| Final sampled retired instructions | 1.791690 T |
| Final sampled cycles | 490.230 B |

This does **not** meet the requested two-minute limit. Compared with the earlier
prototype `4daa778a6b` (also a 3:11 core report), sampled instruction work increased
only 0.134%. Compared with the earlier 1:57 default observation, the increase is
about 0.96%; the much larger CPU-time difference reflects a changed execution
rate and cannot be attributed to equivalent growth in compiler work.

The VM and seed match the earlier prototype bootstrap. This run explicitly used
`taskpolicy -a -t 0 -l 0` for application resource policy plus the runner's periodic
`taskpolicy -B` on its own process. This did not restore the historical execution
rate. It is not a matched scheduling-policy timing comparison with the older run.
A read-only post-run power check showed AC power, normal power mode, and no
recorded thermal/performance warning; that does not identify the scheduling or
frequency cause. No unrelated host process or system power policy was changed.

Exact commands, source/VM/image hashes, process samples and logs are retained in
the adjacent directories. Process samples can precede exit; validation durations
are not runtime benchmark measurements. The paired benchmark images continue to
use the original common per-architecture seed specified in the comparison runbook.

## Subsequent backtracking callback failure

The full compiler suite at `84a10fe6be` (the integrated phi/GC-prefix repair)
failed in native ARM64 execution of the large-struct-return C callback:
`large-return-callback [ ffi_test_large_return_callback ] with-callback`.
The VM reported a memory protection fault at address `0x180`, with
backtracking, rematerialization and loop spills enabled and all allocation
checks active. A second verbose run isolated the same callback. Both original
logs, exact source/assets and process status are retained in the adjacent
`backtracking-prefix-suite-*` directories. These are rejected acceptance runs;
the callback repair and a corrected full-suite pass are required before timing.

## Corrected final compiler gate

Candidate `30a50ab0df` passes the full `compiler` suite with backtracking,
rematerialization and loop spilling enabled, GVN off, and SSA, interval,
operand and strengthened final value-flow checks active: **zero test failures**
in 61.22 seconds. This supersedes the rejected callback runs above.

The integrated repairs preserve representations in greedy fragments, emit
backtracking transitions before phi removal and GC saves, keep spill tails
inside their original live ranges, exclude skipped call blocks from second
chances, and reload memory homes at call successors. The verifier now
invalidates allocator registers across ordinary Factor calls.

All four allocators with rematerialization off/on pass the native ARM64
large-struct-return callback fixture: 40 ABI assertions, with exact evidence
in `../allocator-full-callback-20260908/`. The independent checker regressions
retain an old-checker negative control in `call-clobber-verifier/`.

Selection and greedy documentation lint passes with zero compiler errors
on the same source (4.16 seconds). Neither result is a runtime measurement.
The final comparison uses immutable source `30a50ab0df` and the same native
VM/input image as its repaired prototype baseline. Later evidence-only
commits on this integration branch do not change the measured source.
