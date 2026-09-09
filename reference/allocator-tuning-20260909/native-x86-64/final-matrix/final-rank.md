# Final source, allocator / linear-scan ratios

Source: `5c848c90f63cea092191b70e1678bec4441e0238`. All allocators use the same 28489-word frozen closure and flags: `{"backtracking_loop_spills": true, "gvn": false, "rematerialize_constants": true}`.

Each runtime ratio equally weights 26 workload medians, with at least six samples per workload. Ratios below 1 mean less measured time/work. This table does not establish statistical significance on a shared host; inspect the paired per-round and per-workload records as well.

| Allocator | Runtime CPU | Runtime retired | Compile CPU | Compile retired |
|---|---:|---:|---:|---:|
| linear-scan | 1.0000 | 1.0000 | 1.0000 | 1.0000 |
| greedy | 1.0072 | 1.0018 | 1.0493 | 1.0479 |
| backtracking | 1.0275 | 1.0197 | 1.0026 | 1.0074 |
| chordal | 1.0298 | 1.0710 | 1.2919 | 1.3262 |
