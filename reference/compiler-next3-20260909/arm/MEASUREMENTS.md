# Feature measurements

Frozen source `020b74ce5d8f8fac9b5df5642afad8787da98896`; 27,834 selected words; 5 checked configurations; 10 timing processes and 900 measured batches. All language outputs, source/image/VM identities, and checked-versus-timed final code metrics match.

Each result below is ON/OFF minus one. Negative means less work or CPU time. The geometric mean combines the two process-level ratios; each process contributes the median of three runtime batches per case. Compiler measurements have two observations per setting. The original 26 workloads are separate from the four constructed witnesses.

| Feature | Compiler retired / CPU | Original 26 retired / CPU | Own witness retired / CPU |
|---|---:|---:|---:|
| LICM | +0.131% / +7.978% | +0.023% / +3.388% | -16.687% / -8.192% |
| Representation costs | +0.468% / +16.313% | +0.034% / +3.045% | -67.462% / -74.970% |
| Memory load reuse | +1.747% / +13.556% | +0.055% / +5.216% | -1.926% / -7.048% |
| Integer SLP | +0.770% / +18.003% | +0.015% / +3.733% | -2.820% / +16.965% |

The two OFF processes are shared anchors for all four comparisons. Estimates are correlated, and the settings have different temporal distance from those anchors. These are paired observations, without significance claims.

## Individual rounds

| Feature / round | Compiler retired / CPU | Original 26 retired / CPU | Own witness retired / CPU |
|---|---:|---:|---:|
| LICM / 1 | +0.231% / +13.496% | +0.021% / +7.591% | -16.706% / -8.989% |
| LICM / 2 | +0.030% / +2.727% | +0.025% / -0.650% | -16.669% / -7.389% |
| Representation costs / 1 | +0.603% / +29.340% | -0.004% / +7.746% | -67.526% / -78.618% |
| Representation costs / 2 | +0.333% / +4.598% | +0.072% / -1.451% | -67.397% / -70.698% |
| Memory load reuse / 1 | +1.844% / +27.584% | +0.072% / +8.350% | -1.750% / -12.533% |
| Memory load reuse / 2 | +1.651% / +1.071% | +0.038% / +2.173% | -2.102% / -1.218% |
| Integer SLP / 1 | +0.893% / +24.866% | +0.011% / +7.257% | -2.854% / +25.686% |
| Integer SLP / 2 | +0.647% / +11.516% | +0.019% / +0.324% | -2.785% / +8.849% |

## Final emitted size changes

Only targets with a final size or final machine-IR change are listed. Machine-IR copies are not a count of emitted moves; equal-register copies can disappear in code generation.

| Feature | Target | Bytes OFF → ON |
|---|---|---:|
| Representation costs | `benchmark.nbody:nbody` | 3120 → 3168 |
| Representation costs | `compiler-next3-representation-workload:representation-loop-values` | 1840 → 1792 |
| Memory load reuse | `:( typed memory-loop-work )` | 512 → 496 |
| Integer SLP | `benchmark.scalar-mixing:mixing-pair` | 272 → 208 |

All 16 final static reports match the corresponding strict checked configuration and repeat across both timing processes. The all-OFF first 12 reports match the retained old default-OFF baseline.

Full per-case and per-round observations, including unaffected witnesses, are retained in `results.json`. CPU changes with unchanged retired instructions require separate execution-rate or code-layout investigation; this report does not infer their cause.
