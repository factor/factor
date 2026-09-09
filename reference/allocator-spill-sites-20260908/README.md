# Spill placement evidence — September 8, 2026

Source hashes and machine metadata are in `environment.json`. The base is
integration plus frozen occupancy/index commit `40daa1f79e` (local cherry
`30b5829ad9`). The prepared native ARM64 VM/image is based on `233db947df`.
The only enabled-policy changes are in backtracking and the new spill-sites
vocabulary. Rematerialization remains disabled for these measurements.

## Checked fixture sweep

Each tuple is `(live values, hot values, hot rounds, cold rounds)`. All live
values depend on the runtime loop count. The hot body and cold exit both
contribute to the checksum. The sweep enables interval, numbering, and the
final symbolic value-flow checker before generating executable code.

| Fixture | Hot-loop spills + reloads off → on | Code bytes off → on |
|---|---:|---:|
| 40, 40, 8, 5 | 558 → 280 | 5920 → 4336 |
| 40, 8, 2, 8 | 7 → 0 | 3648 → 3472 |
| 40, 12, 4, 8 | 7 → 0 | 3840 → 3472 |
| 40, 16, 8, 5 | 183 → 95 | 3632 → 3136 |
| 24, 12, 4, 4 | 26 → 0 | 1456 → 1104 |
| 32, 24, 8, 4 | 302 → 153 | 3472 → 2752 |

`sweep.log` contains full final-IR metrics; `sweep.json` is the parsed table.
The loop instruction counts are static counts in the executed loop region,
not hardware memory-event counters. On the uniform fixture the dominant
per-iteration spill/reload traffic is nearly halved. Some cases allocate
more spill storage despite emitting fewer dynamic memory operations.

## Alternating native runtime

`runtime.py` compiles both modes in one fresh Factor process. The worker
warms both generated functions, then runs eight phases in order
`off, on, on, off, off, on, on, off`. Each phase executes 2000 calls with
1000 loop iterations per call. READY/DONE handshakes delimit process-counter
snapshots, excluding startup, compilation, and waiting between phases.
The controller refreshes foreground policy every second.

| Median metric | Off | On | Reduction |
|---|---:|---:|---:|
| Factor benchmark nanoseconds | 75,664,926 | 63,459,472 | 16.1% |
| Process CPU seconds | 0.076913 | 0.064332 | 16.4% |
| Retired instructions | 1,758,072,182.5 | 1,206,083,363 | 31.4% |
| CPU cycles | 328,091,412 | 273,947,100 | 16.5% |

Every phase reported zero background CPU delta. Raw phase data is in
`runtime.json`. These short focused phases establish a native runtime and
retired-instruction benefit; they do not establish a broad workload win.

Reproduce from this worktree with its matching VM/image:

```sh
python3 reference/allocator-spill-sites-20260908/runtime.py
```

The fixture vocabulary exposes `loop-pressure-metrics*` with effect
`( count hot-count hot-rounds cold-rounds enabled? -- word metrics )` and
runs the real backtracking allocator plus code generation. Tests for
`compiler.cfg.register-allocation.spill-sites` also execute zero-, one-, and
three-iteration cases and assert a strict spill/code-size improvement.
