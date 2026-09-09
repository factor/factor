# Same-host candidate / baseline allocator comparison

All captured outputs agree; original independent checks passed and six pressure checks assert in Factor.

Ratios below 1 favor the candidate. Runtime aggregates equally weight 26 workloads and use per-workload medians; warmups and checked runs are excluded. Each allocator is compared with its own baseline implementation.

| Allocator | Runtime CPU | Runtime instructions | Compile CPU | Compile instructions |
|---|---:|---:|---:|---:|
| linear-scan | 0.9998 | 1.0013 | 1.0607 | 1.0645 |
| greedy | 1.0216 | 1.0127 | 1.0760 | 1.0830 |
| backtracking | 1.0200 | 1.0218 | 1.2563 | 1.3545 |
| chordal | 1.0159 | 0.9766 | 1.4347 | 1.4628 |

## linear-scan

Per-round geometric-mean ratios: {"1": {"cpu_seconds": 1.0002589102538428, "instructions": 1.0012740512958487, "ns": 1.0002988318866701}, "2": {"cpu_seconds": 0.9986103146326474, "instructions": 1.0013128739669408, "ns": 0.9991395741054101}}

| Workload | CPU ratio | Retired ratio | Samples before / after |
|---|---:|---:|---:|
| norm-work | 1.0016 | 1.0000 | 6 / 6 |
| nbody-work | 1.0076 | 1.0000 | 6 / 6 |
| nbody-simd-work | 1.0005 | 1.0000 | 6 / 6 |
| trees-work | 0.9881 | 0.9999 | 6 / 6 |
| fannkuch-work | 0.9822 | 1.0000 | 6 / 6 |
| sieve-work | 1.0005 | 1.0000 | 6 / 6 |
| pi-work | 1.0015 | 1.0000 | 6 / 6 |
| md5-work | 0.9774 | 1.0000 | 6 / 6 |
| sha1-work | 0.9827 | 1.0000 | 6 / 6 |
| base64-work | 1.0038 | 1.0000 | 6 / 6 |
| base32-work | 1.0134 | 1.0000 | 6 / 6 |
| csv-benchmark | 1.0259 | 1.0058 | 6 / 6 |
| json-work | 0.9981 | 1.0000 | 6 / 6 |
| msgpack-benchmark | 1.0043 | 1.0000 | 6 / 6 |
| lcs-benchmark | 0.9982 | 1.0000 | 6 / 6 |
| tuple-arrays-benchmark | 0.9994 | 0.9994 | 6 / 6 |
| struct-work | 0.9974 | 1.0000 | 6 / 6 |
| matrix-work | 0.9949 | 1.0000 | 6 / 6 |
| matrix-simd-work | 0.9991 | 1.0000 | 6 / 6 |
| gc-work | 1.0132 | 1.0085 | 6 / 6 |
| float-pressure-work | 0.9898 | 1.0000 | 6 / 6 |
| ffi-pressure-work | 0.9992 | 1.0000 | 6 / 6 |
| branch-pressure-work | 0.9879 | 1.0000 | 6 / 6 |
| integer-pressure-work | 0.9977 | 1.0000 | 6 / 6 |
| simd-pressure-work | 1.0003 | 1.0000 | 6 / 6 |
| gc-pressure-work | 1.0315 | 1.0206 | 6 / 6 |

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

Per-round geometric-mean ratios: {"1": {"cpu_seconds": 1.0280879103666047, "instructions": 1.0127139630186193, "ns": 1.0282873164394062}, "2": {"cpu_seconds": 1.0224916371138824, "instructions": 1.0127238843422346, "ns": 1.0226133021503727}}

| Workload | CPU ratio | Retired ratio | Samples before / after |
|---|---:|---:|---:|
| norm-work | 1.0003 | 1.0000 | 6 / 6 |
| nbody-work | 1.0063 | 1.0000 | 6 / 6 |
| nbody-simd-work | 1.0025 | 1.0000 | 6 / 6 |
| trees-work | 1.0239 | 1.0001 | 6 / 6 |
| fannkuch-work | 1.0019 | 1.0000 | 6 / 6 |
| sieve-work | 0.9987 | 1.0000 | 6 / 6 |
| pi-work | 0.9978 | 1.0000 | 6 / 6 |
| md5-work | 0.9828 | 1.0000 | 6 / 6 |
| sha1-work | 0.9438 | 0.9541 | 6 / 6 |
| base64-work | 1.0177 | 1.0000 | 6 / 6 |
| base32-work | 0.9974 | 1.0000 | 6 / 6 |
| csv-benchmark | 1.0120 | 1.0059 | 6 / 6 |
| json-work | 0.9939 | 1.0000 | 6 / 6 |
| msgpack-benchmark | 0.9968 | 1.0000 | 6 / 6 |
| lcs-benchmark | 0.9927 | 1.0000 | 6 / 6 |
| tuple-arrays-benchmark | 1.0067 | 1.0000 | 6 / 6 |
| struct-work | 0.9944 | 1.0000 | 6 / 6 |
| matrix-work | 0.9957 | 1.0000 | 6 / 6 |
| matrix-simd-work | 0.9923 | 0.9999 | 6 / 6 |
| gc-work | 1.0238 | 1.0088 | 6 / 6 |
| float-pressure-work | 1.1268 | 1.0670 | 6 / 6 |
| ffi-pressure-work | 1.0057 | 1.0000 | 6 / 6 |
| branch-pressure-work | 1.1116 | 1.0716 | 6 / 6 |
| integer-pressure-work | 1.2145 | 1.1577 | 6 / 6 |
| simd-pressure-work | 1.0953 | 1.0616 | 6 / 6 |
| gc-pressure-work | 1.0629 | 1.0211 | 6 / 6 |

