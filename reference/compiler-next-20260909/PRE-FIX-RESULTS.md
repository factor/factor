# Compiler tuning before the backtracking profitability correction

Production candidate: `eccfc0accc5c513b44701f2e59d4a9bafb7515f0`, based on
`c1f7e4d34cd604bbdf22576b237406b39758896d`. Four changes were developed and
committed in separate worktrees. Linear scan remains the default; GVN and
constant rematerialization remain off by default.

## Isolated native x86 measurements

Each attribution comparison uses two fresh-process baseline/candidate pairs
in B/C/C/B order on CPU 2, with matching VM and prepared images. The frozen
compilation workload contains 28,489 baseline words, including the compiler.
The chordal candidate adds its new selector to the closure (28,490 words).
Runtime options for this comparison are rematerialization on, loop placement
on, GVN off. These are compilation-workload measurements, not bootstrap times.

| Change | Compiler instructions | Compiler CPU | Interpretation |
| --- | ---: | ---: | --- |
| Named-class identity operations | −1.20% | −1.32% | Both pairs improve |
| Greedy hint queries | −0.45% | −0.23% pooled | CPU pairs straddle zero; work reduction only |
| Chordal exact preference selection | −3.06% | −3.01% | Both pairs improve; old color policy retained |

The class-algebra shortcut applies only to identical named classes. Anonymous
classoids retain structural-cache behavior, including cache-primed opaque
predicates. Greedy reads current peer assignments without allocating a full
score association for each scalar query; it skips empty sorts. Chordal scans
ascending free colors instead of sorting comparison pairs, preserving the
smallest-color tie break exactly. None adds an optimizer pass or global cache.

Raw paired records and summaries: [class algebra](native-algebra/summary.json),
[greedy](native-greedy/summary.json), [chordal](native-chordal/summary.json).
Greedy's 12 static kernel reports and all 26 outputs match across every run;
this is not a claim of byte identity for every word in the compiler closure.

Backtracking publishes eligible ordinary block-entry registers to existing
SSA parallel-edge resolution instead of forcing a register-to-slot-to-register
round trip. Original live-ins, all non-kill predecessors, and exclusion of
phi/GC/clobber entries guard the change. Outgoing spill obligations remain.
Its isolated ARM FFI diagnostic removes four stores, two reloads and two blocks
(1,344→1,312 bytes); dynamic attribution and combined results follow below.

## Correctness

All four full ARM compiler suites pass at the frozen combined source with
SSA, interval and final-value-flow checks. Linear scan uses rematerialization
off; alternative allocator suites use it on. New coverage includes exact
hint-score/order comparisons across assignment mutations; 240 selector cases
and 3,072 complete-color/exhaustion comparisons; mixed register/slot incoming
edges with a simultaneous register swap; a required-copy deletion mutation;
and native distinct-phi loops with a moving-GC backedge.

The class-algebra suite additionally checks named metaclasses and anonymous
cache behavior. Full gate commands, source/image hashes and output are in
[the compiler gate archive](arm-compiler-gates/).

## Default bootstrap: time budget remains unmet

The combined source saves and verifies a separate default linear-scan image.
It takes **2:38 core / 161.49 seconds whole process**. A contemporary unchanged
baseline takes **3:07 core / 190.48 seconds whole process**. Both exceed the
requested two-minute budget. The root image is unchanged.

Candidate/baseline retire 1.79844/1.80182 trillion instructions. The previous
1:52 accepted bootstrap retired 1.80021 trillion. The large time variation
therefore does not accompany a large increase in source-level compiler work.
The counters instead show substantially different on-core execution rates;
this single comparison does not establish a source-caused wall-time speedup.
See [exact bootstrap records](default-bootstrap/) and image hashes.

## Backtracking profitability requires correction

All pre-fix measurement and callback/GC runs completed successfully. Native
backtracking's isolated runtime retired geomean improves only 0.034%; ARM's
combined backtracking comparison is effectively flat (+0.012%). The FFI gain
is real (native −1.85% instructions, ARM about −1.56%), but branch pressure
regresses on both architectures and native integer pressure regresses 1.13%.
Do not describe this as a broad runtime improvement or promote on the FFI
case alone. The correction under investigation keeps a shared successor
reload when all incoming locations already equal its spill home.

The exact targeted ARM matrix is [archived separately](../compiler-next-arm-20260909/RESULTS.md).
Native isolated case details and the combined same-source ranking are retained
under `independent-native-audit`. The separate chordal recoloring experiment
remains unpromoted diagnostic work.
