# Chordal entry-state tuning, 2026-09-09

Two separate source-spilling policy changes reduce emitted code and spill traffic
in the existing branch-pressure workload. The allocator remains the decoupled
SSA chordal pipeline: source spilling, SSA repair, checked post-spill graph,
preference coloring, then physical SSA transport. No coloring fallback or
post-allocation move deletion was added.

## Changes and proof obligations

`9d26d1200e` filters entry-register candidates. A value known to be absent from
every predecessor's resident set stays in memory until an actual use needs it.
An unknown backedge retains the previous eligibility policy; phi inputs use
their predecessor-specific source identities. This follows the entry-residency
distinction in pinned libFirm
[`bespillbelady.c`](https://raw.githubusercontent.com/libfirm/libfirm/114012d1d93427e63ba2f2ab51318e8a1b92f06c/ir/be/bespillbelady.c),
with Factor's existing edge coupling and loop handling retained.

`bd2edfd3a1` intersects valid saved-home facts when every predecessor has been
processed. A resident value whose home is valid only on a cold GC path no longer
forces a store on the other path. A later actual eviction or clobber still stores
the current joined register before reloading its home. Unknown-backedge joins
retain the previous known-predecessor policy. Phi result homes remain distinct
from incoming homes. Nonresident entry values still require memory, and the
unchanged per-edge coupling establishes each such requirement.

## Native x86 source and emitted-code evidence

`branch-pressure.factor` contains the existing corpus kernel. `diagnose.factor`
records source resident/saved sets, rewritten instructions, final IR counts, and
actual generated code size. It executes newly compiled code at inputs 0 and 17,
requiring results 3672 and 16712. GVN is off, rematerialization is on, and the SSA
and final allocation checkers are enabled. Crossarch ran each version with the
matching native VM and fresh baseline image. Exact source hashes are retained in
`source-provenance.json`.

| Metric | Original `7b6cd9519a` | Entry filter | Both changes |
| --- | ---: | ---: | ---: |
| Generated code bytes | 2256 | 2176 | 2048 |
| Final IR stores | 48 | 47 | 35 |
| Final IR reloads | 45 | 35 | 35 |
| Final IR copies | 9 | 10 | 10 |
| Source pressure stores | 43 | 43 | 31 |
| Source reload definitions | 40 | 31 | 31 |
| Source repair phis | 79 | 61 | 61 |
| Graph vertices | 222 | 195 | 195 |
| Added source edge blocks | 6 | 2 | 1 |
| Allocation repair / fallback | 0 / 0 | 0 / 0 | 0 / 0 |

The first source trace shows three speculative reloads on each branch arm and
further reloads at joins. The entry filter removes those redundant residency
decisions. The second change removes exactly twelve stores from the hot path
around the GC join; the cold path still saves the required values. The logs are
`native-baseline.log`, `native-candidate.log`, and `native-policy2.log`.

The resulting code is 208 bytes smaller than the original chordal code. IR
copies rose by one; they are not an emitted-move count because x86 elides
self-copies and can introduce two-address preparation moves. Linear scan still
has smaller code in this probe (1888 bytes, 31 stores and 31 reloads). These
diagnostic runs establish code and traffic reductions, not a CPU speedup.
Matched runtime measurements are owned by the crossarch benchmark report.

## Correctness validation

The spilling subtree passes after each policy. Its reduced-register fixture
requires exactly one source store and one reload, and executes results 110 and
92 with rematerialization both off and on. Existing diamond, loop, memory-phi,
and callback tests remain enabled. An old diamond counter asserting speculative
edge creation was updated to require zero such edges while retaining the phi
and memory requirements.

Independent `validation.entry-residency` tests (`0fbdb497a6`, `f5b0c38eea`)
cover known-empty versus unknown predecessor state, phi source identity, mixed
resident/saved predecessors, retained loop policy, and a later store-before-
reload from the correct joined register into the same home. All five tests,
sixteen assertions, pass with the second policy.

The full ordinary compiler suite passes with chordal, rematerialization on,
loop spilling on, GVN off, and SSA/interval/final-value checks enabled:
`arm-compiler-policy2-on/output.log` ends with `TEST-FAILURES 0`. It executes the
FFI test fixtures as part of the suite. Runner metadata and focused test logs
are retained alongside it. Correctness-run durations are not performance
measurements. No default allocator or optimization flag changed.
