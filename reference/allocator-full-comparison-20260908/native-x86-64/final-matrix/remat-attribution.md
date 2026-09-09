# Same-host candidate / baseline allocator comparison

All captured outputs agree; original independent checks passed and six pressure checks assert in Factor.

Ratios below 1 favor the candidate. Runtime aggregates equally weight 26 workloads and use per-workload medians; warmups and checked runs are excluded. Each allocator is compared with its own baseline implementation.

| Allocator | Runtime CPU | Runtime instructions | Compile CPU | Compile instructions |
|---|---:|---:|---:|---:|
| linear-scan | 0.9905 | 1.0000 | 1.0023 | 1.0101 |

## linear-scan

Per-round geometric-mean ratios: {"1": {"cpu_seconds": 0.9796402329719477, "instructions": 0.9999890740634915, "ns": 0.9796623050485502}, "2": {"cpu_seconds": 1.002083485608271, "instructions": 0.9999890672655197, "ns": 1.0025976108788048}}

| Workload | CPU ratio | Retired ratio | Samples before / after |
|---|---:|---:|---:|
| norm-work | 1.0022 | 1.0000 | 6 / 6 |
| nbody-work | 0.9544 | 1.0000 | 6 / 6 |
| nbody-simd-work | 1.0035 | 1.0000 | 6 / 6 |
| trees-work | 1.0034 | 0.9999 | 6 / 6 |
| fannkuch-work | 0.9975 | 1.0000 | 6 / 6 |
| sieve-work | 1.0058 | 1.0000 | 6 / 6 |
| pi-work | 1.0033 | 1.0000 | 6 / 6 |
| md5-work | 0.9873 | 1.0000 | 6 / 6 |
| sha1-work | 0.9843 | 1.0000 | 6 / 6 |
| base64-work | 0.9580 | 1.0000 | 6 / 6 |
| base32-work | 1.0223 | 1.0000 | 6 / 6 |
| csv-benchmark | 0.9999 | 1.0000 | 6 / 6 |
| json-work | 0.9786 | 1.0000 | 6 / 6 |
| msgpack-benchmark | 0.9807 | 0.9999 | 6 / 6 |
| lcs-benchmark | 0.9219 | 1.0000 | 6 / 6 |
| tuple-arrays-benchmark | 1.0129 | 1.0000 | 6 / 6 |
| struct-work | 1.0000 | 1.0000 | 6 / 6 |
| matrix-work | 1.0008 | 1.0000 | 6 / 6 |
| matrix-simd-work | 0.9905 | 1.0000 | 6 / 6 |
| gc-work | 0.9955 | 1.0000 | 6 / 6 |
| float-pressure-work | 0.9947 | 1.0000 | 6 / 6 |
| ffi-pressure-work | 0.9967 | 1.0000 | 6 / 6 |
| branch-pressure-work | 0.9703 | 1.0000 | 6 / 6 |
| integer-pressure-work | 1.0027 | 1.0000 | 6 / 6 |
| simd-pressure-work | 0.9976 | 1.0000 | 6 / 6 |
| gc-pressure-work | 0.9945 | 1.0001 | 6 / 6 |

| Kernel / index | Code bytes before → after | Spills before → after | Reloads before → after | Copies before → after |
|---|---:|---:|---:|---:|
| float-pressure|0 | 1264 → 1264 | 17 → 17 | 17 → 17 | 0 → 0 |
| ffi-pressure|1 | 1664 → 1664 | 34 → 34 | 33 → 33 | 0 → 0 |
| branch-pressure|2 | 1888 → 1888 | 31 → 31 | 31 → 31 | 0 → 0 |
| integer-pressure|3 | 672 → 672 | 28 → 28 | 28 → 28 | 0 → 0 |
| simd-pressure|4 | 1504 → 1504 | 17 → 17 | 17 → 17 | 0 → 0 |
| gc-pressure|5 | 11968 → 11968 | 223 → 223 | 223 → 223 | 0 → 0 |
| spectral-norm|6 | 3104 → 3104 | 20 → 20 | 20 → 20 | 1 → 1 |
| nbody|7 | 2960 → 2960 | 0 → 0 | 0 → 0 | 6 → 6 |
| nbody|8 | 4368 → 4336 | 36 → 33 | 21 → 18 | 0 → 0 |
| fannkuch|9 | 3392 → 3392 | 1 → 1 | 1 → 1 | 0 → 0 |
| binary-trees|10 | 8640 → 8640 | 12 → 12 | 12 → 12 | 10 → 10 |
| struct-arrays-bench|11 | 1584 → 1584 | 15 → 15 | 16 → 16 | 3 → 3 |
