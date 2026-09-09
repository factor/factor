# Same-host candidate / baseline allocator comparison

All captured outputs agree; original independent checks passed and six pressure checks assert in Factor.

Ratios below 1 favor the candidate. Runtime aggregates equally weight 26 workloads and use per-workload medians; warmups and checked runs are excluded. Each allocator is compared with its own baseline implementation.

| Allocator | Runtime CPU | Runtime instructions | Compile CPU | Compile instructions |
|---|---:|---:|---:|---:|
| linear-scan | 1.1002 | 1.0001 | 1.0071 | 1.0005 |
| greedy | 1.0260 | 0.9897 | 0.9915 | 1.0034 |
| backtracking | 0.9617 | 0.9949 | 0.7849 | 0.7599 |
| chordal | 0.9568 | 0.9911 | 0.9984 | 1.0037 |

## linear-scan

Per-round geometric-mean ratios: {"1": {"cpu_seconds": 1.0904688853331936, "instructions": 1.0001517437862695, "ns": 1.0945914203527198}, "2": {"cpu_seconds": 1.0321310035504518, "instructions": 0.9999819620934514, "ns": 1.032840372834096}}

| Workload | CPU ratio | Retired ratio | Samples before / after |
|---|---:|---:|---:|
| norm-work | 1.0383 | 0.9999 | 6 / 6 |
| nbody-work | 1.0394 | 0.9998 | 6 / 6 |
| nbody-simd-work | 1.0397 | 1.0000 | 6 / 6 |
| trees-work | 1.0752 | 1.0000 | 6 / 6 |
| fannkuch-work | 1.0844 | 1.0000 | 6 / 6 |
| sieve-work | 1.0660 | 1.0001 | 6 / 6 |
| pi-work | 1.0819 | 1.0000 | 6 / 6 |
| md5-work | 1.0710 | 1.0002 | 6 / 6 |
| sha1-work | 1.0856 | 1.0001 | 6 / 6 |
| base64-work | 1.0762 | 1.0001 | 6 / 6 |
| base32-work | 1.1066 | 1.0001 | 6 / 6 |
| csv-benchmark | 1.0710 | 1.0001 | 6 / 6 |
| json-work | 1.1147 | 1.0001 | 6 / 6 |
| msgpack-benchmark | 1.1307 | 1.0002 | 6 / 6 |
| lcs-benchmark | 1.1364 | 1.0002 | 6 / 6 |
| tuple-arrays-benchmark | 1.0655 | 1.0001 | 6 / 6 |
| struct-work | 1.1361 | 1.0002 | 6 / 6 |
| matrix-work | 1.1364 | 1.0001 | 6 / 6 |
| matrix-simd-work | 1.1315 | 1.0001 | 6 / 6 |
| gc-work | 1.0899 | 1.0003 | 6 / 6 |
| float-pressure-work | 1.1650 | 1.0001 | 6 / 6 |
| ffi-pressure-work | 1.1331 | 1.0002 | 6 / 6 |
| branch-pressure-work | 1.1714 | 1.0002 | 6 / 6 |
| integer-pressure-work | 1.0727 | 1.0004 | 6 / 6 |
| simd-pressure-work | 1.3321 | 1.0007 | 6 / 6 |
| gc-pressure-work | 0.9965 | 0.9995 | 6 / 6 |

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

Per-round geometric-mean ratios: {"1": {"cpu_seconds": 1.1017738434987212, "instructions": 0.9904500078933263, "ns": 1.1307181747083093}, "2": {"cpu_seconds": 0.9705077484992707, "instructions": 0.9892017502474215, "ns": 0.9701493212056495}}

| Workload | CPU ratio | Retired ratio | Samples before / after |
|---|---:|---:|---:|
| norm-work | 1.0182 | 1.0003 | 6 / 6 |
| nbody-work | 1.0483 | 1.0005 | 6 / 6 |
| nbody-simd-work | 1.0279 | 1.0004 | 6 / 6 |
| trees-work | 1.0616 | 1.0006 | 6 / 6 |
| fannkuch-work | 1.0576 | 1.0007 | 6 / 6 |
| sieve-work | 1.0503 | 1.0005 | 6 / 6 |
| pi-work | 1.0786 | 1.0011 | 6 / 6 |
| md5-work | 1.0442 | 1.0007 | 6 / 6 |
| sha1-work | 1.0513 | 1.0004 | 6 / 6 |
| base64-work | 1.0553 | 1.0005 | 6 / 6 |
| base32-work | 1.0518 | 1.0003 | 6 / 6 |
| csv-benchmark | 1.0705 | 1.0004 | 6 / 6 |
| json-work | 1.0540 | 1.0005 | 6 / 6 |
| msgpack-benchmark | 1.0623 | 1.0004 | 6 / 6 |
| lcs-benchmark | 1.0328 | 1.0006 | 6 / 6 |
| tuple-arrays-benchmark | 0.9975 | 1.0002 | 6 / 6 |
| struct-work | 1.0728 | 1.0006 | 6 / 6 |
| matrix-work | 1.0564 | 1.0006 | 6 / 6 |
| matrix-simd-work | 1.0629 | 1.0003 | 6 / 6 |
| gc-work | 1.0628 | 1.0003 | 6 / 6 |
| float-pressure-work | 0.9245 | 0.9520 | 6 / 6 |
| ffi-pressure-work | 1.0752 | 1.0005 | 6 / 6 |
| branch-pressure-work | 0.9094 | 0.9427 | 6 / 6 |
| integer-pressure-work | 0.7731 | 0.8802 | 6 / 6 |
| simd-pressure-work | 0.9348 | 0.9562 | 6 / 6 |
| gc-pressure-work | 1.1097 | 1.0017 | 6 / 6 |

