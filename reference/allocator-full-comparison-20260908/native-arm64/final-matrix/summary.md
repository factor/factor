# Same-host candidate / baseline allocator comparison

All captured outputs agree; original independent checks passed and six pressure checks assert in Factor.

Ratios below 1 favor the candidate. Runtime aggregates equally weight 26 workloads and use per-workload medians; warmups and checked runs are excluded. Each allocator is compared with its own baseline implementation.

| Allocator | Runtime CPU | Runtime instructions | Compile CPU | Compile instructions |
|---|---:|---:|---:|---:|
| linear-scan | 1.0204 | 1.0030 | 1.2367 | 1.0729 |
| greedy | 1.1158 | 1.0116 | 1.1398 | 1.1087 |
| backtracking | 1.1365 | 1.0312 | 1.0914 | 1.4027 |
| chordal | 1.3899 | 1.0551 | 1.5273 | 1.4775 |

## linear-scan

Per-round geometric-mean ratios: {"1": {"cpu_seconds": 0.9534406418073489, "instructions": 1.0016207034820446, "ns": 0.9609735651667027}, "2": {"cpu_seconds": 1.0865479782819223, "instructions": 1.004419544297393, "ns": 1.1378921759866174}}

| Workload | CPU ratio | Retired ratio | Samples before / after |
|---|---:|---:|---:|
| norm-work | 1.1966 | 1.0014 | 6 / 6 |
| nbody-work | 1.0537 | 1.0022 | 6 / 6 |
| nbody-simd-work | 1.2039 | 1.0020 | 6 / 6 |
| trees-work | 1.1975 | 1.0016 | 6 / 6 |
| fannkuch-work | 1.1645 | 1.0028 | 6 / 6 |
| sieve-work | 0.7112 | 1.0013 | 6 / 6 |
| pi-work | 1.1613 | 1.0047 | 6 / 6 |
| md5-work | 0.8146 | 1.0019 | 6 / 6 |
| sha1-work | 0.7854 | 1.0017 | 6 / 6 |
| base64-work | 0.8147 | 1.0012 | 6 / 6 |
| base32-work | 1.0978 | 1.0011 | 6 / 6 |
| csv-benchmark | 1.0622 | 1.0018 | 6 / 6 |
| json-work | 1.0513 | 1.0036 | 6 / 6 |
| msgpack-benchmark | 0.9847 | 1.0025 | 6 / 6 |
| lcs-benchmark | 0.8879 | 1.0023 | 6 / 6 |
| tuple-arrays-benchmark | 0.9921 | 1.0017 | 6 / 6 |
| struct-work | 1.1424 | 1.0031 | 6 / 6 |
| matrix-work | 1.1995 | 1.0026 | 6 / 6 |
| matrix-simd-work | 1.2439 | 1.0025 | 6 / 6 |
| gc-work | 0.7348 | 1.0009 | 6 / 6 |
| float-pressure-work | 1.0129 | 1.0020 | 6 / 6 |
| ffi-pressure-work | 1.0886 | 1.0025 | 6 / 6 |
| branch-pressure-work | 1.0070 | 1.0018 | 6 / 6 |
| integer-pressure-work | 1.0584 | 1.0018 | 6 / 6 |
| simd-pressure-work | 1.0861 | 1.0015 | 6 / 6 |
| gc-pressure-work | 1.0913 | 1.0264 | 6 / 6 |

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
| nbody|8 | 4144 → 4144 | 33 → 33 | 18 → 18 | 0 → 0 |
| fannkuch|9 | 3424 → 3424 | 1 → 1 | 1 → 1 | 0 → 0 |
| binary-trees|10 | 8784 → 8784 | 12 → 12 | 12 → 12 | 10 → 10 |
| struct-arrays-bench|11 | 1648 → 1648 | 14 → 14 | 15 → 15 | 5 → 5 |

## greedy

