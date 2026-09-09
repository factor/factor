# Final source, allocator / linear-scan ratios

Source: `30a50ab0df1147eb5c7d852b5d6aad2c0835464e`. All allocators use the same 27296-word frozen closure and flags: `{"backtracking_loop_spills": true, "gvn": false, "rematerialize_constants": true}`.

Each runtime ratio equally weights 26 workload medians, with at least six samples per workload. Ratios below 1 mean less measured time/work. This table does not establish statistical significance on a shared host; inspect the paired per-round and per-workload records as well.

| Allocator | Runtime CPU | Runtime retired | Compile CPU | Compile retired |
|---|---:|---:|---:|---:|
| linear-scan | 1.0000 | 1.0000 | 1.0000 | 1.0000 |
| greedy | 1.0037 | 1.0089 | 0.8352 | 1.0479 |
| backtracking | 0.8031 | 1.0269 | 0.7816 | 1.3239 |
| chordal | 1.2168 | 1.0956 | 1.1888 | 1.3409 |
