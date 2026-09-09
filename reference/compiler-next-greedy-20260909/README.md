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
the exact executed overlay, launcher, and raw output independently.

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

ARM greedy and region subtree tests pass with rematerialization off and on,
including the differential mutation tests and an assertion that scoped
fixtures restore the caller's enabled rematerialization setting. The run
used the matching VM and fresh tuning image with `refresh-all`; raw output
is retained in `arm-tests.log.gz`.

Paired native compile results are pending. No speedup is claimed by the
diagnostic counts alone.