Per-round geometric-mean ratios: {"1": {"cpu_seconds": 1.1975491402050715, "instructions": 1.0118998641607264, "ns": 1.2207430340544096}, "2": {"cpu_seconds": 0.9992293856742739, "instructions": 1.0115505440835157, "ns": 0.989725894803161}}

| Workload | CPU ratio | Retired ratio | Samples before / after |
|---|---:|---:|---:|
| norm-work | 1.0263 | 1.0003 | 6 / 6 |
| nbody-work | 1.0339 | 0.9999 | 6 / 6 |
| nbody-simd-work | 1.0536 | 1.0001 | 6 / 6 |
| trees-work | 1.0668 | 1.0000 | 6 / 6 |
| fannkuch-work | 1.0449 | 0.9999 | 6 / 6 |
| sieve-work | 1.0531 | 0.9997 | 6 / 6 |
| pi-work | 1.1148 | 1.0003 | 6 / 6 |
| md5-work | 1.1026 | 0.9994 | 6 / 6 |
| sha1-work | 1.1002 | 0.9994 | 6 / 6 |
| base64-work | 1.1102 | 0.9998 | 6 / 6 |
| base32-work | 1.0647 | 0.9996 | 6 / 6 |
| csv-benchmark | 1.1076 | 0.9997 | 6 / 6 |
| json-work | 1.0886 | 1.0000 | 6 / 6 |
| msgpack-benchmark | 1.1135 | 1.0005 | 6 / 6 |
| lcs-benchmark | 1.1399 | 1.0000 | 6 / 6 |
| tuple-arrays-benchmark | 1.1211 | 0.9992 | 6 / 6 |
| struct-work | 1.1649 | 0.9989 | 6 / 6 |
| matrix-work | 1.1072 | 0.9996 | 6 / 6 |
| matrix-simd-work | 1.1241 | 0.9996 | 6 / 6 |
| gc-work | 1.1075 | 0.9995 | 6 / 6 |
| float-pressure-work | 1.2565 | 1.0512 | 6 / 6 |
| ffi-pressure-work | 1.1061 | 0.9999 | 6 / 6 |
| branch-pressure-work | 1.2389 | 1.0612 | 6 / 6 |
| integer-pressure-work | 1.3676 | 1.1366 | 6 / 6 |
| simd-pressure-work | 1.2402 | 1.0466 | 6 / 6 |
| gc-pressure-work | 1.0224 | 1.0230 | 6 / 6 |

| Kernel / index | Code bytes before → after | Spills before → after | Reloads before → after | Copies before → after |
|---|---:|---:|---:|---:|
| float-pressure|0 | 832 → 880 | 11 → 22 | 11 → 11 | 0 → 0 |
| ffi-pressure|1 | 1056 → 1056 | 34 → 34 | 33 → 33 | 0 → 0 |
| branch-pressure|2 | 1264 → 1328 | 31 → 45 | 31 → 31 | 0 → 0 |
| integer-pressure|3 | 576 → 672 | 25 → 49 | 25 → 25 | 0 → 0 |
| simd-pressure|4 | 1136 → 1184 | 11 → 22 | 11 → 11 | 0 → 0 |
| gc-pressure|5 | 8960 → 9056 | 141 → 163 | 141 → 142 | 0 → 0 |
| spectral-norm|6 | 2992 → 2992 | 20 → 20 | 20 → 20 | 1 → 1 |
| nbody|7 | 3120 → 3120 | 0 → 0 | 0 → 0 | 6 → 6 |
| nbody|8 | 4144 → 4144 | 33 → 33 | 18 → 18 | 0 → 0 |
| fannkuch|9 | 3424 → 3424 | 1 → 1 | 1 → 1 | 0 → 0 |
| binary-trees|10 | 8784 → 8784 | 12 → 12 | 12 → 12 | 10 → 10 |
| struct-arrays-bench|11 | 1552 → 1552 | 14 → 14 | 15 → 15 | 3 → 3 |

## backtracking

