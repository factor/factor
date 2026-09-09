# Same-host candidate / baseline allocator comparison

All captured outputs agree; original independent checks passed and six pressure checks assert in Factor.

Ratios below 1 favor the candidate. Runtime aggregates equally weight 26 workloads and use per-workload medians; warmups and checked runs are excluded. Each allocator is compared with its own baseline implementation.

| Allocator | Runtime CPU | Runtime instructions | Compile CPU | Compile instructions |
|---|---:|---:|---:|---:|
| linear-scan | 1.0027 | 1.0000 | 0.9864 | 0.9931 |
| greedy | 0.9755 | 0.9879 | 0.9995 | 1.0105 |
| backtracking | 1.0038 | 0.9972 | 0.8381 | 0.7856 |
| chordal | 0.9797 | 0.9952 | 0.9868 | 1.0014 |

## linear-scan

Per-round geometric-mean ratios: {"1": {"cpu_seconds": 1.0043136097704106, "instructions": 1.0000393910021348, "ns": 1.0043184741688629}, "2": {"cpu_seconds": 1.0025866198128572, "instructions": 1.000053074704435, "ns": 1.0026820265803071}}

| Workload | CPU ratio | Retired ratio | Samples before / after |
|---|---:|---:|---:|
| norm-work | 1.0000 | 1.0000 | 6 / 6 |
| nbody-work | 0.9958 | 1.0000 | 6 / 6 |
| nbody-simd-work | 0.9978 | 1.0000 | 6 / 6 |
| trees-work | 1.0764 | 1.0000 | 6 / 6 |
| fannkuch-work | 1.0136 | 1.0000 | 6 / 6 |
| sieve-work | 1.0002 | 1.0000 | 6 / 6 |
| pi-work | 1.0005 | 1.0000 | 6 / 6 |
| md5-work | 1.0101 | 1.0000 | 6 / 6 |
| sha1-work | 1.0028 | 1.0000 | 6 / 6 |
| base64-work | 1.0042 | 1.0000 | 6 / 6 |
| base32-work | 1.0099 | 1.0000 | 6 / 6 |
| csv-benchmark | 1.0055 | 1.0002 | 6 / 6 |
| json-work | 0.9930 | 0.9999 | 6 / 6 |
| msgpack-benchmark | 0.9946 | 1.0000 | 6 / 6 |
| lcs-benchmark | 1.0023 | 1.0000 | 6 / 6 |
| tuple-arrays-benchmark | 0.9944 | 1.0000 | 6 / 6 |
| struct-work | 1.0004 | 1.0000 | 6 / 6 |
| matrix-work | 1.0049 | 1.0000 | 6 / 6 |
| matrix-simd-work | 0.9942 | 1.0000 | 6 / 6 |
| gc-work | 0.9975 | 1.0003 | 6 / 6 |
| float-pressure-work | 0.9985 | 1.0000 | 6 / 6 |
| ffi-pressure-work | 0.9989 | 1.0000 | 6 / 6 |
| branch-pressure-work | 0.9815 | 1.0000 | 6 / 6 |
| integer-pressure-work | 1.0057 | 1.0000 | 6 / 6 |
| simd-pressure-work | 0.9985 | 1.0000 | 6 / 6 |
| gc-pressure-work | 0.9935 | 1.0008 | 6 / 6 |

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
| nbody|8 | 4336 → 4336 | 33 → 33 | 18 → 18 | 0 → 0 |
| fannkuch|9 | 3392 → 3392 | 1 → 1 | 1 → 1 | 0 → 0 |
| binary-trees|10 | 8640 → 8640 | 12 → 12 | 12 → 12 | 10 → 10 |
| struct-arrays-bench|11 | 1584 → 1584 | 15 → 15 | 16 → 16 | 3 → 3 |

## greedy