| Kernel / index | Code bytes before → after | Spills before → after | Reloads before → after | Copies before → after |
|---|---:|---:|---:|---:|
| float-pressure|0 | 1248 → 1376 | 18 → 35 | 18 → 18 | 0 → 0 |
| ffi-pressure|1 | 1616 → 1616 | 34 → 34 | 33 → 33 | 0 → 0 |
| branch-pressure|2 | 1840 → 2016 | 31 → 47 | 31 → 36 | 0 → 0 |
| integer-pressure|3 | 688 → 864 | 29 → 57 | 29 → 29 | 0 → 0 |
| simd-pressure|4 | 1488 → 1616 | 18 → 35 | 18 → 18 | 0 → 0 |
| gc-pressure|5 | 11984 → 12352 | 223 → 268 | 223 → 228 | 0 → 0 |
| spectral-norm|6 | 3104 → 3104 | 20 → 20 | 20 → 20 | 1 → 1 |
| nbody|7 | 2960 → 2960 | 0 → 0 | 0 → 0 | 6 → 6 |
| nbody|8 | 4336 → 4336 | 33 → 33 | 18 → 18 | 0 → 0 |
| fannkuch|9 | 3392 → 3392 | 1 → 1 | 1 → 1 | 0 → 0 |
| binary-trees|10 | 8640 → 8640 | 12 → 12 | 12 → 12 | 10 → 10 |
| struct-arrays-bench|11 | 1600 → 1600 | 15 → 15 | 16 → 16 | 5 → 5 |

## backtracking

Per-round geometric-mean ratios: {"1": {"cpu_seconds": 1.0202047466667983, "instructions": 1.0218006282726342, "ns": 1.0201992601076697}, "2": {"cpu_seconds": 1.0193994703829512, "instructions": 1.0217992145543677, "ns": 1.019057054730789}}

| Workload | CPU ratio | Retired ratio | Samples before / after |
|---|---:|---:|---:|
| norm-work | 1.0169 | 1.0213 | 6 / 6 |
| nbody-work | 1.0080 | 1.0191 | 6 / 6 |
| nbody-simd-work | 1.0011 | 1.0061 | 6 / 6 |
| trees-work | 1.0193 | 1.0205 | 6 / 6 |
| fannkuch-work | 1.0138 | 1.0147 | 6 / 6 |
| sieve-work | 1.0448 | 1.0694 | 6 / 6 |
| pi-work | 0.9960 | 1.0012 | 6 / 6 |
| md5-work | 1.0073 | 1.0211 | 6 / 6 |
| sha1-work | 0.9970 | 1.0174 | 6 / 6 |
| base64-work | 1.0151 | 1.0320 | 6 / 6 |
| base32-work | 0.9995 | 1.0225 | 6 / 6 |
| csv-benchmark | 1.0211 | 1.0272 | 6 / 6 |
| json-work | 0.9898 | 1.0213 | 6 / 6 |
| msgpack-benchmark | 0.9945 | 1.0088 | 6 / 6 |
| lcs-benchmark | 1.0010 | 1.0243 | 6 / 6 |
| tuple-arrays-benchmark | 1.0517 | 1.0105 | 6 / 6 |
| struct-work | 1.1137 | 1.0316 | 6 / 6 |
| matrix-work | 1.0008 | 1.0191 | 6 / 6 |
| matrix-simd-work | 1.0006 | 1.0179 | 6 / 6 |
| gc-work | 1.0075 | 1.0117 | 6 / 6 |
| float-pressure-work | 0.9905 | 1.0119 | 6 / 6 |
| ffi-pressure-work | 1.2052 | 1.1027 | 6 / 6 |
| branch-pressure-work | 0.9962 | 1.0075 | 6 / 6 |
| integer-pressure-work | 1.0209 | 1.0113 | 6 / 6 |
| simd-pressure-work | 1.0005 | 1.0000 | 6 / 6 |
| gc-pressure-work | 1.0298 | 1.0210 | 6 / 6 |

