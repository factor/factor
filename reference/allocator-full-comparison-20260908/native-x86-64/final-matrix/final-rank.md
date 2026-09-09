# Final source, allocator / linear-scan ratios

Source: `30a50ab0df1147eb5c7d852b5d6aad2c0835464e`. All allocators use the same 28375-word frozen closure and flags: `{"backtracking_loop_spills": true, "gvn": false, "rematerialize_constants": true}`.

Each runtime ratio equally weights 26 workload medians, with at least six samples per workload. Ratios below 1 mean less measured time/work. This table does not establish statistical significance on a shared host; inspect the paired per-round and per-workload records as well.

| Allocator | Runtime CPU | Runtime retired | Compile CPU | Compile retired |
|---|---:|---:|---:|---:|
| linear-scan | 1.0000 | 1.0000 | 1.0000 | 1.0000 |
| greedy | 1.0247 | 1.0144 | 1.0306 | 1.0293 |
| backtracking | 1.0146 | 1.0222 | 1.1892 | 1.2823 |
| chordal | 1.0530 | 1.0774 | 1.2913 | 1.3188 |
