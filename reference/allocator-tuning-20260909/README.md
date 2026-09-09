# Allocator regression tuning

The compiler baseline is merged source `7b6cd9519a71960a4fb0385bf6ceeaf66097d618`. Completed full-algorithm matrices under `reference/allocator-full-comparison-20260908` remain historical, immutable evidence. This experiment first captures targeted interval, assignment, and emitted-code provenance; full timing begins only after accepted fixes pass correctness gates.

Native x86 runs in a new isolated `agent1` root on CPU 2. The matching baseline VM is built from the merged source, because it includes callback/ABI changes beyond the previously measured `30a50ab0df`. Its original compatible x86 image seed is reused; the complete compiler is refreshed with `refresh-all` before saving a new frozen image. Baseline and candidate must use identical VM/initial seed hashes within each architecture. Parent owns the ARM CPU lane and its matched assets.

Preparation uses the existing guarded driver with this experiment's script:

```
python3 reference/allocator-speed-crossarch-20260908/prepare.py --label tuning-baseline-prepare --script reference/allocator-tuning-20260909/prepare.factor
```

The driver records both compiler source and preparation-script hashes. The existing frozen-closure, source, option, native counter, and macOS priority guards remain required. New helpers must join the full frozen compiler/workload closure under the selected allocator; wrapper-only recompilation is insufficient.

Targeted diagnostics must distinguish final machine-IR opcode counts from actual emission. A same-register `##copy` can emit no instruction. Preserve vreg/ranges/uses and reload/spill boundary metadata before allocation, assigned fragments after allocation, final typed memory operations, generated code bytes, and disassembly or emitter events sufficient to identify actual movements. Execute independent expected answers and strict SSA, interval, and final value-flow checks before accepting a performance change.

The later paired comparison will retain all 26 workloads, matched rematerialization/loop-spill/GVN options, reversed source order across rounds, six timed runtime samples per workload/source/allocator, and two whole-closure compiler observations. Record CPU, retired instructions, wall time, code size, host load and per-round execution rate. Keep default-policy/bootstrap assessment separate from allocator options used for the matrix.
