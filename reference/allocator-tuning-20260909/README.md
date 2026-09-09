# Allocator regression tuning

The compiler baseline is merged source `7b6cd9519a71960a4fb0385bf6ceeaf66097d618`. Completed full-algorithm matrices under `reference/allocator-full-comparison-20260908` remain historical, immutable evidence. This experiment first captures targeted interval, assignment, and emitted-code provenance; full timing begins only after accepted fixes pass correctness gates.

Native x86 runs in a new isolated `agent1` root on CPU 2. The matching baseline VM is built from the merged source, because it includes callback/ABI changes beyond the previously measured `30a50ab0df`. Its original compatible x86 image seed is reused; the complete compiler is refreshed with `refresh-all` before saving a new frozen image. Baseline and candidate must use identical VM/initial seed hashes within each architecture. Parent owns the ARM CPU lane and its matched assets.

Preparation uses the existing guarded driver with this experiment's script:

```
python3 reference/allocator-speed-crossarch-20260908/prepare.py --label tuning-baseline-prepare --script reference/allocator-tuning-20260909/prepare.factor
```

The driver records both compiler source and preparation-script hashes. The existing frozen-closure, source, option, native counter, and macOS priority guards remain required. New helpers must join the full frozen compiler/workload closure under the selected allocator; wrapper-only recompilation is insufficient.

Targeted diagnostics must distinguish final machine-IR opcode counts from actual emission. A same-register `##copy` can emit no instruction. Preserve vreg/ranges/uses and reload/spill boundary metadata before allocation, assigned fragments after allocation, final typed memory operations, generated code bytes, and disassembly or emitter events sufficient to identify actual movements. Execute independent expected answers and strict SSA, interval, and final value-flow checks before accepting a performance change.

The paired comparison freezes candidate `5c848c90f63cea092191b70e1678bec4441e0238`. It retains all 26 workloads, rematerialization and loop spilling on, GVN off, reversed source order across rounds, six timed runtime samples per workload/source/allocator, and two whole-closure compiler observations. CPU, retired instructions, wall time, code size, host load and per-round execution rate are retained. Default-policy/bootstrap assessment stays separate from the options used for this matrix. The previous rematerialization-off attribution remains historical; this tuning changes neither rematerialization nor defaults, so it is not repeated.

`collect.py` requires exactly 16 main timing processes and eight checked closures per host: 1,248 measured runtime batches plus 208 checked workload outputs. It rejects missing samples, changed answers, inactive options, changed frozen word order and failed counters. `test_collect.py` exercises these rejection paths and canonical input-label mapping. `diagnostics.py` requires the same counts and preserves per-round execution-rate context. Existing analysis and ranking tools in the crossarch/full-comparison folders produce own-baseline deltas and final same-source allocator/linear-scan comparisons.

Both source revisions passed all four checked closures and the explicit gates in `gates/`: 40 real C ABI assertions and 384 moving-GC fresh object pairs per revision per architecture, with rematerialization off and on and the strict final verifier active. Preparation status files prove identical initial image hashes within each architecture. ARM asset hashes are in `gates/arm-assets.json`; native VM/seed hashes are in `native-greedy-provenance/native-staging.json`, and the candidate changes no VM source.

The timing `drive.py` reapplies the macOS background override every second and retains the existing Mach-thread counter priority guards. A child-exit race in the original wrapper caused one completed ARM greedy process to lack an accepted status. Its log and original/revised wrapper hashes are retained in `arm-driver-exit-race/`. The same slot was rerun regardless of measured values; both already accepted linear-scan runs were retained and source order preserved. The narrow repair tolerates a failed priority syscall only when the child has exited. Native timing used the archived original driver throughout (the changed branch is macOS-only); ARM uses that original for its first two accepted runs and the repaired driver thereafter. `resume.py` validates every retained prefix run before continuing the exact 16-command plan.