| Kernel / index | Code bytes before → after | Spills before → after | Reloads before → after | Copies before → after |
|---|---:|---:|---:|---:|
| float-pressure|0 | 1232 → 1232 | 17 → 17 | 17 → 17 | 0 → 0 |
| ffi-pressure|1 | 1616 → 2000 | 34 → 50 | 33 → 48 | 0 → 24 |
| branch-pressure|2 | 1840 → 1856 | 31 → 31 | 31 → 31 | 0 → 1 |
| integer-pressure|3 | 688 → 704 | 29 → 29 | 29 → 29 | 0 → 0 |
| simd-pressure|4 | 1472 → 1472 | 17 → 17 | 17 → 17 | 0 → 0 |
| gc-pressure|5 | 12064 → 10704 | 228 → 214 | 228 → 214 | 0 → 0 |
| spectral-norm|6 | 3104 → 3152 | 20 → 20 | 20 → 20 | 1 → 1 |
| nbody|7 | 2960 → 2992 | 0 → 0 | 0 → 0 | 6 → 6 |
| nbody|8 | 4336 → 4304 | 33 → 38 | 18 → 18 | 0 → 14 |
| fannkuch|9 | 3392 → 3424 | 1 → 1 | 1 → 1 | 0 → 0 |
| binary-trees|10 | 8640 → 8800 | 12 → 12 | 12 → 12 | 10 → 10 |
| struct-arrays-bench|11 | 1584 → 1792 | 15 → 23 | 16 → 25 | 1 → 12 |

## chordal

Per-round geometric-mean ratios: {"1": {"cpu_seconds": 1.0344089734846416, "instructions": 0.9766064708291283, "ns": 1.0343681110367537}, "2": {"cpu_seconds": 0.9988514349218862, "instructions": 0.9766105189924873, "ns": 0.9985768797960201}}

| Workload | CPU ratio | Retired ratio | Samples before / after |
|---|---:|---:|---:|
| norm-work | 0.9715 | 0.9852 | 6 / 6 |
| nbody-work | 1.0633 | 1.0228 | 6 / 6 |
| nbody-simd-work | 0.9671 | 0.9452 | 6 / 6 |
| trees-work | 1.0188 | 1.0139 | 6 / 6 |
| fannkuch-work | 0.9988 | 0.9862 | 6 / 6 |
| sieve-work | 0.9527 | 0.9288 | 6 / 6 |
| pi-work | 0.9998 | 0.9991 | 6 / 6 |
| md5-work | 0.9912 | 0.9506 | 6 / 6 |
| sha1-work | 0.9679 | 0.9151 | 6 / 6 |
| base64-work | 1.0620 | 1.0117 | 6 / 6 |
| base32-work | 1.0019 | 1.0045 | 6 / 6 |
| csv-benchmark | 1.0321 | 1.0543 | 6 / 6 |
| json-work | 1.0536 | 1.0421 | 6 / 6 |
| msgpack-benchmark | 1.0082 | 1.0031 | 6 / 6 |
| lcs-benchmark | 0.9872 | 0.9702 | 6 / 6 |
| tuple-arrays-benchmark | 1.0024 | 0.9988 | 6 / 6 |
| struct-work | 1.0209 | 0.9440 | 6 / 6 |
| matrix-work | 1.0099 | 0.9895 | 6 / 6 |
| matrix-simd-work | 0.9665 | 0.9057 | 6 / 6 |
| gc-work | 1.0247 | 1.0036 | 6 / 6 |
| float-pressure-work | 0.9369 | 0.9193 | 6 / 6 |
| ffi-pressure-work | 1.1732 | 0.9272 | 6 / 6 |
| branch-pressure-work | 1.2641 | 1.0034 | 6 / 6 |
| integer-pressure-work | 0.9807 | 0.9678 | 6 / 6 |
| simd-pressure-work | 0.9586 | 0.9026 | 6 / 6 |
| gc-pressure-work | 1.0525 | 1.0212 | 6 / 6 |

| Kernel / index | Code bytes before → after | Spills before → after | Reloads before → after | Copies before → after |
|---|---:|---:|---:|---:|
| float-pressure|0 | 1408 → 1312 | 19 → 17 | 19 → 17 | 0 → 0 |
| ffi-pressure|1 | 1760 → 1984 | 34 → 34 | 33 → 65 | 0 → 0 |
| branch-pressure|2 | 2000 → 2256 | 31 → 48 | 31 → 45 | 0 → 9 |
| integer-pressure|3 | 752 → 688 | 30 → 28 | 30 → 28 | 0 → 0 |
| simd-pressure|4 | 1632 → 1536 | 19 → 17 | 19 → 17 | 0 → 0 |
| gc-pressure|5 | 12432 → 11824 | 252 → 214 | 252 → 214 | 0 → 0 |
| spectral-norm|6 | 3408 → 3568 | 20 → 43 | 20 → 23 | 18 → 83 |
| nbody|7 | 3072 → 3136 | 1 → 0 | 1 → 0 | 7 → 63 |
| nbody|8 | 4656 → 4656 | 38 → 47 | 18 → 18 | 15 → 46 |
| fannkuch|9 | 3520 → 3568 | 3 → 3 | 3 → 2 | 12 → 37 |
| binary-trees|10 | 8896 → 9152 | 13 → 24 | 13 → 12 | 20 → 107 |
| struct-arrays-bench|11 | 1888 → 1744 | 16 → 13 | 17 → 16 | 5 → 13 |
