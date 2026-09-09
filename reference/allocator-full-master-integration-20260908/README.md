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
