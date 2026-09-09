# Native Linux full-suite validation, 2026-09-09

The corrected source passes strict `load-all` and ordinary `test-all` on native x86-64 Linux/glibc with the C++ VM. Eight focused fixes are committed through `a5c42fcfd8`.

| Stage | Result | Seconds |
| --- | --- | ---: |
| Source VM build and fresh bootstrap | Exit 0 | 129.0 (bootstrap) |
| Final strict `load-all` | 3,367 vocabularies, zero compiler errors, exit 0 | 408.9 |
| First complete `test-all` | 13 failures, zero compiler errors, exit 1 | 1011.1 |
| Final complete `test-all` | Zero failures, zero compiler errors, exit 0 | 990.4 |
| GTK3 and GTK2 CI entry points | Both exit 0 | Recorded in archive |

The final sweep logs 1,303 test-file executions across 1,298 distinct paths. Its native dialog assertions additionally execute in a child VM. The first sweep logs one extra in-process dialog fixture; moving that same fixture to a child accounts for the difference. `tools.test` deliberately generates four `fake` failure notifications while testing itself; those are not retained failures. Final failure counts come from `test-failures`, with no failure filtering.

## Corrections

- **SQLite fixture loading:** the optional qualification vocabulary threw during ordinary loading without `SQLITE_3534_LIBRARY`. Definitions now load normally; the explicit runner initializes its required fixture. An ordinary regression retains rejection when the fixture is not configured. The explicit runner refreshes fixture bindings after registration and passes from both fresh and saved images.
- **SQLite Linux qualification build:** the optional library omitted native link dependencies and allowed the system SQLite to interpose its implementation and version data. The original loader control reports system version `3.46.1`; the corrected fixture reports `3.53.4`. Both its C controls and Factor session, carray, callback, FTS5 and VFS checks pass. These are fixture-build corrections, not new SQLite ABI declaration defects.
- **curl and Lua runtime loading:** Linux now selects `libcurl.so.4` and `liblua5.1.so.0`. With identical versioned-only runtimes and permanent tests, both old declarations fail and both candidates pass. GCC and Clang [C controls](library-controls.c) pass without network transfers. Lua 5.1 was also missing from the initial environment; it was supplied privately, and the old declaration was then rerun to distinguish that setup problem from the wrong library name. No newer Lua ABI is substituted.
- **SIMD lowering test:** its expected instruction sequence omitted the mask load and AND introduced by the existing byte-index wrapping fix. The lowering and compiled SIMD semantic regressions pass with the expectation corrected. No backend behavior was changed in this batch.
- **ncurses test precondition:** native C also returns null for the old arbitrary string-parameter format on this ncurses build. The test now compiles private terminfo and expands its actual `pfkey` capability, preserving the raw capability pointer. GCC, Clang and Factor return `7:text`. This follows the native library's [documented capability checks](https://invisible-island.net/ncurses/announce-6.5.html); it is a test correction, not a discovered Factor ABI defect.
- **GTK test process:** a loaded image contains both GTK majors, which GTK3 refuses to initialize together. The ordinary suite now invokes the same native dialog assertions in a bounded child using a fresh GUI image. CI preserves that image before saving `load-all`, and selects the separately bootstrapped GTK2 image for its lane. Compiler errors and child failures remain fatal.
- **Git test identity:** temporary commits supply their own author identity and disable signing for that command. No global Git configuration is changed.
- **Signal test import:** `raise` comes from `unix.process`; the test now imports it explicitly. Both immediate and delayed handler-acknowledgement checks pass with automatic imports disabled.

## Failure propagation

The GUI driver was exercised in a separate control checkout. The valid C-backed assertions exit **0**; an intentionally wrong expected native result exits **1**; an unavailable child image exits **1**. These are labeled negative controls. The injected assertion was restored, and that control checkout is clean. The production assertions were not weakened or skipped.

The initial SQLite `load-all` failure, native link failure, interposition failures, saved-image runner correction, and first complete sweep remain in the evidence. The temporary signal-test draft that omitted the constants import is recorded separately from the final passing tests.

## Source and environment

The isolated workspace `/home/sheeple/factor-workspaces/all-20260909` starts at `5fa90c067de4a7a22c29a1a49aad1ad714934553`. It has a freshly built GCC VM, a boot image generated from source, and freshly bootstrapped runtime images. Candidate patches and all changed source hashes identify the fixes layered onto that snapshot. The final loaded image is `loaded-final.image`; `factor.image` remains the fresh GUI base. The final sweep uses its own deployment cache and rebuilds staging images there.

PostgreSQL and Redis ran on private loopback ports 64591 and 64592. Xvfb used display `:109`; GTK CI controls used separate `xvfb-run` displays. All test-owned services are stopped. Native libraries were supplied in a private directory, with development headers outside the runtime search path so linker symlinks could not hide the runtime-name defects.

This uses the ordinary suite's platform and long-test policies. Its reduced-type C fixture explicitly reports unsupported toolchain/CPU on x64; this run does not claim native AArch64 half/BF16 execution or certify every optional external binding. No new test exclusion list was introduced.

[results.json](results.json) records commands, exits, timings and counts. [manifest.json](manifest.json) identifies source, VM/image/library hashes, native toolchains and dependencies. [evidence.tar.gz](evidence.tar.gz) preserves drivers, baseline/candidate sources, native controls, logs and negative controls. [SHA256SUMS](SHA256SUMS) verifies the delivered artifacts. Runtime images and deployment caches remain in the isolated workspace rather than in Git.

Reproduce using a matching source-built checkout, private dependencies/services, and the archived stage drivers under `validation/`:

```sh
python3 validation/run-stage.py source-boot
python3 validation/run-stage.py bootstrap
python3 validation/run-stage.py load-all-final
python3 validation/run-stage.py test-all-final
```

The drivers disable user initialization, monitors and automatic imports, and make compiler errors fatal. `FACTOR_GUI_TEST_IMAGE` names the fresh image when testing a saved `load-all` image. The archived service scripts refuse occupied ports and affect only their own instances; their paths and ports record this run's exact setup.
