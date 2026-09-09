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

## Dominating-store proof correction

Commit `e9b04ce995` requires an actual allocated cold defining fragment with
its real store immediately after the definition in the same block. The old
eligibility-only rule could wrongly delete an initializing store when a
non-GC clobber split placed the earlier store in a bypassed hot body.

An exact final-IR checker regression now models this counterexample:
retaining the cold C1 store passes verification; removing it makes the later
C2 reload lose its original value on the bypass path and is rejected.
Native non-GC clobber fixtures also pass both policy modes with zero, one,
and three iterations for 8, 16, and 24 live values.

`proof-equivalence.factor` compares the former and corrected finishing
rules on clones of the **same allocated interval records** for all six
original sweep fixtures. All six full-record equality assertions pass
(`proof-equivalence.log`). Thus register assignment, edge resolution, and
code generation receive identical inputs for those fixtures. The earlier
runtime evidence remains applicable to these unchanged generated programs;
no new timing result is claimed. This avoids conflating allocator tie/order
variation with the effect of the store-proof correction.

The comparison intentionally replaces the finishing word inside its owned
fresh Factor process; it does not edit the compiler source or saved image.
