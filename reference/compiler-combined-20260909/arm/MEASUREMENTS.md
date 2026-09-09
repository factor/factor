# Combined feature measurements

Frozen source `6b14328972`; 27,834 selected words; two strict checked configurations, four fresh timing processes and 360 measured batches.

All four new features switch together. Linear scan stays selected; GVN, rematerialization and loop spill changes stay OFF. A single prepared image is shared by both states. Temporal order: OFF / ON / ON / OFF. Each runtime observation is a median of three batches. Aggregate ratios are geometric means of the two process-level ON/OFF ratios. Negative percentages mean less work or time. There are two independent processes per state, not 360 independent compiler experiments.

| Measurement | Retired instructions / CPU time |
|---|---:|
| Compile selected scope | +2.741% / -1.961% |
| Original 26 workloads, geometric mean | -0.013% / -4.720% |

## Every runtime case

The four constructed witnesses are listed separately from the existing workload corpus.

| Workload | Aggregate retired / CPU | Round 1 retired / CPU | Round 2 retired / CPU |
|---|---:|---:|---:|
| `allocator-runtime-comparison:norm-work` | -0.026% / -8.452% | -0.017% / -6.331% | -0.035% / -10.525% |
| `allocator-runtime-comparison:nbody-work` | -0.035% / -6.121% | -0.054% / -1.260% | -0.016% / -10.742% |
| `allocator-runtime-comparison:nbody-simd-work` | -0.015% / -7.950% | -0.022% / -5.622% | -0.009% / -10.220% |
| `allocator-runtime-comparison:trees-work` | +0.004% / -1.359% | +0.010% / -0.099% | -0.001% / -2.604% |
| `allocator-runtime-comparison:fannkuch-work` | +0.208% / -5.646% | +0.237% / -3.016% | +0.180% / -8.205% |
| `allocator-runtime-comparison:sieve-work` | +0.013% / -5.273% | +0.020% / -4.516% | +0.006% / -6.023% |
| `allocator-runtime-comparison:pi-work` | +0.039% / -6.376% | -0.039% / -6.606% | +0.118% / -6.146% |
| `allocator-runtime-comparison:md5-work` | +0.100% / -6.899% | +0.064% / -2.909% | +0.136% / -10.725% |
| `allocator-runtime-comparison:sha1-work` | +0.038% / -2.516% | +0.005% / +0.742% | +0.071% / -5.667% |
| `allocator-runtime-comparison:base64-work` | +0.038% / -2.692% | +0.037% / -2.155% | +0.039% / -3.226% |
| `allocator-runtime-comparison:base32-work` | +0.131% / -4.486% | +0.125% / -7.081% | +0.136% / -1.819% |
| `benchmark.csv:csv-benchmark` | -0.135% / -5.320% | -0.145% / -3.182% | -0.125% / -7.410% |
| `allocator-runtime-comparison:json-work` | -0.083% / +0.198% | -0.109% / -0.088% | -0.056% / +0.484% |
| `benchmark.msgpack:msgpack-benchmark` | -0.208% / -4.265% | -0.199% / -0.952% | -0.217% / -7.466% |
| `benchmark.lcs:lcs-benchmark` | -0.021% / -4.184% | -0.007% / -0.531% | -0.034% / -7.702% |
| `benchmark.tuple-arrays:tuple-arrays-benchmark` | -0.003% / -4.458% | +0.002% / -2.455% | -0.008% / -6.420% |
| `allocator-runtime-comparison:struct-work` | +0.006% / -1.264% | +0.042% / +0.853% | -0.031% / -3.337% |
| `allocator-runtime-comparison:matrix-work` | -0.158% / -1.606% | -0.153% / -3.436% | -0.162% / +0.260% |
| `allocator-runtime-comparison:matrix-simd-work` | -0.058% / -4.524% | -0.075% / -0.849% | -0.042% / -8.063% |
| `allocator-runtime-comparison:gc-work` | -0.069% / -4.410% | -0.068% / -0.263% | -0.070% / -8.385% |
| `allocator-runtime-comparison:float-pressure-work` | -0.021% / -1.500% | +0.010% / +0.571% | -0.051% / -3.528% |
| `allocator-runtime-comparison:ffi-pressure-work` | -0.049% / -5.153% | -0.019% / -2.561% | -0.079% / -7.676% |
| `allocator-runtime-comparison:branch-pressure-work` | +0.012% / -6.202% | +0.013% / +0.245% | +0.012% / -12.235% |
| `allocator-runtime-comparison:integer-pressure-work` | -0.013% / -7.692% | -0.023% / -5.302% | -0.003% / -10.021% |
| `allocator-runtime-comparison:simd-pressure-work` | -0.045% / -10.252% | -0.012% / -9.923% | -0.077% / -10.581% |
| `allocator-runtime-comparison:gc-pressure-work` | +0.007% / -3.488% | +0.040% / -3.598% | -0.026% / -3.378% |

### Constructed witnesses

| Workload | Aggregate retired / CPU | Round 1 retired / CPU | Round 2 retired / CPU |
|---|---:|---:|---:|
| `compiler-next3.witnesses:loop-work` | -16.705% / -11.336% | -16.646% / -3.926% | -16.763% / -18.174% |
| `compiler-next3-representation-workload:representation-loop-work` | -67.285% / -77.559% | -67.286% / -76.484% | -67.283% / -78.585% |
| `compiler-next3.witnesses:memory-work` | -2.098% / -11.246% | -2.118% / -18.424% | -2.079% / -3.438% |
| `benchmark.scalar-mixing:mixing-work` | -2.915% / +5.046% | -2.892% / -2.810% | -2.938% / +13.538% |

## Compiler and corpus by round

| Round | Compiler retired / CPU | Corpus retired / CPU |
|---|---:|---:|
| 1 | +2.781% / +7.704% | -0.013% / -2.744% |
| 2 | +2.701% / -10.759% | -0.013% / -6.655% |

## Final emitted size changes

Targets with any final static difference are listed, including equal-size changes.

| Target | Code bytes OFF → ON |
|---|---:|
| `benchmark.nbody:nbody` | 3120 → 3168 |
| `compiler-next3-representation-workload:representation-loop-values` | 1840 → 1792 |
| `:( typed memory-loop-work )` | 512 → 496 |
| `benchmark.scalar-mixing:mixing-pair` | 272 → 208 |

Both strict configurations pass SSA, allocation and final value-flow checks. All 30 workload outputs and the full selected scope match. All 16 final static reports match the checked configuration and repeat across timing processes. Full raw observations, including absolute time and counters, are retained in `results.json`.

This measures recompilation of the selected closure and workload execution, not bootstrap. CPU changes with unchanged retired instructions do not by themselves identify a compiler improvement or its cause. No default is changed by this experiment.
