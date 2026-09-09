# Native x86 GVN × rematerialization results

Both features work in the exercised compiler paths. Their correctness and positive activity gates pass, but this corpus does not establish a broad runtime speedup. Defaults remain unchanged.

Production source: `ad0fc337de5ce51816f8251fa490f7aee9b74074`. The matrix uses LS, GVN/rematerialization settings `00`, `10`, `01`, `11`, and loop spilling off. The balanced order is `00,10,11,01 / 01,11,10,00`. Four checked closures and eight fresh timing processes pass: identical 28,500 selected word objects, all 26 language outputs equal, 624 measured batches, six samples per workload/configuration, and two compiler observations per configuration. No failed run or performance-based sample exclusion occurred.

Each round uses the median of three runtime samples per case. Tables combine the two paired ratios geometrically; runtime corpus figures also use an unweighted geometric mean over 26 cases. Negative percentages mean less work/time. `native-analysis.json` retains every case, round, raw observation, arithmetic compiler-ratio mean, geometric compiler-ratio mean, and factorial interaction. Hardware instructions are main-thread user-space retired instructions, excluding kernel and hypervisor. CPU time is main-thread CPU time.

| Configuration versus both off | Compiler retired | Compiler CPU | Runtime retired | Runtime CPU |
|---|---:|---:|---:|---:|
| GVN only | +4.3754% | +4.5818% | -0.0440% | +0.7566% |
| Rematerialization only | +0.5801% | +0.9855% | +0.0004% | +0.1762% |
| Both | +4.6609% | +5.0788% | +0.0873% | +0.6114% |

## Direction across both rounds

| Comparison | Round | Compiler retired | Compiler CPU | Runtime retired | Runtime CPU |
|---|---:|---:|---:|---:|---:|
| 10_vs_00 | 1 | +4.3422% | +4.3084% | -0.0439% | +0.3848% |
| 10_vs_00 | 2 | +4.4087% | +4.8559% | -0.0442% | +1.1298% |
| 01_vs_00 | 1 | +0.4570% | +0.8770% | +0.0012% | +0.5201% |
| 01_vs_00 | 2 | +0.7034% | +1.0942% | -0.0005% | -0.1664% |
| 11_vs_00 | 1 | +4.6583% | +4.8448% | +0.0872% | +0.7124% |
| 11_vs_00 | 2 | +4.6634% | +5.3133% | +0.0873% | +0.5105% |
| 11_vs_10 | 1 | +0.3029% | +0.5143% | +0.1311% | +0.3264% |
| 11_vs_10 | 2 | +0.2440% | +0.4363% | +0.1316% | -0.6124% |

## Workload attribution

| Workload | Setting vs 00 | Retired round 1 | Retired round 2 | CPU round 1 | CPU round 2 |
|---|---|---:|---:|---:|---:|
| struct-work | 10 | -0.6747% | -0.6750% | -0.0542% | +1.3352% |
| struct-work | 01 | +0.0004% | -0.0007% | +5.5876% | +0.3393% |
| struct-work | 11 | -0.6747% | -0.6749% | +0.3971% | +1.7413% |
| base64-work | 10 | -0.3235% | -0.3238% | +0.5852% | -0.3880% |
| base64-work | 01 | +0.0005% | -0.0003% | +0.0937% | -1.1591% |
| base64-work | 11 | -0.3235% | -0.3234% | +0.2725% | -0.0865% |
| nbody-work | 10 | -0.0002% | -0.0006% | +1.2304% | +0.7802% |
| nbody-work | 01 | +0.0001% | -0.0003% | -0.8179% | +1.8969% |
| nbody-work | 11 | -0.0004% | +0.0000% | +0.6581% | +0.8868% |
| nbody-simd-work | 10 | -0.1228% | -0.1232% | -0.1214% | +0.4916% |
| nbody-simd-work | 01 | +0.0002% | -0.0011% | +1.4458% | +0.2894% |
| nbody-simd-work | 11 | -0.1228% | -0.1230% | +0.2308% | +0.3780% |
| base32-work | 10 | -0.0003% | -0.0003% | +2.1889% | +0.4947% |
| base32-work | 01 | +0.0007% | +0.0004% | +0.9811% | -0.2996% |
| base32-work | 11 | +3.4190% | +3.4192% | +5.8901% | +4.6747% |

GVN consistently reduces retired instructions for struct (about 0.675%), base64 (0.324%), and SIMD nbody (0.123%). Scalar nbody is effectively flat. CPU changes on these small cases do not consistently follow the instruction changes: even paths with nearly unchanged retired work shift in CPU time. These measurements establish modest work reductions, not persuasive runtime CPU wins.

Both enabled produces a repeatable base32 increase of about 3.419% retired instructions in each round, accompanied by increased CPU time. Neither feature alone shows that retired increase. This is retained as a measured interaction, not dismissed as timing noise. The 12 static metric targets do not include base32, and this experiment does not establish whether its cause is emitted code, dispatch/runtime state, or another effect. No detached code capture or speculative cause is presented.

## Interaction

Adding rematerialization to GVN changes compiler retired work by +0.2735% and runtime corpus retired work by +0.1314%. The latter is dominated by the base32 interaction. The multiplicative factorial interaction is `11 × 00 / (10 × 01)`; a value of one would mean multiplicatively independent effects.

| Metric | Compiler interaction | Runtime interaction round 1 | Runtime interaction round 2 |
|---|---:|---:|---:|
| instructions | -0.3049% | +0.1299% | +0.1320% |
| cpu_seconds | -0.5053% | -0.1927% | -0.4467% |

## Static code and activity

Of the 12 static metric targets, nbody and struct change; the other ten do not. Counts below are final machine IR stores/reloads and generated code size. Copy counts in the complete JSON are IR copies, not necessarily emitted moves.

| Target | 00 bytes / spills / reloads | 10 | 01 | 11 |
|---|---:|---:|---:|---:|
| nbody | 4368 / 36 / 21 | 4304 / 33 / 18 | 4336 / 33 / 18 | 4304 / 33 / 18 |
| struct | 1584 / 15 / 16 | 1568 / 14 / 15 | 1584 / 15 / 16 | 1568 / 14 / 15 |

Both-on static reports equal GVN-only reports, consistent with overlapping transformations on these targets. The separate pressure witness proves actual rematerialization emission for all four allocators: LS 736→512 bytes and 28 stores/reloads→zero; greedy 720→480; backtracking 704→480; chordal 736→512. The ordinary GVN gate reports 17 pass invocations and 11 changed graphs, with independent native outputs. See `NATIVE-AUDIT.md` for all callback/GC and mutation checks.

## Reproduction and limits

`native-x86/matrix/` preserves compressed raw logs/JSONL, exact executed scripts, source/image/VM hashes, counter guards, host load snapshots, and all statuses. `native-x86/source/` contains the 1,589-path manifests; `native-x86/support-source/` contains the unchanged workload and counter sources. The machine is native x86 Linux, not Rosetta. Measured processes use CPU2 at nice0 with the original capability-bearing VM. `native-x86/audit/` is separately labeled test-only source overlays; it never replaces the timed image or canonical closure.

Reproduce analysis with:

```
python3 reference/compiler-flags-20260909/analyze.py reference/compiler-flags-20260909/native-x86/matrix --prefix native --output reference/compiler-flags-20260909/native-analysis.json
```

Two rounds provide limited CPU confidence, and these 26 workloads are not exhaustive. The positive allocation witness is not a runtime speed claim. No additional chordal timing or bootstrap is included in this factorial experiment.
