# Compiler next2 ARM evidence

Frozen source: `87ac3f9b1e19a9bee974a52d263f7abce4b61c34`.
Baseline source: `1d67bdd034110a385286179974f3bcaef77b35ba`.

## Loaded compiler-vocabulary suites

All four completed with exit 0, no timeout, `TEST-FAILURES 0`, and the
explicit success marker. The harness invokes `"compiler" test`, which tests
loaded compiler child vocabularies; this does not claim every filesystem
compiler/test vocabulary. It explicitly loads the allocator implementations,
enables SSA, interval and final value-flow checks, and disables GVN. Loop spill
placement is on. Rematerialization is off for linear scan and on for the other
three allocators. The exact harness and queue driver are retained.

| Allocator | Elapsed seconds | Result |
| --- | ---: | --- |
| linear-scan | 115.58 | PASS |
| greedy | 120.93 | PASS |
| backtracking | 110.99 | PASS |
| chordal | 118.82 | PASS |

These are correctness gates, not controlled performance samples. Their elapsed
times must not be interpreted as allocator or optimization speedups.

`collect.py` only archives a run after `status.json` exists. It checks the exact
frozen clean source, command flags, executable and input image hashes against
`frozen-assets.json`, plus explicit result markers. `suite-audit.json` records
each predicate. Per-run environment, final status, sampled counters and compressed
stdout are under `loaded-compiler/`. Expected missing-library diagnostics in the
FFI negative tests are retained, alongside the final zero-failure result.

`frozen-source-trees.json` records the baseline and current tree objects;
`inherited-baseline-source-equivalence.json` documents earlier baseline equivalence
and is not the provenance of this new freeze. The input image is cloned into the
integration worktree; the runs refresh changed vocabularies before testing.

## User-requested stopping point

Preparation completed with explicit status 0 in 3.038 seconds. Its status records
frozen source `87ac3f9b1e19a9bee974a52d263f7abce4b61c34`, input image SHA-256
`beb3fba75cf0895272c906db69b76c5d320cb9c85c7af07fba676b7de2813224`
and prepared image SHA-256
`dd9db27596600af92c5a74d4c2689fbec2c208781779aede97f03a4e089ec4fb`.
A final taskpolicy retry reported no such process; the preparation's actual exit
status is 0. Exact scripts, status and source markers are under `preparation/`.

The final linear-scan checked-closure log contains all 40 expected payload rows:
one checked scope, one compile, twelve code reports and twenty-six runtime output
records. It reports the frozen source with rematerialization off, loop spills on
and GVN off. However, the driver never saved its terminal `.status.json` or
`.jsonl`; disappearance of its child PIDs is not an exit-status proof. This run is
therefore **incomplete for acceptance**, not a passed closure. The original log,
separately named archive-derived JSON records, source guard, exact launch/driver,
and explicit audit are under `stopping-point/`.

At the user's requested stop, subsequent chordal closure, paired ARM default
compiler measurements, callback/moving-GC gates, fresh bootstrap and image check
were not run in this pipeline. The retained queue script describes planned work,
not evidence that every command executed. No combined ARM performance or fresh
bootstrap claim is made. The four completed loaded compiler-vocabulary suites
above remain the accepted ARM correctness milestone.
