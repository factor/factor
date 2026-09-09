# Chordal compiler tuning, 2026-09-09

Baseline: `c1f7e4d34cd604bbdf22576b237406b39758896d`. This worktree uses
the matching allocator-tuning-final-candidate VM. The original-image phase
audit and fresh-image correctness/probes record their exact image hashes in
their runner metadata. Every startup runs `refresh-all` with an explicit
resource path. Default allocator and optimization flags remain unchanged.

## Exact preference selection

The first phase audit measured twelve existing metric kernels five times.
Preference coloring accounted for 284 ms, maximum-cardinality ordering 76 ms,
and next-use analysis 43 ms in aggregate. These are nested instrumented wall
times, not whole-compiler CPU measurements. They selected preference coloring
as the first bounded optimization target.

The previous implementation sorted every free color by the pair
`[-preference_score, color]` and selected the first. `preferred-free-color`
instead scans the ascending free-color sequence and accepts only a strict
score improvement. It therefore retains the smallest color on ties, including
zero and rational scores, without comparison-pair allocation or sorting. The
free-color construction, affinities, scores, MCS order, interference graph,
bank-exhaustion error and physical transport are unchanged.

Independent tests in commit `4b92aea27f` compare 240 selector cases and 3,072
complete maps/exhaustions against the original lexicographic sort. The real
corpus gate additionally compares all 16 CFG color maps produced by twelve
metric kernels and requires a positive invocation count. SSA and final-value
checks are enabled. The chordal subtree, including its native execution
fixtures, passes with the original-sort comparison installed.

The first corpus gate used a namespace-local integer counter, whose increments
were discarded when compiler scopes exited. Its assertions passed, but its
printed count was zero. `exact-color-corpus` is the corrected run using a shared
mutable counter and an explicit positive-count assertion; it reports 16.

`paired-profile.factor` compares both implementations in one process in
old/new/new/old order, measuring twelve kernels per round:

| Round | Selector | Aggregate coloring wall time |
| --- | --- | ---: |
| 1 | Original sort | 47.075 ms |
| 2 | Ascending scan | 12.680 ms |
| 3 | Ascending scan | 11.662 ms |
| 4 | Original sort | 43.843 ms |

Every generated-code byte vector matches. Raw data and a parsed summary are
under `paired-color-profile`. This establishes a substantial reduction in the
targeted phase's work; a whole-closure CPU/retired comparison is still required
before claiming an end-to-end compiler speedup. It is not a runtime-code change.

## Separate runtime investigation

The latest native matrix identifies spectral norm as a stronger remaining
runtime target than the pressure kernel: chordal retires about 40% more
instructions than linear scan on x86 and 49% more on ARM. The diagnostic script
records loop phi color mismatches, interference blocking and direct recoloring
gain, then the final physical CFG. It does not change allocation policy.
Further runtime policy changes must be reviewed and measured separately from
the exact-selection optimization.
