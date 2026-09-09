# Feature measurements

Frozen source `020b74ce5d8f8fac9b5df5642afad8787da98896`; 28,959 selected words; 5 checked configurations; 10 timing processes and 900 measured batches. All language outputs, source/image/VM identities, and checked-versus-timed final code metrics match.

Each result below is ON/OFF minus one. Negative means less work or CPU time. The geometric mean combines the two process-level ratios; each process contributes the median of three runtime batches per case. Compiler measurements have two observations per setting. The original 26 workloads are separate from the four constructed witnesses.

| Feature | Compiler retired / CPU | Original 26 retired / CPU | Own witness retired / CPU |
|---|---:|---:|---:|
| LICM | -0.708% / -0.536% | -0.001% / +0.025% | -28.571% / +53.617% |
| Representation costs | +0.209% / +0.593% | +0.021% / +0.959% | -65.636% / -75.920% |
| Memory load reuse | +1.976% / +2.268% | -0.025% / +1.399% | -1.111% / +3.962% |
| Integer SLP | -0.148% / -0.304% | +0.132% / +0.226% | -2.669% / -3.132% |

The two OFF processes are shared anchors for all four comparisons. Estimates are correlated, and the settings have different temporal distance from those anchors. These are paired observations, without significance claims.

## Individual rounds

| Feature / round | Compiler retired / CPU | Original 26 retired / CPU | Own witness retired / CPU |
|---|---:|---:|---:|
| LICM / 1 | -0.708% / -0.227% | -0.001% / -0.008% | -28.571% / +54.646% |
| LICM / 2 | -0.708% / -0.843% | -0.001% / +0.059% | -28.571% / +52.596% |
| Representation costs / 1 | +0.160% / +1.222% | +0.019% / +1.834% | -65.636% / -75.766% |
| Representation costs / 2 | +0.258% / -0.032% | +0.023% / +0.091% | -65.636% / -76.074% |
| Memory load reuse / 1 | +2.130% / +2.479% | -0.024% / +0.290% | -1.111% / +5.525% |
| Memory load reuse / 2 | +1.822% / +2.059% | -0.025% / +2.521% | -1.111% / +2.422% |
| Integer SLP / 1 | -0.247% / -0.007% | +0.132% / +0.230% | -2.669% / -3.571% |
| Integer SLP / 2 | -0.050% / -0.600% | +0.132% / +0.223% | -2.669% / -2.691% |

## Final emitted size changes

Only targets with a final size or final machine-IR change are listed. Machine-IR copies are not a count of emitted moves; equal-register copies can disappear in code generation.

| Feature | Target | Bytes OFF → ON |
|---|---|---:|
| Representation costs | `benchmark.nbody:nbody` | 2960 → 2992 |
| Representation costs | `compiler-next3-representation-workload:representation-loop-values` | 2496 → 2448 |
| Memory load reuse | `:( typed memory-loop-work )` | 496 → 496 |
| Integer SLP | `benchmark.scalar-mixing:mixing-pair` | 224 → 240 |

All 16 final static reports match the corresponding strict checked configuration and repeat across both timing processes. The all-OFF first 12 reports match the retained old default-OFF baseline.

Full per-case and per-round observations, including unaffected witnesses, are retained in `results.json`. CPU changes with unchanged retired instructions require separate execution-rate or code-layout investigation; this report does not infer their cause.
