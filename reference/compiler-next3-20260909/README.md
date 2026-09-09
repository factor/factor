# Round 3 native baseline and diagnostics

Baseline source is `8780b3c0908ba06be2720c5ac0949e3c68b871e4`. Compared with the measured `ad0fc337de` source, only three validation/test files change; production compiler, VM, and workload sources are identical. `baseline-source-proof.json` records that relationship. The new isolated native root has an exact 1,591-path manifest. It reuses the retained image (SHA256 `358139bcf48356b821c3b3e4159ad5df77c56d921e9fbb99ffa2a4a9e5b608fd`) and capability-bearing native x86 VM (`5004b96bf99cc5edeecdadafe01f6ccc8697d3708dfdb04005f70e5c2a79922f`). The image's original source marker remains ad0fc; no new bootstrap or preparation is claimed.

`baseline-work-costs.json` reuses the six accepted default-off runtime samples per case from the previous 26-workload matrix, normalized by the recorded batch iteration count. These are costs per complete workload invocation, not a claim about which inner operations dominate. Different workloads perform different amounts of useful work.

`shape-diagnostic.factor` captures instruction classes and bounded IR text in each block after SSA optimization, representation selection, GC insertion, and allocation. It recomputes natural-loop metadata for the snapshot. This is an untimed diagnostic using the normal metric pipeline on 12 real source targets; it does not install or time a new full workload closure. Loop counts are static instruction sites, not execution frequencies or hardware branch traces. `analyze-shapes.py` independently verifies that all final code sizes, spill/reload/copy counts, frames, and block counts equal the retained default-off baseline.

The native diagnostic passes all 12 targets with strict SSA/allocation/final value checking in 3.668 seconds. Exact final scripts/status and compressed raw output are under `baseline-native/`; `baseline-shapes.json` contains complete per-target/per-phase opcode counts. Initial private-helper and hashtable-literal parse errors are preserved as `shape1/2`. The unlimited prettyprinter run was stopped after 142 seconds and is retained as `shape3`; bounded printing completes as `shape4`. These are diagnostic harness attempts, not performance samples or compiler failures.

Portable invocation after supplying a matching prepared workload image and VM:

```
ABS_VM -i=ABS_PREPARED_IMAGE -no-user-init -resource-path=ABS_ROOT reference/compiler-next3-20260909/shape-launch.factor
```

Selected observations after representation selection:

| Target | Static loop sites worth inspecting |
|---|---|
| Spectral norm | 12 tagged→integer, 8 integer→float, 7 memory loads, 8 immediate slot loads, 12 calls, 2 allocations |
| Scalar nbody | 16 slot loads, 32 calls, 1 tagged→integer |
| SIMD nbody | 35 memory loads, 3 displaced-alien boxes and unboxes |
| Struct arrays | 12 memory loads, 9 stores, 4 tagged→integer, 1 integer→float |

These counts do not establish that tags or boxes dominate runtime, nor that repeated loads can legally be merged. The exact CFG sites and alias/representation obligations must justify each transformation. Candidate owners receive the raw blocks for that purpose.

Timing protocol: freeze each candidate first, verify positive emitted transformation and independent outputs, then compare feature off/on in the same candidate source, image, and selected word sequence using balanced B/C/C/B runs. This isolates feature activity from additional helper definitions. Measure accepted combined/default-off infrastructure against 8780 separately if warranted. Keep existing GVN/rematerialization and allocator defaults explicit. No 16-way factorial or long timing queue has started for this round.