| Kernel / index | Code bytes before → after | Spills before → after | Reloads before → after | Copies before → after |
|---|---:|---:|---:|---:|
| float-pressure|0 | 880 → 832 | 22 → 11 | 11 → 11 | 0 → 0 |
| ffi-pressure|1 | 1056 → 1056 | 34 → 34 | 33 → 33 | 0 → 0 |
| branch-pressure|2 | 1328 → 1264 | 45 → 31 | 31 → 31 | 0 → 0 |
| integer-pressure|3 | 672 → 576 | 49 → 25 | 25 → 25 | 0 → 0 |
| simd-pressure|4 | 1184 → 1136 | 22 → 11 | 11 → 11 | 0 → 0 |
| gc-pressure|5 | 9056 → 8976 | 163 → 143 | 142 → 142 | 0 → 0 |
| spectral-norm|6 | 2992 → 2992 | 20 → 20 | 20 → 20 | 1 → 1 |
| nbody|7 | 3120 → 3120 | 0 → 0 | 0 → 0 | 6 → 6 |
| nbody|8 | 4144 → 4144 | 33 → 33 | 18 → 18 | 0 → 0 |
| fannkuch|9 | 3424 → 3424 | 1 → 1 | 1 → 1 | 0 → 0 |
| binary-trees|10 | 8784 → 8784 | 12 → 12 | 12 → 12 | 10 → 10 |
| struct-arrays-bench|11 | 1552 → 1552 | 14 → 14 | 15 → 15 | 3 → 3 |

## backtracking

Per-round geometric-mean ratios: {"1": {"cpu_seconds": 1.0071920076018703, "instructions": 0.9946460419842925, "ns": 1.000870884212124}, "2": {"cpu_seconds": 0.9448359260236379, "instructions": 0.9950638634706129, "ns": 0.9451914416929075}}

| Workload | CPU ratio | Retired ratio | Samples before / after |
|---|---:|---:|---:|
| norm-work | 0.9939 | 0.9999 | 6 / 6 |
| nbody-work | 0.9794 | 1.0000 | 6 / 6 |
| nbody-simd-work | 0.9683 | 0.9999 | 6 / 6 |
| trees-work | 0.9939 | 0.9999 | 6 / 6 |
| fannkuch-work | 0.9637 | 0.9998 | 6 / 6 |
| sieve-work | 0.9895 | 1.0000 | 6 / 6 |
| pi-work | 0.9694 | 0.9996 | 6 / 6 |
| md5-work | 0.9439 | 0.9997 | 6 / 6 |
| sha1-work | 0.9799 | 0.9999 | 6 / 6 |
| base64-work | 0.9529 | 0.9998 | 6 / 6 |
| base32-work | 0.9698 | 0.9999 | 6 / 6 |
| csv-benchmark | 0.9806 | 0.9989 | 6 / 6 |
| json-work | 0.9753 | 0.9995 | 6 / 6 |
| msgpack-benchmark | 0.9777 | 0.9999 | 6 / 6 |
| lcs-benchmark | 0.9891 | 1.0000 | 6 / 6 |
| tuple-arrays-benchmark | 0.9716 | 0.9999 | 6 / 6 |
| struct-work | 0.7679 | 0.9373 | 6 / 6 |
| matrix-work | 0.9720 | 0.9999 | 6 / 6 |
| matrix-simd-work | 0.9682 | 0.9998 | 6 / 6 |
| gc-work | 0.9765 | 0.9998 | 6 / 6 |
| float-pressure-work | 0.9486 | 0.9997 | 6 / 6 |
| ffi-pressure-work | 0.9632 | 0.9536 | 6 / 6 |
| branch-pressure-work | 0.9617 | 0.9953 | 6 / 6 |
| integer-pressure-work | 0.9720 | 0.9884 | 6 / 6 |
| simd-pressure-work | 0.9640 | 0.9997 | 6 / 6 |
| gc-pressure-work | 0.9362 | 0.9994 | 6 / 6 |

