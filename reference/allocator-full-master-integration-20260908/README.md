# Integration with current master-candidate

Merge `962f514580` combines master-candidate `31037918db` with the completed
allocator integration. Its register-allocation, linear-scan and liveness
source trees are identical to frozen benchmark candidate `30a50ab0df`. The
newer target/ABI and VM work already on master-candidate is preserved.

Both full compiler suites pass with SSA, interval and strengthened final
value-flow checks, GVN off and loop spilling enabled:

- Linear scan, rematerialization off: zero failures, 124.03 seconds.
- Backtracking, rematerialization on: zero failures, 133.56 seconds.

These validation durations include refreshing the original root image and
are not benchmark measurements. VM, library and input-image copies came
from the current root checkout; their hashes are in `assets.json`. The
root image was not changed. The frozen performance comparison continues
to use its separate common baseline VM and image on each architecture.

The first attempt used the older benchmark harness's partial CPU/compiler
refresh and stopped before tests because the original root image had not
loaded the newer ABI boxing definitions. The retained failure is superseded
by the root project's established `refresh-all` workflow, as used by the
committed `compiler-suite.factor`. No production change was needed for this
harness correction. Both passing runs start from the same original image.

## Fresh default bootstrap on the merged source

Source `680ab93773` bootstrapped successfully with the current root VM and boot
seed. The saved image independently verifies linear scan, GVN off,
rematerialization off, zero compiler errors and integer/float/loop/moving-GC
smoke tests. It is saved separately as `full-master-default.factor.image` in
the integration worktree. The original root image hash is unchanged.

| Measurement | Result |
| --- | ---: |
| Core bootstrap report | 2:12 |
| Whole process | 135.63 s |
| Final sampled process CPU | 134.61 s |
| Final sampled retired instructions | 1.802696 T |
| Final sampled cycles | 484.417 B |

The requested under-two-minute bootstrap budget remains **unmet**. The earlier
frozen candidate's 3:11 run used a different VM and boot seed, so this is not a
matched source-only regression comparison. No unrelated process or system power
setting was changed. The runner adjusted only its own child process's scheduling
policy and saved exact commands, source/assets and counters. All allocator
timing processes had finished before this separate bootstrap began.

The [bootstrap records](default-bootstrap/status.json),
[asset hashes](default-bootstrap/assets.json), and
[fresh-image verification](default-image-check/status.json) retain the result,
including the timing miss.