Per-round geometric-mean ratios: {"1": {"cpu_seconds": 0.9812843256008053, "instructions": 0.9878523056133782, "ns": 0.9813686555960462}, "2": {"cpu_seconds": 0.9690359798636072, "instructions": 0.9879071973098255, "ns": 0.9690113504511}}

| Workload | CPU ratio | Retired ratio | Samples before / after |
|---|---:|---:|---:|
| norm-work | 1.0000 | 1.0000 | 6 / 6 |
| nbody-work | 0.9365 | 0.9999 | 6 / 6 |
| nbody-simd-work | 0.9580 | 1.0000 | 6 / 6 |
| trees-work | 0.9737 | 1.0002 | 6 / 6 |
| fannkuch-work | 0.9742 | 1.0000 | 6 / 6 |
| sieve-work | 1.0043 | 1.0000 | 6 / 6 |
| pi-work | 0.9989 | 1.0000 | 6 / 6 |
| md5-work | 0.9954 | 1.0000 | 6 / 6 |
| sha1-work | 0.9943 | 1.0000 | 6 / 6 |
| base64-work | 1.0127 | 1.0000 | 6 / 6 |
| base32-work | 0.9436 | 1.0000 | 6 / 6 |
| csv-benchmark | 0.9952 | 1.0002 | 6 / 6 |
| json-work | 0.9796 | 0.9998 | 6 / 6 |
| msgpack-benchmark | 0.9824 | 0.9999 | 6 / 6 |
| lcs-benchmark | 0.9959 | 1.0000 | 6 / 6 |
| tuple-arrays-benchmark | 1.0140 | 1.0006 | 6 / 6 |
| struct-work | 0.9970 | 1.0000 | 6 / 6 |
| matrix-work | 1.0000 | 1.0000 | 6 / 6 |
| matrix-simd-work | 1.0089 | 0.9998 | 6 / 6 |
| gc-work | 0.9931 | 1.0003 | 6 / 6 |
| float-pressure-work | 0.8903 | 0.9372 | 6 / 6 |
| ffi-pressure-work | 1.0127 | 0.9999 | 6 / 6 |
| branch-pressure-work | 0.9391 | 0.9539 | 6 / 6 |
| integer-pressure-work | 0.8303 | 0.8638 | 6 / 6 |
| simd-pressure-work | 0.9542 | 0.9419 | 6 / 6 |
| gc-pressure-work | 1.0032 | 1.0008 | 6 / 6 |

| Kernel / index | Code bytes before → after | Spills before → after | Reloads before → after | Copies before → after |
|---|---:|---:|---:|---:|
| float-pressure|0 | 1376 → 1248 | 35 → 18 | 18 → 18 | 0 → 0 |
| ffi-pressure|1 | 1616 → 1616 | 34 → 34 | 33 → 33 | 0 → 0 |
| branch-pressure|2 | 2016 → 1888 | 47 → 32 | 36 → 36 | 0 → 0 |
| integer-pressure|3 | 864 → 688 | 57 → 29 | 29 → 29 | 0 → 0 |
| simd-pressure|4 | 1616 → 1488 | 35 → 18 | 18 → 18 | 0 → 0 |
| gc-pressure|5 | 12352 → 12080 | 268 → 233 | 228 → 228 | 0 → 0 |
| spectral-norm|6 | 3104 → 3104 | 20 → 20 | 20 → 20 | 1 → 1 |
| nbody|7 | 2960 → 2960 | 0 → 0 | 0 → 0 | 6 → 6 |
| nbody|8 | 4336 → 4336 | 33 → 33 | 18 → 18 | 0 → 0 |
| fannkuch|9 | 3392 → 3392 | 1 → 1 | 1 → 1 | 0 → 0 |
| binary-trees|10 | 8640 → 8640 | 12 → 12 | 12 → 12 | 10 → 10 |
| struct-arrays-bench|11 | 1600 → 1600 | 15 → 15 | 16 → 16 | 5 → 5 |

## backtracking

