# Backtracking index-only compilation attribution

Baseline `7b6cd9519a71960a4fb0385bf6ceeaf66097d618` versus index-only `dda193f12ad49aedaa91a1d1c522c4622ed63de3`, native Linux x86-64 on agent1, CPU 2. Two reversed pairs compile the entire frozen 28,484-word closure under backtracking; these are two compiler observations per revision, not runtime samples. Rematerialization and loop spilling are on, GVN and timing-time checks off.

| Median | Baseline | Index | Candidate/baseline |
|---|---:|---:|---:|
| Compilation CPU seconds | 57.084141664 | 48.6237809845 | 0.851791 |
| Retired instructions | 742,264,513,491 | 584,438,121,809 | 0.787372 |

The selected closure contains the new `uncovered-vreg-ranges` helper; the obsolete `uncovered-ranges` helper drops out. `scope-difference.json` records the exact frozen-vector difference. Each revision starts from the same original image and matching newly built VM, then performs a fresh full source refresh and closure preparation. Preparation records, all source hashes, exact scripts, commands, load snapshots and raw observations are retained here. VM and initial-image provenance is shared with `../native-greedy-provenance/native-staging.json`.

Both strict checked closures pass all 26 independent workload outputs. All twelve kernel reports—including actual generated code bytes, allocation policy counters and final machine-IR metrics—match exactly after excluding compilation nanoseconds (`index-equivalence.json`). The change is an indexing implementation improvement; these observations establish reduced compiler work without a policy/code change for this corpus. They do not establish runtime speed improvement.
