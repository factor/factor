# All four compiler features enabled together

Enabling all four preserves the large representation-cost witness improvement, but does not demonstrate a broad workload speedup. The x86 loop-hoisting witness regresses by about 54% CPU time in both pairs. Keep the defaults OFF pending investigation and broader useful wins. The experiment itself enables the four flags explicitly.

| Architecture | Compile retired / CPU | Original 26 retired / CPU |
|---|---:|---:|
| ARM64 | +2.741% / -1.961% | -0.013% / -4.720% |
| x86-64 | +0.706% / +0.636% | -0.004% / -0.629% |

Each entry is ON/OFF minus one; negative means less work or time. The original 26 workloads are separate from four constructed witnesses.

| Constructed witness | ARM64 retired / CPU | x86-64 retired / CPU |
|---|---:|---:|
| Loop hoisting | -16.705% / -11.336% | -28.571% / +54.089% |
| Representation costs | -67.285% / -77.559% | -65.635% / -75.923% |
| Load reuse | -2.098% / -11.246% | -1.111% / +0.410% |
| Integer SLP | -2.915% / +5.046% | -2.464% / -4.770% |

The representation example removes repeated loop boxing and remains the clear large effect on both architectures. SLP shows a modest x86 CPU improvement; its ARM CPU ratios disagree (-2.810% and +13.538%). Load reuse reduces instructions but does not show a repeatable native CPU win. The loop example executes substantially fewer instructions yet takes longer on x86 (+54.308% and +53.870% CPU). This repeats the prior individual-feature result. The cause is unresolved; these timings do not prove an alignment explanation.

The broader corpus has essentially unchanged instruction counts. ARM observes -4.720% CPU time overall, but timing changes also affect unchanged controls; compile CPU ratios vary from +7.704% to -10.759%. We do not attribute that broad timing difference to the passes. Native corpus CPU changes by -0.629%, with no corresponding broad reduction in retired work. The prior native Base32 +3.419% retired-instruction anomaly does not recur here (+0.067%); it is not established as fixed.

## Method and correctness

The four flags are loop optimization, conversion-aware representation costs, memory optimization and automatic SLP. Linear scan stays selected; GVN, rematerialization and backtracking loop spills stay OFF. Production defaults are unchanged.

Each architecture uses a single refreshed image with compiler source 6b14328972, production-equivalent to the previous measured 020b74ce5d. Both configurations compile the same frozen closure: 27,834 words on ARM64 and 28,959 on x86-64. Every process reads back all four flags. Strict all-OFF and all-ON gates pass SSA, allocation and final value-flow verification, all 30 workload outputs and 16 metric targets. Timed final static reports match their checked versions and repeat across processes. Both all-OFF baselines also match the prior individual-feature experiment.

The balanced OFF / ON / ON / OFF sequence runs three measured batches per workload per fresh process: 360 batches per architecture, 720 total, with no discarded runs. Ratios combine two process-level pairs using geometric means; runtime observations use each process's median of three batches. This is two independent processes per setting. It is not a statistical significance claim. macOS counters and native Linux user-instruction counters have different coverage; compare ratios within an architecture.

These runs measure selected-closure recompilation and workload execution. They do not measure bootstrap or establish the two-minute bootstrap target. The later unrelated macOS text changes on master-candidate were merged after measurements and do not change compiler pass definitions.

## Evidence

- [ARM64 every-case measurements](arm/MEASUREMENTS.md), [raw observations](arm/results.json), [audit](arm/README.md).
- [x86-64 every-case measurements](../compiler-combined-native-20260909/native-x86/MEASUREMENTS.md), [raw observations](../compiler-combined-native-20260909/native-x86/results.json).
- [Reproduction harness](README.md). Both archives retain source/image/VM identities, executed scripts, raw records, statuses and checksums.
