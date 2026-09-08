# Allocator measurement worktree

Branch: `compiler-allocator`, based on `57f9c97a4f`.

- `d22a41706a`: independently verify completed allocations, including lifetime holes, physical register classes and use coverage. Runs under the existing `check-allocation?` switch.
- `effb512aa1`: record production pass costs, instruction/block counts, spills, reloads, copies, spill/frame bytes and generated code bytes.

Allocation policy is unchanged by the shared interface. These measurements establish a baseline for alternative policies being developed in separate worktrees.

- `e44a74f58d`: selectable allocators at the SSA CFG boundary, with linear scan as default; `compare-allocators` builds fresh CFGs for every choice.
- `52411397fa`: per-procedure allocator diagnostics in measurement reports.
- `2dd941fc8d`: verify that interval splitting preserves mandatory register operands, in addition to checking legal registers and interference.

Selection, measurement and diagnostics tests pass. Help lint passed for the selection API. The 13-word corpus retains identical emitted byte counts and final instruction/spill/frame statistics after selector integration (`selection-baseline.jsonl` versus `matching-vm-baseline.jsonl`). The integrated full compiler suite passes under linear scan, greedy, backtracking and final chordal (`integrated-*-compiler-tests.log`). Greedy exposed nine ABI regression failures; its fix passes the focused FFI suite and full compiler suite. An earlier selector-only run during source integration had two failures not reproduced by focused tests or the final integrated linear-scan suite; `selection-compiler-tests.log` is retained but superseded by the final integrated run.

## Validation

The full compiler suite passed with `check-allocation? on`; metrics tests and help lint passed. After rebuilding the native VM from this worktree, the full compiler suite (including the loaded metrics tests) passed again; see `rebuilt-vm-compiler-tests.log`. Logs are alongside this report.

## Native ARM64 baseline

One sample per word, taken with the production allocator and the VM rebuilt in this worktree. Static counts sum all generated procedures. Timing is exploratory, not a controlled performance claim.

| Input | Spills | Reloads | Copies | Spill bytes | Frame bytes | Code bytes |
|---|---:|---:|---:|---:|---:|---:|
| mismatch | 0 | 0 | 3 | 0 | 16 | 1024 |
| rehash | 0 | 0 | 3 | 0 | 16 | 1952 |
| post-order | 1 | 1 | 0 | 8 | 48 | 1584 |
| compute-def-use | 0 | 0 | 0 | 0 | 32 | 2160 |
| build-stack-frame | 0 | 0 | 0 | 0 | 16 | 176 |
| linear-scan | 0 | 0 | 0 | 0 | 16 | 80 |
| propagate | 0 | 0 | 0 | 0 | 16 | 656 |
| build-tree | 0 | 0 | 0 | 0 | 0 | 48 |
| generate | 6 | 6 | 0 | 48 | 64 | 3120 |
| spectral-norm | 22 | 22 | 1 | 144 | 160 | 3008 |
| nbody | 0 | 0 | 6 | 0 | 16 | 3104 |
| fannkuch | 1 | 1 | 0 | 8 | 32 | 3392 |
| binary-trees-benchmark | 12 | 12 | 4 | 96 | 208 | 4080 |

`measure.factor` and `matching-vm-baseline.jsonl` preserve the harness and raw data. The compiler counter library path in the harness is specific to this machine.

## Next allocator experiments

Spectral norm (22 spills) and binary trees (12 across their procedures) are the largest spill producers in this small corpus. Use them to evaluate loop-aware spill costs and rematerializing inexpensive constants before changing allocation policy. Keep the new verifier enabled, compare execution results, and record code size, spill traffic and compile cost together.

## Completed alternatives

The integrated greedy, backtracking and SSA chordal alternatives all pass the full compiler suite. See [EXPERIMENTS.md](EXPERIMENTS.md) for final comparable corpus and pressure results, limitations, and runnable examples. Linear scan remains the default.
