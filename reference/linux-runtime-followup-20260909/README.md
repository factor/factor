# Native Linux runtime follow-up, 2026-09-09

The append, FIFO, runtime-library detection, GTK backend selection and save-dialog fixes pass on native x86-64 Linux/glibc with the C++ VM. Linux ping is new port coverage. This does not complete the [Linux AArch64 ABI qualification](../linux-abi-x64-20260908/README.md).

## Defects and controls

| Behavior | Baseline exit | C control, GCC / Clang | Candidate exit |
| --- | ---: | ---: | ---: |
| Two append streams retain both writes (`ba`), preserving `O_APPEND` when enabling nonblocking I/O | 1 (`a`) | 0 / 0 | 0 |
| Opening a FIFO reader without a writer does not block the VM | 124 (15-second timeout) | 0 / 0 | 0 |
| Appending to a FIFO accepts its expected `ESPIPE` seek result | 1 | 0 / 0 | 0 |
| Runtime-only versioned library is detected; broken dependency and missing compiler are distinguished | 1 | Native `dlopen` control passes in each compiler lane | 0 |
| GTK2 window creation uses the GTK2 OpenGL extension resolver | 1 | 0 / 0 | 0 |
| Default GTK3 image opens its file chooser using GTK3 | 1 | 0 / 0 | 0 |
| Save chooser selects SAVE and proposes a nonexistent filename | 1, component comparison | 0 / 0 | 0 |

The ordinary regressions are retained in `io.files.unix`, `ui.backend.gtk2`, and `file-picker.linux`. Independent native C controls are [unix_file_flags.c](../../vm/tests/unix_file_flags.c), [gtk_file_picker.c](../../vm/tests/gtk_file_picker.c), and [library_probe.py](../../vm/tests/library_probe.py), which preserves and compiles its tiny C fixtures. The GTK control tests both native GTK major versions. Assembly and executable hashes are preserved for the standalone controls.

The save-dialog component comparison uses the unchanged old picker source and the candidate picker source on the same corrected GTK2 runtime: the baseline GTK2 runtime independently fails window creation before a dialog action can be inspected. This is explicitly a component comparison with a prerequisite runtime correction, not a successful run of the unchanged baseline image. The separate whole-image GTK2 window comparison fails on the unchanged baseline and passes with the resolver correction. `G_DEBUG=fatal-criticals` makes the invalid native GObject state fail promptly.

[linux_ping.c](../../vm/tests/linux_ping.c) passes with GCC and Clang; the Factor ping suite passes. Baseline vocabulary loading rejects Linux because it was not advertised as supported. This is new Linux port coverage, not a historical implementation defect. The port uses IPv4 ICMP datagram sockets and the kernel's `ping_group_range` policy; this host permits the test user's group. IPv6 and denied-group behavior are not qualified here.

## Integration

- A fresh source boot and default image complete successfully. The final I/O, Unix process/FFI, input-event FFI and ping integration exits 0, with zero test failures and compiler errors.
- GTK2 and GTK3 run the CI dialog driver under Xvfb and exit 0. The original GTK2 keyboard and icon tests are preserved and pass alongside the new window regression. The no-display skip in the general integration is supplemented by these required displayed runs.
- Full compiler verification with SSA/allocation checks exits 0. The GVN FFI matrix passes with linear-scan, greedy, backtracking and chordal allocation under both GCC and Clang. These runs precede the final GTK resolver-only correction; final fresh GTK images and dialog tests cover that correction.
- The existing callback/GC, borrowed-pointer, large-return, native FP status/trap/recovery and VM-owned thread-entry checks pass. General ABI executes 27 cases per allocator. Required missing-fixture and intentionally failing C-backed assertions exit 1; they remain labeled negative controls.
- 907 installed Linux constants agree with the native header oracle, including the added `F_GETFL`.
- Linux CI keeps the normal compiler lanes and adds native runtime-library checks plus GTK2/GTK3 dialog runs. Local CI entry-point execution passes; no remote GitHub Actions result is claimed.

## Provenance and reproduction

Both isolated workspaces start at snapshot `babf26555d` (before the concurrent branch rebase). The unchanged baseline is `/home/sheeple/factor-workspaces/linux-followup-base`; the candidate is `/home/sheeple/factor-workspaces/linux-followup`. Both bootstrap images from source. The VM and static library are reused from the previously verified source build: VM production sources did not change in this batch. Source hashes, dirty patches, untracked source archives, VM/image/library hashes, compiler versions, host details, process exits and compiler assembly identify the actual tested snapshots. Concurrent changes in the main checkout are excluded from this evidence.

[final-validation.json](final-validation.json) gives exact final commands and expected exits. [manifest.json](manifest.json) identifies source and runtime hashes. [evidence.tar.gz](evidence.tar.gz) retains the logs, earlier failures, source/bootstrap runs, compiler and allocator manifests, negative controls, and historical execution scripts. [SHA256SUMS](SHA256SUMS) checks the delivered artifacts. GCC is 15.2.0, Clang is 21.1.8, and glibc is 2.43 on an AMD Ryzen 9 7950X3D.

For a matching built checkout:

```sh
python3 vm/tests/library_probe.py
CC=/usr/lib/llvm-21/bin/clang python3 vm/tests/library_probe.py
./factor -no-user-init -no-monitors -run=tools.test io.files.unix ping
G_DEBUG=fatal-criticals xvfb-run -a ./factor -no-user-init -no-monitors .github/gtk-tests.factor
# Repeat the GTK driver with a separately bootstrapped -ui-backend=gtk2 image.
python3 .github/ffi-qualify.py --cc gcc --out logs/followup-gcc --full
python3 .github/ffi-qualify.py --cc /usr/lib/llvm-21/bin/clang --out logs/followup-clang
```

Early authoring/setup failures are retained rather than recast as defects: a missing `5array` word in the first test draft, a temporary directory too deep for Unix socket paths, an initially absent copied static VM library, and initial GTK2 runs before the resolver correction. A final review also restored the pre-existing GTK2 tests after an accidental overwrite; the delivered commits retain those tests. The final runs supersede those intermediate candidates.

Remaining work includes native AArch64/glibc reduced-type and runtime qualification, macOS shared-code verification, Zig runtime qualification, and the broader ABI inventory already documented in the preceding report. This batch does not qualify musl/NixOS, non-UTF8 locale/path handling, physical input devices, hardware GPU rendering, GTK2 GL rendering, or foreign-thread callbacks. Concurrent input-device/library-finder/Zig work needs its own evidence before those exclusions change.
