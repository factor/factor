# Independent native evidence audit

This audit reads completed records from the parent-owned native queue. It starts no Factor process and changes no remote source, image, driver, or result. The logical baseline is `c1f7e4d34cd604bbdf22576b237406b39758896d`; its `basis`, `core`, `extra`, and `vm` trees are identical to the executed retained baseline `5c848c90f63cea092191b70e1678bec4441e0238`.

The completed isolated pairs use fresh processes pinned to native Linux x86-64 CPU 2, in baseline/candidate/candidate/baseline order. Rematerialization and loop spilling are enabled; GVN and the checked allocation paths are disabled during measurements. The checks run separately. Each compiler result is one compilation of the entire prepared word sequence; there are two compiler observations per source. Ratios below divide the mean candidate observation by the mean baseline observation.

| Isolated change | Compiler CPU ratio | Compiler instruction ratio | Scope |
|---|---:|---:|---:|
| Greedy hint scoring, `c81ec7fefc` | 0.997744 | 0.995543 | 28,489 → 28,489 |
| Named-class algebra, `b16dd3c6f7` | 0.986809 | 0.987977 | 28,489 → 28,489 |
| Chordal exact selector, `29dec39c55` | 0.969939 | 0.969359 | 28,489 → 28,490 |

Greedy's instruction reductions are 0.481% and 0.410% in the two rounds. CPU changes are +0.185% and −0.635%, so the small aggregate CPU difference is noisy. All twelve kernels' non-timing metrics, including allocation diagnostics and code sizes, agree across both sources and both rounds. All 26 ordered workload outputs agree in every recorded batch. These are machine-IR and size comparisons; they do not establish equality of all emitted bytes. In particular, an IR `##copy` count is not an emitted move count.

The algebra change reduces CPU by 1.221% and 1.417%, and instructions by 1.184% and 1.221%, respectively. Both `classes.algebra:class-and` and `classes.algebra:class-or` occur in the measured sequence at the same positions in both revisions. The compiler scope is recomputed after the candidate's explicit vocabulary reload; the two changed source words introduce no new helpers.

`audit-isolated.py` checks source/status agreement, preparation script hashes, manifest acceptance, allocator/options, CPU affinity, repeated scope identity, and required helper membership. Its raw inputs and `audit.json` outputs are retained under each case directory. `collect-isolated.py` is a local-output adaptation of the parent's collector. No raw timing sample is removed based on its result.

The original baseline and greedy source manifests cover 955 paths. `baseline-core-supplement.json` independently hashes all 565 baseline `core` files and compares them with the exact c1 Git archive; every file matches. This supplies the core algebra provenance without rewriting the old manifest. New algebra and chordal source manifests cover 1,587 paths.

`environment-audit.json` records native architecture, no detected virtualization, queue nice priority, VM hashes, resolved executable paths, and performance-counter capabilities. The corrected queue launches through Python at nice 0; algebra/chordal candidates resolve to the same capability-bearing baseline executable. Earlier algebra startup failures from inherited nice priority and a copied executable lacking `cap_perfmon` occurred before compiler measurements. They are excluded by nonzero status, not by performance, and remain in the parent archive.

Chordal's completed checked closure contains 28,490 words: precisely `compiler.cfg.register-allocation.chordal:preferred-free-color` is added and no baseline word is removed. Its complete pair reduces instructions by 3.0641% in both rounds; CPU reductions are 3.3757% and 2.6349%. The backtracking/combined gates are still running at this audit checkpoint. The queue/log snapshots are diagnostic provenance, not a declaration that the final queue has completed.

## Backtracking entry transport

The accepted `784a05ead7` pair adds exactly three selected words (28,489 → 28,492): the entry predicate, transport function, and diagnostic counter. Compile instructions fall 0.298%, CPU 0.167%. The runtime instruction geomean is 0.999656725, with per-round ratios 0.999658200 and 0.999655251. This is a very small net reduction (0.0343%), not a broad runtime improvement. CPU geomean is 0.993324.

FFI improves in both rounds: retired ratio 0.981487089/0.981487044; CPU ratio 0.841165/0.837004. Its code shrinks 2000 → 1952 bytes, stores 54 → 50, reloads 51 → 49, and blocks 8 → 6. IR copies remain 14. Branch pressure gains two reloads and two blocks, grows 1856 → 1872 bytes, and retires 0.3753% more instructions in both rounds. Integer pressure retires 1.1264% more instructions in both rounds and takes 2.584%/1.920% more CPU. Its separately measured main kernel retains its size and traffic; the executed workload includes loop/container operations beyond that kernel, and the retained reports do not identify the exact changed physical instruction. Attribution requires a separate targeted dump after the measurement queue finishes. SIMD pressure retires 0.7186% fewer instructions.

All 12 kernels' static metrics are stable between rounds. Only FFI and branch pressure change those final static totals. All 26 ordered outputs match across all batches. `native-backtracking/case-details.json` retains each case's raw samples and per-round ratios and all 12 final machine-IR reports. No recommendation to promote this runtime policy follows from the target result alone.
