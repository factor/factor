# Independent preference-color oracle

The targeted ARM correctness gate passed with exit 0 on 2026-09-09. It ran 240 selector comparisons, two fixed tie expectations, and 3,072 complete-map or explicit-exhaustion comparisons. Every undirected four-vertex graph is combined with six sparse/weighted affinity patterns, two vertex orders and capacities 1 through 4. Conflicting affinities, fractional weights, absent scores and out-of-bank scores are covered.

The oracle retains the previous lexicographic sort rule and its full coloring loop. It shares affinity-component construction with production because this change only replaces color selection. This is a differential corpus, not a proof of the allocator or evidence of a speedup.

Peer source SHA-256: `07ad63902e97af2aa99e8796832206e735e7d4c78ad31baa9a644c3f1141eb45` (compiler-next-chordal chordal.factor). The gate explicitly requires that vocabulary, then loads a frozen copy before loading these independent tests; it does not rely on the prepared image containing the new helper. The environment JSON records the exact command, image and executable. The gate's absolute paths record this run; for a new run, freeze the intended peer file, adjust those paths and verify its hash.

The production `preferred-free-color` must be installed before requiring the new validation vocabulary. No production source is changed by this test commit.
