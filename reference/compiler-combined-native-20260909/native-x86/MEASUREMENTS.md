# Combined feature measurements

Frozen source `6b14328972`; 28,959 selected words; two strict checked configurations, four fresh timing processes and 360 measured batches.

All four new features switch together. Linear scan stays selected; GVN, rematerialization and loop spill changes stay OFF. A single prepared image is shared by both states. Temporal order: OFF / ON / ON / OFF. Each runtime observation is a median of three batches. Aggregate ratios are geometric means of the two process-level ON/OFF ratios. Negative percentages mean less work or time. There are two independent processes per state, not 360 independent compiler experiments.

| Measurement | Retired instructions / CPU time |
|---|---:|
| Compile selected scope | +0.706% / +0.636% |
| Original 26 workloads, geometric mean | -0.004% / -0.629% |

## Every runtime case

The four constructed witnesses are listed separately from the existing workload corpus.

| Workload | Aggregate retired / CPU | Round 1 retired / CPU | Round 2 retired / CPU |
|---|---:|---:|---:|
| `allocator-runtime-comparison:norm-work` | +0.000% / -0.016% | +0.000% / -0.025% | +0.000% / -0.007% |
| `allocator-runtime-comparison:nbody-work` | +0.004% / +0.005% | +0.004% / +0.688% | +0.004% / -0.674% |
| `allocator-runtime-comparison:nbody-simd-work` | +0.002% / -3.312% | +0.002% / -5.552% | +0.002% / -1.019% |
| `allocator-runtime-comparison:trees-work` | +0.029% / -5.895% | +0.029% / -4.937% | +0.029% / -6.843% |
| `allocator-runtime-comparison:fannkuch-work` | +0.172% / -1.071% | +0.172% / -0.793% | +0.172% / -1.349% |
| `allocator-runtime-comparison:sieve-work` | -0.000% / +0.383% | -0.000% / +0.419% | -0.000% / +0.347% |
| `allocator-runtime-comparison:pi-work` | +0.002% / -0.098% | +0.002% / -0.088% | +0.002% / -0.108% |
| `allocator-runtime-comparison:md5-work` | -0.000% / -0.640% | -0.000% / -1.219% | -0.001% / -0.056% |
| `allocator-runtime-comparison:sha1-work` | +0.000% / -0.638% | +0.000% / -0.641% | +0.000% / -0.635% |
| `allocator-runtime-comparison:base64-work` | -0.000% / -0.162% | -0.000% / -0.333% | -0.000% / +0.010% |
| `allocator-runtime-comparison:base32-work` | +0.067% / -1.082% | +0.067% / -1.263% | +0.067% / -0.900% |
| `benchmark.csv:csv-benchmark` | -0.122% / -1.179% | -0.121% / -1.313% | -0.124% / -1.044% |
| `allocator-runtime-comparison:json-work` | -0.126% / -1.896% | -0.126% / -0.191% | -0.126% / -3.573% |
| `benchmark.msgpack:msgpack-benchmark` | -0.180% / +1.576% | -0.180% / +2.176% | -0.180% / +0.980% |
| `benchmark.lcs:lcs-benchmark` | -0.023% / -0.717% | -0.023% / -0.681% | -0.023% / -0.753% |
| `benchmark.tuple-arrays:tuple-arrays-benchmark` | +0.004% / -3.012% | +0.004% / -5.001% | +0.003% / -0.982% |
| `allocator-runtime-comparison:struct-work` | +0.000% / -0.285% | +0.000% / -0.219% | +0.000% / -0.351% |
| `allocator-runtime-comparison:matrix-work` | -0.004% / -0.734% | -0.004% / -0.340% | -0.004% / -1.126% |
| `allocator-runtime-comparison:matrix-simd-work` | +0.003% / -0.650% | +0.003% / -0.375% | +0.003% / -0.925% |
| `allocator-runtime-comparison:gc-work` | +0.028% / -0.099% | +0.029% / -0.210% | +0.028% / +0.012% |
| `allocator-runtime-comparison:float-pressure-work` | +0.000% / -0.408% | +0.000% / -0.429% | +0.000% / -0.387% |
| `allocator-runtime-comparison:ffi-pressure-work` | +0.000% / -0.147% | +0.000% / -0.320% | +0.000% / +0.026% |
| `allocator-runtime-comparison:branch-pressure-work` | +0.000% / +0.087% | +0.000% / +0.314% | +0.000% / -0.139% |
| `allocator-runtime-comparison:integer-pressure-work` | -0.000% / +2.115% | -0.000% / +2.566% | -0.000% / +1.666% |
| `allocator-runtime-comparison:simd-pressure-work` | +0.000% / +2.112% | +0.000% / -0.122% | +0.000% / +4.395% |
| `allocator-runtime-comparison:gc-pressure-work` | +0.054% / -0.242% | +0.054% / +2.825% | +0.054% / -3.217% |

### Constructed witnesses

| Workload | Aggregate retired / CPU | Round 1 retired / CPU | Round 2 retired / CPU |
|---|---:|---:|---:|
| `compiler-next3.witnesses:loop-work` | -28.571% / +54.089% | -28.571% / +54.308% | -28.571% / +53.870% |
| `compiler-next3-representation-workload:representation-loop-work` | -65.635% / -75.923% | -65.635% / -75.829% | -65.635% / -76.016% |
| `compiler-next3.witnesses:memory-work` | -1.111% / +0.410% | -1.111% / +3.667% | -1.111% / -2.745% |
| `benchmark.scalar-mixing:mixing-work` | -2.464% / -4.770% | -2.464% / -4.730% | -2.464% / -4.811% |

## Compiler and corpus by round

| Round | Compiler retired / CPU | Corpus retired / CPU |
|---|---:|---:|
| 1 | +0.664% / +0.384% | -0.003% / -0.599% |
| 2 | +0.748% / +0.888% | -0.004% / -0.658% |

## Final emitted size changes

Targets with any final static difference are listed, including equal-size changes.

| Target | Code bytes OFF → ON |
|---|---:|
| `benchmark.nbody:nbody` | 2960 → 2992 |
| `compiler-next3-representation-workload:representation-loop-values` | 2496 → 2448 |
| `:( typed memory-loop-work )` | 496 → 496 |
| `benchmark.scalar-mixing:mixing-pair` | 224 → 240 |

Both strict configurations pass SSA, allocation and final value-flow checks. All 30 workload outputs and the full selected scope match. All 16 final static reports match the checked configuration and repeat across timing processes. Full raw observations, including absolute time and counters, are retained in `results.json`.

This measures recompilation of the selected closure and workload execution, not bootstrap. CPU changes with unchanged retired instructions do not by themselves identify a compiler improvement or its cause. No default is changed by this experiment.