| Kernel / index | Code bytes before → after | Spills before → after | Reloads before → after | Copies before → after |
|---|---:|---:|---:|---:|
| float-pressure|0 | 832 → 832 | 11 → 11 | 11 → 11 | 0 → 0 |
| ffi-pressure|1 | 1392 → 1344 | 58 → 60 | 55 → 57 | 36 → 20 |
| branch-pressure|2 | 1264 → 1264 | 31 → 31 | 31 → 31 | 0 → 0 |
| integer-pressure|3 | 576 → 576 | 25 → 25 | 25 → 25 | 0 → 0 |
| simd-pressure|4 | 1136 → 1136 | 11 → 11 | 11 → 11 | 0 → 0 |
| gc-pressure|5 | 8960 → 8960 | 140 → 140 | 140 → 140 | 0 → 0 |
| spectral-norm|6 | 3008 → 3008 | 20 → 20 | 20 → 20 | 1 → 1 |
| nbody|7 | 3120 → 3120 | 0 → 0 | 0 → 0 | 6 → 6 |
| nbody|8 | 4160 → 4112 | 38 → 38 | 18 → 18 | 14 → 0 |
| fannkuch|9 | 3504 → 3504 | 1 → 1 | 1 → 1 | 0 → 0 |
| binary-trees|10 | 9008 → 9008 | 12 → 12 | 12 → 12 | 10 → 10 |
| struct-arrays-bench|11 | 1680 → 1584 | 21 → 12 | 23 → 14 | 12 → 8 |

## chordal

Per-round geometric-mean ratios: {"1": {"cpu_seconds": 0.8830699754513115, "instructions": 0.9906477479936511, "ns": 0.87442784247021}, "2": {"cpu_seconds": 1.0275022740375221, "instructions": 0.9913442536094905, "ns": 1.0301273309450822}}

| Workload | CPU ratio | Retired ratio | Samples before / after |
|---|---:|---:|---:|
| norm-work | 0.9767 | 0.9997 | 6 / 6 |
| nbody-work | 0.9458 | 0.9835 | 6 / 6 |
| nbody-simd-work | 0.9633 | 0.9768 | 6 / 6 |
| trees-work | 0.9250 | 0.9806 | 6 / 6 |
| fannkuch-work | 0.9670 | 0.9995 | 6 / 6 |
| sieve-work | 0.9698 | 1.0000 | 6 / 6 |
| pi-work | 0.9742 | 1.0000 | 6 / 6 |
| md5-work | 1.0083 | 0.9991 | 6 / 6 |
| sha1-work | 0.9861 | 0.9997 | 6 / 6 |
| base64-work | 0.9904 | 1.0001 | 6 / 6 |
| base32-work | 1.0005 | 0.9998 | 6 / 6 |
| csv-benchmark | 0.9594 | 0.9919 | 6 / 6 |
| json-work | 0.9591 | 0.9920 | 6 / 6 |
| msgpack-benchmark | 0.9754 | 0.9994 | 6 / 6 |
| lcs-benchmark | 0.9614 | 0.9991 | 6 / 6 |
| tuple-arrays-benchmark | 0.9515 | 0.9912 | 6 / 6 |
| struct-work | 0.9821 | 1.0000 | 6 / 6 |
| matrix-work | 0.9860 | 0.9995 | 6 / 6 |
| matrix-simd-work | 0.9637 | 0.9990 | 6 / 6 |
| gc-work | 0.9759 | 1.0001 | 6 / 6 |
| float-pressure-work | 0.9237 | 0.9787 | 6 / 6 |
| ffi-pressure-work | 0.8787 | 0.9799 | 6 / 6 |
| branch-pressure-work | 0.7749 | 0.9117 | 6 / 6 |
| integer-pressure-work | 0.9328 | 1.0000 | 6 / 6 |
| simd-pressure-work | 0.9744 | 0.9921 | 6 / 6 |
| gc-pressure-work | 1.0006 | 1.0002 | 6 / 6 |

| Kernel / index | Code bytes before → after | Spills before → after | Reloads before → after | Copies before → after |
|---|---:|---:|---:|---:|
| float-pressure|0 | 832 → 832 | 11 → 11 | 11 → 11 | 0 → 0 |
| ffi-pressure|1 | 1232 → 1056 | 34 → 34 | 77 → 33 | 0 → 0 |
| branch-pressure|2 | 1472 → 1376 | 55 → 36 | 46 → 36 | 11 → 15 |
| integer-pressure|3 | 560 → 560 | 24 → 24 | 24 → 24 | 0 → 0 |
| simd-pressure|4 | 1136 → 1136 | 11 → 11 | 11 → 11 | 0 → 0 |
| gc-pressure|5 | 8960 → 8960 | 140 → 140 | 140 → 140 | 0 → 0 |
| spectral-norm|6 | 3504 → 3392 | 43 → 23 | 23 → 23 | 92 → 92 |
| nbody|7 | 3312 → 3312 | 0 → 0 | 0 → 0 | 52 → 52 |
| nbody|8 | 4416 → 4352 | 47 → 36 | 18 → 18 | 58 → 58 |
| fannkuch|9 | 3664 → 3664 | 3 → 2 | 2 → 2 | 38 → 38 |
| binary-trees|10 | 9408 → 9344 | 25 → 13 | 13 → 13 | 92 → 92 |
| struct-arrays-bench|11 | 1696 → 1680 | 13 → 10 | 14 → 14 | 15 → 15 |
