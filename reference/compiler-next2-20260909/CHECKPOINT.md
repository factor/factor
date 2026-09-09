# Compiler checkpoint — 2026-09-09

This checkpoint lands two measured compiler-cost reductions developed in separate
worktrees. It retains linear scan as the default, with GVN and rematerialization
off by default. The alternative allocators remain selectable.

## Accepted this round

- Chordal residency: skip victim scoring/sorting when excess pressure is zero,
  after mandatory-capacity validation. Native isolated compiler retired work
  improves **3.910%**, CPU **3.254%** over two reversed baseline/candidate pairs.
  All 12 static reports and 26 checked outputs match. The ARM instrumented
  corpus matched the old result on all 31,146 queries; 99.25% had zero excess.
- Named class-info construction: construct a fresh result directly from known
  class-only state. Keep dynamic null-class checks, fresh finite interval
  endpoints, capacity normalization, and the original anonymous-classoid path.
  Native default linear-scan compiler retired work improves **1.126%**, CPU
  **0.893%**. Both paired orderings agree; the 28,500-word scopes, 12 static
  reports and 26 checked outputs match. This introduces no mutable-result cache.

The percentages are isolated compilation-workload results and must not be added
as a measured combined gain. Neither experiment measured a runtime speedup. See the isolated
[residency measurements](residency/README.md) and
[class-info measurements](class-info/README.md).
The combined source passes all four ARM loaded compiler-vocabulary suites;
this describes loaded vocabulary coverage, not every test on disk. Native
isolated tests and strict full benchmark closures also pass. The final combined
ARM linear-scan closure emitted all 26 runtime records, but its terminal driver
status is unavailable; that run remains incomplete for acceptance. The remaining
combined measurements and bootstrap were not started.

The suite freeze was `87ac3f9b1e19a9bee974a52d263f7abce4b61c34` in
`compiler-next2-integration`. That tree also contains an inactive recoloring
experiment and its independent test vocabulary. This checkpoint excludes those
unused namespaces; its active production changes and corresponding tests
exactly match the validated freeze. No normal allocator imported or called that experiment.

## Kept experimental

`compiler-next2-recolor` and `compiler-next2-verification` retain the bounded
reverse-order affinity recoloring helper, activation harness and independent
16,350-pass legality corpus. Fresh ARM spectral execution, 450 reduced-bank
answers and real callbacks passed. Broad matched ARM/x86 runtime measurement
is pending, so the recoloring helper is not activated or included in this
checkpoint. The native observed/pristine activation protocol is saved without
starting its measurement queue.

## Performance limits and previous work

The earlier tuning round improved named-class algebra operations, greedy hint
queries and exact chordal preference selection, and corrected backtracking's
shared-entry-reload profitability. Its FFI workload retires about 1.3–1.5%
fewer instructions; aggregate runtime changes were nearly flat. Full results
and bootstrap evidence remain in [the prior report](../compiler-next-final-20260909/RESULTS.md).

The earlier native integer workload's +1.1264% retired count did not reproduce
in this round's focused same-process B/C/C/B diagnostic: paired excesses were
0 and 5 instructions out of about 3.448 billion. Installed bytes and addresses
were stable during each batch. Surrounding runtime activity differed, so the
prior observation remains recorded and unattributed. See [the diagnostic](README.md).

The last completed default bootstrap remains **203.912 seconds** (3:19 core),
above the user's two-minute goal. No new bootstrap for this checkpoint was
started before the requested stop. The original root image and unrelated user
edits are preserved. A combined prepared benchmark image remains in the
integration worktree; it is not an installed root image.

## Resume from here

1. Finish the pending combined ARM measurements and bootstrap if needed for
   a release decision; all completed records remain available.
2. Run the frozen recoloring runtime matrix with the pristine timed activation,
   checking actual emitted code and per-case tradeoffs before activation.
3. Investigate further propagation and spill/phi transport costs using the
   measured profiles. Do not introduce shared class-info caching without a
   valid mutation and class-redefinition lifetime model.

All new benchmark queues are stopped. Completed results are committed;
unfinished experiment artifacts and commands remain in their worktrees
for resumption.
