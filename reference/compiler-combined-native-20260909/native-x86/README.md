# Native ALL-ON versus ALL-OFF

All four new compiler features were enabled together in the ON processes, and both strict configurations produced the same 30 workload outputs. The complete balanced comparison passed: two checked closures, four fresh timing processes, and 360 measured batches. No timing process failed, retried or was discarded. [MEASUREMENTS.md](MEASUREMENTS.md) lists every case and both rounds; [results.json](results.json) retains the complete observations and static reports.

Combined ON increases selected-closure compiler retired instructions by **0.706%** and CPU time by **0.636%**. Across the original 26 workloads, retired work is essentially unchanged (**−0.0035%**), while measured CPU time decreases **0.629%**. Those corpus results are separate from the constructed witnesses:

| Witness | Retired instructions | CPU time |
|---|---:|---:|
| Loop invariant motion | −28.571% | **+54.089%** |
| Representation selection | **−65.635%** | **−75.923%** |
| Memory load reuse | −1.111% | +0.410% |
| Integer SLP | −2.464% | −4.770% |

The representation improvement and SLP improvement repeat in both rounds. The loop CPU regression also repeats (+54.308% and +53.870%) despite fewer instructions. The earlier isolated-feature study's unchanged-loop control and detached disassembly constrain interpretation but did not establish its cause; this combined run adds no new causal experiment. Memory witness CPU changes direction between rounds (+3.667% and −2.745%). The earlier isolated SLP Base32 regression of about 3.419% retired instructions does **not** recur at that magnitude here: combined Base32 is +0.067% retired and −1.082% CPU. Its previous cause remains unresolved.

## Fixed protocol and source

The frozen production source is `6b1432897261fd72aa0578afb8e621224cdf629f`, recorded in benchmark rows by the common short marker `6b14328972`. Relative to the prior `020b74ce5d` candidate, the only change under basis/core/extra/VM is `basis/compiler/cfg/slp/slp-tests.factor`; executable production is identical. All 1,603 manifest paths matched before preparation and after the completed matrix. The new remote root is `/home/erg/factor-compiler-combined-20260909`; earlier roots and datasets were preserved.

Both settings use one newly prepared image, SHA256 `27ba6690a67f33dbb0144f8940af1074f421b78a8cc070c18909cfcc12c12e59`, prepared in 2.00s from the retained image `15a12ce2c70d85f4a43adb10f5816cabf68492ae68dfbccd44b8bedb4ebe4e45`. Preparation explicitly refreshes source, loads the combined configuration and all witness definitions, asserts all four global flags OFF, and rebuilds the selected closure. No preparation import warning occurred. The old image is the input seed, not the timed image.

The 28,959 actual selected word objects, 30 dynamic runtime handles and 16 metric targets are identical in every process. The typed LICM/memory targets and mutable SLP/representation handles ensure selected implementations are invoked. OFF and ON record actual readback of all four flags; linear scan remains selected, and GVN, constant rematerialization and backtracking loop spilling remain OFF. These are experimental process settings; no production defaults or user image were changed.

Native execution uses the retained AMD Ryzen 9 7950X3D host, CPU2 (core 2, sibling 18), nice0 and the capability-bearing VM symlink. The VM SHA256 is `5004b96bf99cc5edeecdadafe01f6ccc8697d3708dfdb04005f70e5c2a79922f`, with `cap_perfmon=ep`; the counter-library SHA256 is `fb380f29e9265891875d2079707f903a8503c4c526e62d33ea579b1f53ce1fd7`. Exact commands, priority launch, load snapshots, hashes and host metadata are retained under `matrix/`. No power or clock preferences were changed.

The order is **OFF / ON / ON / OFF**. Each runtime process records a warmup and three measured batches per case. Ratios pair corresponding rounds, using the median of each process's three batches, then the geometric mean of the two ratios. There are only two independent processes and two compiler observations per state; 360 batches are not 360 independent compiler experiments. No significance claim or bootstrap timing is made. Small CPU changes with stable retired work do not by themselves identify a compiler mechanism or exclude placement/execution-rate effects.

## Acceptance and static comparisons

Strict OFF and ON checks passed in 81.1s and 83.1s, verifying SSA, allocation intervals and final value flow. Their full scope and all 30 outputs match. The final analyzer verifies every timed output, every per-case trial/iteration count, both source/image/VM identities, both complete static repeats, and all 16 checked-versus-timed final reports. Its optional old-baseline comparison also passes.

The new OFF state exactly matches the prior isolated matrix's full selected-word sequence, all 30 outputs and **all 16 final static reports**. Combined ON's static differences match the prior individual effects exactly: scalar nbody 2960→2992 bytes and representation witness 2496→2448; memory witness 103→100 final IR instructions at 496 bytes; SLP witness 224→240 bytes. Other final totals, including LICM's motion-only totals, are unchanged. Static counts are not a count of executed machine instructions or proof that code placement is unchanged.

Source equivalence and the per-target comparison are retained in `matrix/native-prior-off-equivalence.json` and `matrix/native-prior-individual-static-comparison.json`. The expanded source manifest and frozen harness hashes accompany raw logs and JSONL compressed losslessly. The shared harness is commit `1ccbc883ff`; the result renderer is from `fa9427f39d`. Collection and staging scripts are retained in the parent native reference directory.
