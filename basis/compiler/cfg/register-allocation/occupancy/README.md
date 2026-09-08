# Register occupancy

Each physical register has an independent, sorted vector of disjoint inclusive
live ranges. Queries binary-search the first range whose end reaches the query
start, then visit only ranges starting before the query end. Lifetime holes do
not interfere. The owner can be a single greedy interval or a backtracking
bundle containing multiple intervals.

Assignment records a serial number shared by all of the owner's ranges. Query
results deduplicate owners by identity and preserve assignment order. Eviction
removes every range before the owner is requeued; reinsertion gets a new serial.
This preserves the original vector-based allocators' eviction ordering and tie
breaks. Splitting is performed only after the owner has left the index.

A query over R input ranges and N occupied ranges takes R binary searches plus
visits to actual overlapping ranges. Assignments and evictions can still move
O(N) vector entries. A vector keeps storage and initialization small, and an
empty index returns immediately. There is no alternate allocator or linear-scan
fallback.

Backtracking caches bundle ranges, class, size, and spill weight until the
bundle is discarded on splitting. Greedy caches interval priority and spill
weight in an identity hashtable, retaining them over eviction and deleting the
entry before any split mutates the interval. Both allocators stop searching as
soon as the first free register is found.

The tests compare all 903 inclusive query intervals within [0, 41] against the
old pairwise range oracle for occupied, evicted/reinserted, and split states.
They also cover atomic ranges, holes, duplicate hits, and assignment ordering.
Backend tests compare indexed backtracking queries after real evictions and
splits, and verify greedy cache entries against recomputation after splitting.