Per-round geometric-mean ratios: {"1": {"cpu_seconds": 0.9981513740374822, "instructions": 0.9971758061954735, "ns": 0.998092330256658}, "2": {"cpu_seconds": 1.0084351181521793, "instructions": 0.9971617878363246, "ns": 1.0084195019538025}}

| Workload | CPU ratio | Retired ratio | Samples before / after |
|---|---:|---:|---:|
| norm-work | 1.0004 | 1.0000 | 6 / 6 |
| nbody-work | 1.0217 | 1.0001 | 6 / 6 |
| nbody-simd-work | 0.9956 | 1.0000 | 6 / 6 |
| trees-work | 1.0166 | 0.9999 | 6 / 6 |
| fannkuch-work | 0.9966 | 1.0000 | 6 / 6 |
| sieve-work | 1.0252 | 1.0000 | 6 / 6 |
| pi-work | 0.9967 | 1.0001 | 6 / 6 |
| md5-work | 0.9677 | 1.0000 | 6 / 6 |
| sha1-work | 0.9673 | 1.0027 | 6 / 6 |
| base64-work | 1.1951 | 1.0000 | 6 / 6 |
| base32-work | 1.0032 | 1.0000 | 6 / 6 |
| csv-benchmark | 0.9976 | 1.0002 | 6 / 6 |
| json-work | 0.9712 | 1.0001 | 6 / 6 |
| msgpack-benchmark | 1.0054 | 1.0001 | 6 / 6 |
| lcs-benchmark | 1.0017 | 1.0001 | 6 / 6 |
| tuple-arrays-benchmark | 0.9946 | 0.9966 | 6 / 6 |
| struct-work | 0.9068 | 0.9521 | 6 / 6 |
| matrix-work | 1.0022 | 1.0000 | 6 / 6 |
| matrix-simd-work | 1.0033 | 1.0000 | 6 / 6 |
| gc-work | 0.9813 | 1.0008 | 6 / 6 |
| float-pressure-work | 0.9932 | 1.0000 | 6 / 6 |
| ffi-pressure-work | 0.9916 | 0.9671 | 6 / 6 |
| branch-pressure-work | 0.9950 | 1.0000 | 6 / 6 |
| integer-pressure-work | 1.0056 | 1.0000 | 6 / 6 |
| simd-pressure-work | 1.1042 | 1.0073 | 6 / 6 |
| gc-pressure-work | 0.9892 | 1.0008 | 6 / 6 |

| Kernel / index | Code bytes before → after | Spills before → after | Reloads before → after | Copies before → after |
|---|---:|---:|---:|---:|
| float-pressure|0 | 1232 → 1232 | 17 → 17 | 17 → 17 | 0 → 0 |
| ffi-pressure|1 | 2000 → 2000 | 50 → 54 | 48 → 51 | 24 → 14 |
| branch-pressure|2 | 1856 → 1856 | 31 → 31 | 31 → 31 | 1 → 1 |
| integer-pressure|3 | 704 → 704 | 29 → 29 | 29 → 29 | 0 → 0 |
| simd-pressure|4 | 1472 → 1472 | 17 → 17 | 17 → 17 | 0 → 0 |
| gc-pressure|5 | 10704 → 10704 | 214 → 214 | 214 → 214 | 0 → 0 |
| spectral-norm|6 | 3152 → 3152 | 20 → 20 | 20 → 20 | 1 → 1 |
| nbody|7 | 2992 → 2992 | 0 → 0 | 0 → 0 | 6 → 6 |
| nbody|8 | 4304 → 4256 | 38 → 38 | 18 → 18 | 14 → 0 |
| fannkuch|9 | 3424 → 3424 | 1 → 1 | 1 → 1 | 0 → 0 |
| binary-trees|10 | 8800 → 8800 | 12 → 12 | 12 → 12 | 10 → 10 |
| struct-arrays-bench|11 | 1792 → 1680 | 23 → 14 | 25 → 16 | 12 → 8 |

## chordal

