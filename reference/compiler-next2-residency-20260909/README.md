# Chordal zero-pressure victim selection

Baseline: `1d67bdd034`. Only production change: `pressure-victims` returns
an empty victim sequence when its existing union-based excess calculation
is zero. The mandatory-operand capacity check still executes first.
Positive-pressure selection retains the original difference, priority
sort, reverse, and prefix operations unchanged. Default allocator and
optimization flags are unchanged.

This removes allocation and sorting from a path called for every machine
instruction/register bank by `limit-residents`. It does not alter residency,
spill placement, memory-home assumptions, next-use computation, or tie rules.

## Tests and untimed diagnostic

The residency subtree passes, including 6,144 differential cases against
the original complete selector: all subsets of four values as residents
and demands, capacities zero through four, four next-use maps, and input
duplicates on/off. Independent expected answers cover dead-first eviction,
SSA-number ties, zero-capacity empty demand, and duplicate demands. An
impossible demand at zero capacity checks the exact error payload.

The twelve existing metric kernels were compiled with chordal, SSA/interval
and final-value-flow checks enabled, rematerialization on, and GVN off.
An overlay compared every actual query with the original selector:

| Diagnostic | Count |
| --- | ---: |
| Queries compared | 31,146 |
| Queries with zero excess | 30,913 (99.25%) |
| Old priority/sort entries avoided on those queries | 46,842 |

All comparisons passed. These are instrumented counts, not timing results
or generated-runtime evidence. No end-to-end speedup is claimed yet.
The corpus compiles metric procedures; it is not a native runtime oracle.

Both runs exited zero, using a separate copy of the matching VM and
`compiler-next-final.factor.image` from the integration worktree, explicit
resource path, and `refresh-all`. [assets.json](assets.json) records hashes;
`check.py` and `frequency.py` retain launcher commands, and the compressed
logs retain all test output. The exact executed diagnostic is
`frequency-executed.factor`: its missing `system` import caused one
successful auto-import warning. `frequency.factor` adds that explicit
import for repeatable future execution, with no other change.

Native isolated compiler CPU/instruction attribution and broader policy
comparison remain pending. The intended benefit is compiler cost only;
positive-pressure victim choices and generated code should remain equal.