Per-round geometric-mean ratios: {"1": {"cpu_seconds": 1.158090131804228, "instructions": 1.0303465219203989, "ns": 1.1591824464695766}, "2": {"cpu_seconds": 1.0218197696084532, "instructions": 1.032004002562005, "ns": 1.0417327958456164}}

| Workload | CPU ratio | Retired ratio | Samples before / after |
|---|---:|---:|---:|
| norm-work | 1.0655 | 1.0226 | 6 / 6 |
| nbody-work | 1.0662 | 1.0152 | 6 / 6 |
| nbody-simd-work | 1.0377 | 1.0061 | 6 / 6 |
| trees-work | 1.0737 | 1.0288 | 6 / 6 |
| fannkuch-work | 1.0987 | 1.0253 | 6 / 6 |
| sieve-work | 1.0268 | 1.0774 | 6 / 6 |
| pi-work | 1.0634 | 1.0043 | 6 / 6 |
| md5-work | 1.0864 | 1.0276 | 6 / 6 |
| sha1-work | 1.0365 | 1.0156 | 6 / 6 |
| base64-work | 1.1211 | 1.0212 | 6 / 6 |
| base32-work | 1.1034 | 1.0242 | 6 / 6 |
| csv-benchmark | 1.1053 | 1.0330 | 6 / 6 |
| json-work | 1.1056 | 1.0265 | 6 / 6 |
| msgpack-benchmark | 1.0795 | 1.0123 | 6 / 6 |
| lcs-benchmark | 1.0963 | 1.0301 | 6 / 6 |
| tuple-arrays-benchmark | 1.0201 | 1.0163 | 6 / 6 |
| struct-work | 1.4672 | 1.0950 | 6 / 6 |
| matrix-work | 1.1514 | 1.0300 | 6 / 6 |
| matrix-simd-work | 1.1613 | 1.0317 | 6 / 6 |
| gc-work | 1.1552 | 1.0057 | 6 / 6 |
| float-pressure-work | 1.1922 | 1.0288 | 6 / 6 |
| ffi-pressure-work | 1.3853 | 1.1697 | 6 / 6 |
| branch-pressure-work | 1.1315 | 1.0178 | 6 / 6 |
| integer-pressure-work | 1.0388 | 1.0121 | 6 / 6 |
| simd-pressure-work | 1.8202 | 1.0224 | 6 / 6 |
| gc-pressure-work | 1.1140 | 1.0258 | 6 / 6 |

| Kernel / index | Code bytes before → after | Spills before → after | Reloads before → after | Copies before → after |
|---|---:|---:|---:|---:|
| float-pressure|0 | 832 → 832 | 11 → 11 | 11 → 11 | 0 → 0 |
| ffi-pressure|1 | 1056 → 1392 | 34 → 58 | 33 → 55 | 0 → 36 |
| branch-pressure|2 | 1264 → 1264 | 31 → 31 | 31 → 31 | 0 → 0 |
| integer-pressure|3 | 576 → 576 | 25 → 25 | 25 → 25 | 0 → 0 |
| simd-pressure|4 | 1136 → 1136 | 11 → 11 | 11 → 11 | 0 → 0 |
| gc-pressure|5 | 8976 → 8960 | 142 → 140 | 142 → 140 | 0 → 0 |
| spectral-norm|6 | 2992 → 3008 | 20 → 20 | 20 → 20 | 1 → 1 |
| nbody|7 | 3120 → 3120 | 0 → 0 | 0 → 0 | 6 → 6 |
| nbody|8 | 4128 → 4160 | 33 → 38 | 18 → 18 | 0 → 14 |
| fannkuch|9 | 3424 → 3504 | 1 → 1 | 1 → 1 | 0 → 0 |
| binary-trees|10 | 8784 → 9008 | 12 → 12 | 12 → 12 | 10 → 10 |
| struct-arrays-bench|11 | 1632 → 1680 | 14 → 21 | 15 → 23 | 1 → 12 |

## chordal

