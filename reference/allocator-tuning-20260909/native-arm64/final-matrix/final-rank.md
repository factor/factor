# Final source, allocator / linear-scan ratios

Source: `5c848c90f63cea092191b70e1678bec4441e0238`. All allocators use the same 27356-word frozen closure and flags: `{"backtracking_loop_spills": true, "gvn": false, "rematerialize_constants": true}`.

Each runtime ratio equally weights 26 workload medians, with at least six samples per workload. Ratios below 1 mean less measured time/work. This table does not establish statistical significance on a shared host; inspect the paired per-round and per-workload records as well.

| Allocator | Runtime CPU | Runtime retired | Compile CPU | Compile retired |
|---|---:|---:|---:|---:|
| linear-scan | 1.0000 | 1.0000 | 1.0000 | 1.0000 |
| greedy | 0.9669 | 1.0001 | 1.0317 | 1.0450 |
| backtracking | 0.9464 | 1.0238 | 1.0373 | 1.0002 |
| chordal | 0.9732 | 1.0770 | 1.3285 | 1.3398 |
