# Native combined candidate before the BT profitability correction

Executed source: `eccfc0accc5c513b44701f2e59d4a9bafb7515f0`. Measurement integrity passes; promotion of its backtracking entry-transport policy is held because the isolated pair shows repeatable branch/integer regressions. This archive is preserved before the subsequent correction.

All four checked closures, eight timing runs, C ABI callback gate, moving-GC gate, and the final 1,589-path source manifest pass. The matrix contains 624 measured runtime batches (26 cases × four allocators × six samples), plus 104 checked answers and unmeasured warmups. There are two compiler observations per allocator. Rematerialization and loop spilling are on; GVN is off. Timed processes run exclusively on native x86-64 CPU 2; checks run separately.

The frozen 28,493-word sequence is identical across all twelve matrix processes. Relative to the retained c1-equivalent baseline it adds exactly `preferred-free-color`, `edge-entry-reload?`, `reify-entry-transports`, and the entry-reload counter; no baseline word disappears. Both class algebra words and the two changed greedy words are present. `summary.json` lists the exact qualified identities. Preparation/script hashes, source manifests, commands, raw logs, all samples, and completed queue log are retained.

Ratios below are relative to linear scan within this source. Lower is better. Runtime ratios use arithmetic sample means per case and an equal-case geometric mean across the 26 cases; compiler ratios divide the two-observation means.

| Allocator | Runtime CPU | Runtime instructions | Compiler CPU | Compiler instructions |
|---|---:|---:|---:|---:|
| Linear scan | 1.0000 | 1.0000 | 1.0000 | 1.0000 |
| Greedy | 1.0343 | 1.0015 | 1.0339 | 1.0266 |
| Backtracking | 1.0132 | 1.0198 | 1.0131 | 1.0113 |
| Chordal | 1.0297 | 1.0718 | 1.2628 | 1.2880 |

Linear scan has the lowest aggregate measured runtime CPU and instruction count. This is an eight-run same-source ranking, not a new sixteen-run baseline/candidate matrix. Individual change attribution is recorded in the sibling isolated-pair directories.

Per-round runtime CPU ratios are greedy 1.0259/1.0424, backtracking 1.0142/1.0121, and chordal 1.0309/1.0286. Greedy/chordal retired-work ratios closely repeat. Backtracking's base32 retired ratio changes from 1.02253 to 1.05673, accounting for most of its aggregate per-round instruction difference (1.01918/1.02048). Every sample is retained; no outlier was excluded. These observations alone do not identify a thermal, frequency, or core-placement cause.

The twelve kernel reports preserve final code sizes, spill/reload counts, allocation diagnostics, and pass timings. Copy counts describe machine-IR `##copy` instructions; equal-register copies can emit no machine move. The reports do not establish full emitted-byte equivalence.
