# Native x86 compiler flag gates

Production source is `ad0fc337de5ce51816f8251fa490f7aee9b74074`. All four LS configurations use one prepared image and exactly the same 28,500 selected word objects. Strict SSA, interval, and final value checks pass in each configuration, and all 26 language outputs match. The selected closure includes the GVN entry/global pass and rematerialization emitter. Backtracking loop spilling is off throughout the LS factorial matrix.

The common image was refreshed from the retained a7 image with the four source files changed through ad0fc. Source manifests cover 1,589 paths, including core/classes, compiler, CPU, alien, and VM sources. The executable retains its original `cap_perfmon` capability through a symlink. Every measured process runs on native Linux x86 CPU2 at nice0. Status files retain exact source, image, VM, launcher, driver, and timing-script hashes.

A separate disposable audit root adds only the test files and scripts listed in `audit-source.json`; it does not change the canonical benchmark image, selected scope, or production source. The native audit passes:

- Rematerialization tests under GVN off and on, including signed constants, GC-root exclusion, and clearing state after disabling the option.
- Final verifier mutation tests.
- GVN production-flag and independent language-output tests.
- All 16 allocator × GVN × rematerialization C ABI callback configurations.
- All 16 moving-GC configurations, 32 fresh generated words, and 768 native answers. This fixture runs value numbering before collector insertion and asserts actual collector/derived-root metadata.

The allocation-stage pressure witness proves rematerialization emits code:

| Allocator | Code bytes off → on | Spills/reloads off → on | Emitted recipes on |
|---|---:|---:|---:|
| LS | 736 → 512 | 28/28 → 0/0 | 28 |
| Greedy | 720 → 480 | 29/29 → 0/0 | 29 |
| Backtracking | 704 → 480 | 28/28 → 0/0 | 29 |
| Chordal | 736 → 512 | 28/28 → 0/0 | 28 |

All four reduce spill storage to zero. This constructed allocation witness bypasses GVN and establishes activity, not a runtime speedup. The separate factorial timings determine benefit on the ordinary corpus.

Raw records, compressed logs, exact executed audit sources, and statuses are under `native-x86/`. `checked-validation.json` independently enforces scope and output equality. No failed native compiler gate or discarded timing sample occurred before the timing queue began.
