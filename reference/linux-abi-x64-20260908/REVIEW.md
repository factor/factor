# Commit review, 2026-09-08

The three implementation fixes retain independent C reproducers and ordinary-suite regressions. GCC and Clang again produced baseline exit 1, C-only control exit 0, and candidate exit 0 for each fix. These are native Linux x86-64/glibc results using the C++ VM.

The review removed an unused runner, trimmed fixture imports, replaced hardcoded runtime coverage with executed-case counters, rejected reused evidence directories, and made comparison setup failures retain process exits and manifests. An invalid baseline image is classified as infrastructure failure and cannot count as proof of a defect.

A fresh image was bootstrapped from snapshot `a28ecec9b9ce60b5c82a089221f4e3a8e06a7df9` plus the recorded candidate changes. VM sources were unchanged from the previously built candidate, so the identical source-built VM binary was reused. The first full compiler run exposed a harness problem: subprocess tests ignored the parent's custom image argument and tried to open an absent `factor.image`. That run is preserved as a setup failure. The runner now installs the selected image at the default path for child VMs and restores the original afterward.

| Final review check | Result |
| --- | --- |
| Fresh-image full compiler suite with SSA/allocation verification | Exit 0; 3,294 logged experiments |
| GCC and Clang GVN FFI matrix | All four allocators pass; zero test failures and compiler errors |
| General ABI coverage | 27 Factor cases per allocator; 12 C-only controls per compiler |
| Callback allocation/GC, pointer lifetime, FP status/trap/recovery, supported VM-owned thread startup | Pass |
| Valid assertion / wrong assertion / assertion injected into allocator suite / unavailable required fixture | Exits 0 / 1 / 1 / 1 |
| Missing compiler and invalid baseline controls | Exit 1; infrastructure failure recorded |
| Reused evidence directory | Exit 2 before fixture mutation |
| Original image and fixture restoration after a failed lane | Hashes unchanged |
| Temporary default image when none existed | Removed after qualification |

The fresh-image GCC integration uses the newer snapshot above. The final Clang integration uses the preserved candidate snapshot described in [README.md](README.md), and both compiler comparisons were also rerun against the newer candidate image. This keeps the exact tested snapshots explicit despite concurrent work in the shared repository. The comparison sources in the archive include the executed files; the final unsigned-callback test only differs by removal of a blank line at EOF.

[review-results.json](review-results.json) records commands, statuses, source hashes and the seven implementation/infrastructure commits. [review-evidence.tar.gz](review-evidence.tar.gz) contains the new manifests, assembly, logs, bootstrap output, controls and reviewed sources; [SHA256SUMS](SHA256SUMS) verifies both evidence archives. The original archive remains unchanged.

Linux AArch64 completion is still pending: native GCC/Clang half/BF16 execution, ARM64 runtime and image-restart checks, the broader ABI inventory, and macOS shared-code qualification. Zig signal-context stubs remain a separate port task. Cross-compilation and x64 success do not qualify those surfaces.
