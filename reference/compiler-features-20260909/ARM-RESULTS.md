# ARM64 feature comparison

All four strict closures and all eight fresh timing processes completed with
exit zero. The source/image/VM/harness identities and exact 27,367-word selected
scope match throughout. All 26 language outputs match across configurations and
rounds. There are 624 measured runtime batches, with three batches per case per
process and two processes per configuration. No observation was discarded.

Linear scan is selected; loop-spill policy and compiler checks are off during
timing. GVN/rematerialization are the only varied settings. The common prepared
image contains the unchanged production source `ad0fc337de`.

## Paired changes from both-off

Negative means less work/time. Compiler columns use geometric means of the two
same-round ratios. Runtime columns use geometric means across 26 per-case median
ratios and both rounds. These are separate compilation and runtime measurements.

| Setting | Compiler retired work | Runtime retired work | Compiler CPU | Runtime CPU |
| --- | ---: | ---: | ---: | ---: |
| GVN only | +3.921% | −0.070% | −0.381% | −4.043% |
| Rematerialization only | +0.907% | −0.018% | +1.637% | +6.060% |
| Both | +4.565% | −0.074% | +1.745% | −1.462% |

CPU results are noisy and are not reliable optimization speedup estimates here.
For example, GVN's runtime CPU changes are −7.45% and −0.51% in the two rounds;
both-on changes are −4.25% and +1.40%. Broad CPU shifts also affect kernels with
almost unchanged retired work. Source-level causes for those execution-rate
changes have not been established. The complete CPU/wall-time observations,
load snapshots and per-round ratios remain in `arm-summary.json` and the raw
status/JSONL records. The near-flat runtime instruction totals do not justify
claiming these multi-percent CPU changes as compiler wins.

## Where work decreases

GVN reduces struct-array runtime retired work **1.295%**, Base64 **0.371%** and
SIMD nbody **0.116%** in this comparison. These are selected-case reductions,
not the overall speedup. Aggregate runtime work remains close to flat. The
corresponding both-on reductions are 1.228%, 0.407% and 0.105%.

The 12 static reports show a concrete ordinary-program rematerialization effect:
scalar nbody changes from 4,160 to 4,144 bytes, 36 to 33 spills and 21 to 18
reloads. GVN changes it to 4,112 bytes with the same spill/reload counts and a
smaller frame. GVN also changes struct arrays from 1,648 to 1,600 bytes, reducing
spills/reloads by one. Both-on reports equal GVN-only reports for all 12 targets.
This is static-report equality, not an assertion of raw byte identity. Other
helper words in the selected closure are outside these 12 reports.

Rematerialization alone shows no meaningful aggregate runtime gain in this
corpus. Adding it to GVN increases compilation retired work another 0.619%,
while runtime retired work changes only −0.003%. The full per-round factorial
interaction is retained in the summary; no additive benefit is assumed.

## Decision and reproduction

Keep both features opt-in. They work in the tested pipeline, but this corpus
does not show a broad runtime gain that offsets their compilation overhead.
The conservative recipe set and existing local simplification explain why
activation and synthetic-pressure wins need not become ordinary-program wins.
No new bootstrap was measured in this investigation.

`run-arm.py check` and `run-arm.py timing` retain the original commands and
preconditions. The completed raw records are compressed under `arm/`.
Recompute the summary with:

```
python3 reference/compiler-features-20260909/analyze.py reference/compiler-features-20260909/arm --output /tmp/compiler-features-arm-summary.json
```
