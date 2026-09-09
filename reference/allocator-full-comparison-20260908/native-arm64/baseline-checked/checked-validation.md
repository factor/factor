# Same-host candidate / baseline allocator comparison

All captured outputs agree; original independent checks passed and six pressure checks assert in Factor.

Ratios below 1 favor the candidate. Runtime aggregates equally weight 26 workloads and use per-workload medians; warmups and checked runs are excluded. Each allocator is compared with its own baseline implementation.

| Allocator | Runtime CPU | Runtime instructions | Compile CPU | Compile instructions |
|---|---:|---:|---:|---:|
