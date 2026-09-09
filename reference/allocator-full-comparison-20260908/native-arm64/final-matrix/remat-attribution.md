# Same-host candidate / baseline allocator comparison

All captured outputs agree; original independent checks passed and six pressure checks assert in Factor.

Ratios below 1 favor the candidate. Runtime aggregates equally weight 26 workloads and use per-workload medians; warmups and checked runs are excluded. Each allocator is compared with its own baseline implementation.

| Allocator | Runtime CPU | Runtime instructions | Compile CPU | Compile instructions |
|---|---:|---:|---:|---:|
| linear-scan | 1.0348 | 1.0005 | 1.0375 | 0.9990 |

## linear-scan

Per-round geometric-mean ratios: {"1": {"cpu_seconds": 1.1509746172302062, "instructions": 1.000538967182881, "ns": 1.1594367065603168}, "2": {"cpu_seconds": 0.9541061777989174, "instructions": 1.000349293059046, "ns": 0.9560951735028957}}

| Workload | CPU ratio | Retired ratio | Samples before / after |
|---|---:|---:|---:|
| norm-work | 1.0043 | 0.9999 | 6 / 6 |
| nbody-work | 1.0055 | 1.0001 | 6 / 6 |
| nbody-simd-work | 0.9093 | 0.9996 | 6 / 6 |
| trees-work | 0.9498 | 0.9993 | 6 / 6 |
| fannkuch-work | 0.9598 | 1.0000 | 6 / 6 |
| sieve-work | 0.9397 | 1.0004 | 6 / 6 |
| pi-work | 0.9633 | 1.0011 | 6 / 6 |
| md5-work | 0.9839 | 1.0004 | 6 / 6 |
| sha1-work | 1.0033 | 1.0004 | 6 / 6 |
| base64-work | 1.0147 | 0.9999 | 6 / 6 |
| base32-work | 1.0063 | 0.9996 | 6 / 6 |
| csv-benchmark | 1.0116 | 1.0010 | 6 / 6 |
| json-work | 1.0643 | 1.0024 | 6 / 6 |
| msgpack-benchmark | 1.1311 | 1.0014 | 6 / 6 |
| lcs-benchmark | 1.1252 | 1.0013 | 6 / 6 |
| tuple-arrays-benchmark | 1.0667 | 1.0006 | 6 / 6 |
| struct-work | 1.0780 | 1.0010 | 6 / 6 |
| matrix-work | 1.0911 | 1.0014 | 6 / 6 |
| matrix-simd-work | 1.1430 | 1.0007 | 6 / 6 |
| gc-work | 1.0504 | 1.0001 | 6 / 6 |
| float-pressure-work | 1.0714 | 1.0009 | 6 / 6 |
| ffi-pressure-work | 1.0888 | 1.0004 | 6 / 6 |
| branch-pressure-work | 1.0517 | 1.0009 | 6 / 6 |
| integer-pressure-work | 1.0357 | 1.0002 | 6 / 6 |
| simd-pressure-work | 1.2087 | 1.0005 | 6 / 6 |
| gc-pressure-work | 1.0061 | 0.9997 | 6 / 6 |

| Kernel / index | Code bytes before → after | Spills before → after | Reloads before → after | Copies before → after |
|---|---:|---:|---:|---:|
| float-pressure|0 | 848 → 848 | 12 → 12 | 12 → 12 | 0 → 0 |
| ffi-pressure|1 | 1056 → 1056 | 34 → 34 | 33 → 33 | 0 → 0 |
| branch-pressure|2 | 1264 → 1264 | 31 → 31 | 31 → 31 | 0 → 0 |
| integer-pressure|3 | 560 → 560 | 24 → 24 | 24 → 24 | 0 → 0 |
| simd-pressure|4 | 1152 → 1152 | 12 → 12 | 12 → 12 | 0 → 0 |
| gc-pressure|5 | 8976 → 8976 | 142 → 142 | 142 → 142 | 0 → 0 |
| spectral-norm|6 | 2992 → 2992 | 20 → 20 | 20 → 20 | 1 → 1 |
| nbody|7 | 3120 → 3120 | 0 → 0 | 0 → 0 | 6 → 6 |
| nbody|8 | 4160 → 4144 | 36 → 33 | 21 → 18 | 0 → 0 |
| fannkuch|9 | 3424 → 3424 | 1 → 1 | 1 → 1 | 0 → 0 |
| binary-trees|10 | 8784 → 8784 | 12 → 12 | 12 → 12 | 10 → 10 |
| struct-arrays-bench|11 | 1648 → 1648 | 14 → 14 | 15 → 15 | 5 → 5 |
