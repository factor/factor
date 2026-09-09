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

## Pending work

Combined checked closures, controlled measurements and fresh bootstrap have not
yet been collected here. This milestone establishes only the four completed
loaded compiler-vocabulary suites. No performance conclusion is claimed.