Per-round geometric-mean ratios: {"1": {"cpu_seconds": 1.6684308268385195, "instructions": 1.056771654708004, "ns": 1.731050909741372}, "2": {"cpu_seconds": 1.106346192879986, "instructions": 1.0529213579881331, "ns": 1.1367507944103803}}

| Workload | CPU ratio | Retired ratio | Samples before / after |
|---|---:|---:|---:|
| norm-work | 1.7050 | 1.2955 | 6 / 6 |
| nbody-work | 1.3403 | 1.0992 | 6 / 6 |
| nbody-simd-work | 1.3374 | 1.1455 | 6 / 6 |
| trees-work | 1.2706 | 1.0256 | 6 / 6 |
| fannkuch-work | 1.2713 | 1.0067 | 6 / 6 |
| sieve-work | 1.3003 | 1.0113 | 6 / 6 |
| pi-work | 1.3116 | 1.0040 | 6 / 6 |
| md5-work | 1.2913 | 1.0082 | 6 / 6 |
| sha1-work | 1.3385 | 1.0096 | 6 / 6 |
| base64-work | 1.4430 | 1.0690 | 6 / 6 |
| base32-work | 1.2866 | 1.0104 | 6 / 6 |
| csv-benchmark | 2.2428 | 1.3621 | 6 / 6 |
| json-work | 1.3942 | 1.0826 | 6 / 6 |
| msgpack-benchmark | 1.3811 | 1.0205 | 6 / 6 |
| lcs-benchmark | 1.3628 | 1.0121 | 6 / 6 |
| tuple-arrays-benchmark | 1.2812 | 1.0326 | 6 / 6 |
| struct-work | 1.4587 | 1.0232 | 6 / 6 |
| matrix-work | 1.3261 | 1.0181 | 6 / 6 |
| matrix-simd-work | 1.3845 | 1.0152 | 6 / 6 |
| gc-work | 1.3420 | 1.0042 | 6 / 6 |
| float-pressure-work | 1.3524 | 1.0416 | 6 / 6 |
| ffi-pressure-work | 1.4560 | 1.0433 | 6 / 6 |
| branch-pressure-work | 1.5791 | 1.1586 | 6 / 6 |
| integer-pressure-work | 1.2587 | 0.9791 | 6 / 6 |
| simd-pressure-work | 1.3458 | 1.0142 | 6 / 6 |
| gc-pressure-work | 1.3529 | 1.0262 | 6 / 6 |

| Kernel / index | Code bytes before → after | Spills before → after | Reloads before → after | Copies before → after |
|---|---:|---:|---:|---:|
| float-pressure|0 | 848 → 832 | 12 → 11 | 12 → 11 | 0 → 0 |
| ffi-pressure|1 | 1056 → 1232 | 34 → 34 | 33 → 77 | 0 → 0 |
| branch-pressure|2 | 1264 → 1472 | 31 → 55 | 31 → 46 | 0 → 11 |
| integer-pressure|3 | 576 → 560 | 26 → 24 | 26 → 24 | 0 → 0 |
| simd-pressure|4 | 1152 → 1136 | 12 → 11 | 12 → 11 | 0 → 0 |
| gc-pressure|5 | 9216 → 8960 | 172 → 140 | 172 → 140 | 0 → 0 |
| spectral-norm|6 | 3120 → 3504 | 20 → 43 | 20 → 23 | 18 → 92 |
| nbody|7 | 3152 → 3312 | 1 → 0 | 1 → 0 | 7 → 52 |
| nbody|8 | 4256 → 4416 | 38 → 47 | 18 → 18 | 15 → 58 |
| fannkuch|9 | 3568 → 3664 | 4 → 3 | 4 → 2 | 10 → 38 |
| binary-trees|10 | 9056 → 9408 | 13 → 25 | 13 → 13 | 21 → 92 |
| struct-arrays-bench|11 | 1712 → 1696 | 14 → 13 | 15 → 14 | 5 → 15 |
