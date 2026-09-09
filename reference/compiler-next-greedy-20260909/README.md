# Greedy hint-query work reduction

Baseline: `c1f7e4d34c`, with linear scan still the default allocator.

The preceding native 26-workload matrix put greedy at 1.0072 times linear
scan's geometric-mean execution CPU and 1.0493 times its compiler CPU.
This change targets redundant compiler work without changing allocation
policy, spill placement, or generated-code expectations.

## Baseline diagnostic

An instrumented compilation of the same prepared native x86-64 benchmark
image's 28,489 actual word objects counted:

| Operation | Count |
| --- | ---: |
| Full hint-score maps built | 2,102,677 |
| Empty score maps | 2,055,918 (97.78%) |
| Single-register score queries | 1,815,904 |
| Register-order sorts | 286,773 |
| Sorts with empty score maps | 284,701 (99.28%) |
| Register entries sorted with empty scores | 3,424,881 |

`hint-frequency.factor` mirrors the original implementation and adds
counters. Its run time is instrumentation overhead, not a performance
measurement. Native execution uses global numbering off, rematerialization
and loop placement on, and allocation checks off. The native agent retains
the exact executed overlay, launcher, and raw output independently. As the
closure includes the instrumented hint words themselves, these are
diagnostic counts rather than an uninstrumented execution trace.

## Change and policy preservation

Single-register queries now sum only contributions to that register,
without constructing a temporary hash table. They read current physical
assignments every time; eviction and recoloring introduce no cache
invalidation requirement.

Register ordering immediately returns the original bank order when an
interval has no split or copy hints. If hints exist but none produces a
score, it also skips sorting. Factor's stable sort previously preserved
this same bank order. Nonempty scores continue through the existing scorer
and stable sort. The full score-map implementation is unchanged.

The differential tests compare scalar scores and exact register order
against that original implementation after assignment, eviction,
reassignment, recoloring, rollback, and splitting a peer into fragments.
They cover additive duplicate hints, split hints, inclusive endpoints,
requester and peer holes, unassigned peers, an out-of-bank hint, and a
vector-backed bank with deliberately reversed order.

## Validation

All 75 ARM greedy and region subtree unit-test invocations pass across
rematerialization off and on,
including the differential mutation tests and an assertion that scoped
fixtures restore the caller's enabled rematerialization setting. The run
used the matching VM and fresh tuning image with `refresh-all`; raw output
is retained in `arm-tests.log.gz`.

## Native isolated result

Candidate `c81ec7fefc` was compared with logical baseline `c1f7e4d34c`.
The executed baseline source was `5c848c90f6`, whose basis/core/extra/vm
trees are identical to that logical baseline. Both used the same retained
prepared image, identical selective greedy reload/preparation, and the
same ordered vector of 28,489 actual word objects, including the two
redefined production words. No diagnostic counters were enabled.

Four fresh timing processes ran in baseline/candidate/candidate/baseline
order, pinned to native x86-64 CPU 2. Compilation was timed once per
process; the three samples per process apply to runtime workload batches,
not to additional compiler measurements.

| Round | Baseline compiler CPU s | Candidate compiler CPU s | Baseline instructions | Candidate instructions |
| --- | ---: | ---: | ---: | ---: |
| 1 | 48.514933 | 48.604692 | 596,235,212,170 | 593,366,063,897 |
| 2 (reversed) | 48.662180 | 48.353198 | 596,235,192,908 | 593,789,422,506 |

Aggregate candidate/baseline compiler ratios are **0.995543 retired
instructions** (0.446% less work) and **0.997744 CPU time** (0.226% lower).
Instruction reductions agree across rounds: 0.481% and 0.410%. CPU changes
straddle zero: 0.185% slower and 0.635% faster. Therefore the result supports
a small compiler-work reduction, with no persuasive CPU-time improvement.

All 26 workload outputs match, including 52 checked outputs before timing
and every measured batch; all 12 kernels' non-timing code reports match in
both pairs. This establishes unchanged observed workload behavior/static
metrics, not bitwise identity of every method in the full compiler closure.
The two deliberately changed compiler words themselves may generate
different code.

Exact accepted counters, raw rows/statuses, source manifests, and preparation
records are in [the native result archive](../compiler-next-20260909/native-greedy/summary.json)
and its baseline/candidate directories. The independently reproduced audit
is retained by the comparison worktree at
`reference/compiler-next-20260909/independent-native-audit/native-greedy/`.
No allocator default or placement policy changed. Remaining greedy runtime
pressure differences are outside this cost-only change.

A separate [bootstrap-rate diagnosis](BOOTSTRAP-RATE.md) addresses combined
candidate timing variability; it is not an isolated greedy measurement.