Per-round geometric-mean ratios: {"1": {"cpu_seconds": 0.9687902211320822, "instructions": 0.9957454669000974, "ns": 0.9689150165393333}, "2": {"cpu_seconds": 0.9913568382748028, "instructions": 0.994609728951054, "ns": 0.9914205979717163}}

| Workload | CPU ratio | Retired ratio | Samples before / after |
|---|---:|---:|---:|
| norm-work | 0.9967 | 1.0000 | 6 / 6 |
| nbody-work | 0.9358 | 0.9816 | 6 / 6 |
| nbody-simd-work | 0.9779 | 0.9741 | 6 / 6 |
| trees-work | 0.9882 | 0.9779 | 6 / 6 |
| fannkuch-work | 0.9063 | 1.0000 | 6 / 6 |
| sieve-work | 0.9959 | 1.0000 | 6 / 6 |
| pi-work | 0.9997 | 1.0000 | 6 / 6 |
| md5-work | 1.0053 | 0.9994 | 6 / 6 |
| sha1-work | 1.0297 | 1.0158 | 6 / 6 |
| base64-work | 0.9952 | 1.0000 | 6 / 6 |
| base32-work | 0.9799 | 1.0155 | 6 / 6 |
| csv-benchmark | 1.0049 | 1.0099 | 6 / 6 |
| json-work | 1.0003 | 1.0109 | 6 / 6 |
| msgpack-benchmark | 0.9859 | 0.9994 | 6 / 6 |
| lcs-benchmark | 0.9885 | 0.9987 | 6 / 6 |
| tuple-arrays-benchmark | 0.9973 | 0.9957 | 6 / 6 |
| struct-work | 0.9874 | 1.0023 | 6 / 6 |
| matrix-work | 0.9935 | 0.9994 | 6 / 6 |
| matrix-simd-work | 0.9703 | 0.9990 | 6 / 6 |
| gc-work | 1.0001 | 1.0003 | 6 / 6 |
| float-pressure-work | 0.9862 | 0.9817 | 6 / 6 |
| ffi-pressure-work | 0.9257 | 0.9780 | 6 / 6 |
| branch-pressure-work | 0.7909 | 0.9441 | 6 / 6 |
| integer-pressure-work | 0.9951 | 1.0000 | 6 / 6 |
| simd-pressure-work | 0.9970 | 0.9930 | 6 / 6 |
| gc-pressure-work | 1.0741 | 1.0008 | 6 / 6 |

| Kernel / index | Code bytes before → after | Spills before → after | Reloads before → after | Copies before → after |
|---|---:|---:|---:|---:|
| float-pressure|0 | 1312 → 1312 | 17 → 17 | 17 → 17 | 0 → 0 |
| ffi-pressure|1 | 1984 → 1664 | 34 → 34 | 65 → 33 | 0 → 0 |
| branch-pressure|2 | 2256 → 2048 | 48 → 35 | 45 → 35 | 9 → 10 |
| integer-pressure|3 | 688 → 688 | 28 → 28 | 28 → 28 | 0 → 0 |
| simd-pressure|4 | 1536 → 1536 | 17 → 17 | 17 → 17 | 0 → 0 |
| gc-pressure|5 | 11824 → 11824 | 214 → 214 | 214 → 214 | 0 → 0 |
| spectral-norm|6 | 3568 → 3424 | 43 → 23 | 23 → 23 | 83 → 83 |
| nbody|7 | 3136 → 3136 | 0 → 0 | 0 → 0 | 63 → 63 |
| nbody|8 | 4656 → 4544 | 47 → 36 | 18 → 18 | 46 → 46 |
| fannkuch|9 | 3568 → 3552 | 3 → 2 | 2 → 2 | 37 → 37 |
| binary-trees|10 | 9152 → 9088 | 24 → 12 | 12 → 12 | 107 → 107 |
| struct-arrays-bench|11 | 1744 → 1728 | 13 → 10 | 16 → 16 | 13 → 13 |
