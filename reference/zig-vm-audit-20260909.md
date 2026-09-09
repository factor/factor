# Zig VM audit — 2026-09-09

This audit reviewed allocation and teardown, GC roots in interpreted execution,
alien displacements, stdio and image persistence, thread registration, and the
Windows platform boundaries in `src/`. It found and fixed concrete bugs; it does
not establish that every VM path is correct or complete the Windows port.

## Fixes

- `3e111bca72`: unwind failed bitmap, heap metadata, stack segment, VM, and
  context allocations. Reject overflowing segment sizes. Release all registered
  contexts at VM teardown, including suspended contexts, without reading an
  uninitialized current-context pointer.
- `5f4702cbd2`: keep an interpreted quotation's array rooted and reload it after
  operations that may move objects. Use retain-stack roots for `dip` and `keep`.
  Apply wrapping address arithmetic to negative alien displacements.
- `b8017a614f`: clear thread-local VM registration and release/reset the empty
  thread map so subsequent registration does not reuse poisoned storage.
- `fbd965a430`: use the Windows CRT's 64-bit seek/tell functions; handle empty
  transfers and invalid seek origins; clear stdio error indicators before
  retrying interrupted transfers; close pipe descriptors on setup failure.
  Close and check an image file before renaming it into place, returning failure
  if its final flush fails.
- `7df900fdb2`: release the image loader's free-list and collector metadata
  before destroying their owning objects.
- `aabd1ce908`: supply build options to the test module and add `zig build check`
  for compiling a target without installing over the host executable.

Regression tests exercise allocation failure at each allocation point, moving GC
inside an interpreted quotation and `dip`, negative alien offsets, repeated
thread registration, image-loader teardown, segment-size overflow, and stdio
offsets beyond signed 32-bit range.

Runtime integration also exposed a Factor-side Linux library finder bug, fixed
in `0d8c785672`:
`find-in-library-directories` called `directory?` on absent search paths, which
throws on Arch systems without Debian multiarch directories. The finder now
checks existence first, with a regression for a nonexistent `LD_LIBRARY_PATH`
entry. This change is in `basis/alien/libraries/finder/linux/`.

## Validation

Use Zig **0.16.0**, the version named by `build.zig.zon`. The installed 0.17
development compiler has incompatible build APIs and was not used to qualify
these changes.

- Linux x86-64, WSL Arch: `zig build test --summary all` — **72 passed, 1 skipped**.
- Windows x86-64: `zig test src/mark_bits.zig -lc` — **6 passed**;
  `zig test src/io.zig -lc` — **2 passed**, including the 64-bit file offset test.
- Linux x86-64: `zig build -Doptimize=ReleaseFast --summary all` — succeeded.
- Linux ARM64: `zig build check -Dtarget=aarch64-linux-gnu
  -Doptimize=ReleaseFast --summary all` — succeeded; compile coverage only.
- Generated `boot.unix-x86.64.image` from the repository's Factor sources and
  bootstrapped the release Zig VM with `-include=math compiler threads io tools`.
  Bootstrap completed successfully and saved a fresh 117,293,880-byte image.
- Reloaded that image with the rebuilt release VM and ran `alien`, `compiler`,
  `io.streams.c`, and `memory` tests, including long GC tests: **zero failures**,
  process exit 0. The new missing-directory regression ran in this suite.

The runtime suite requires `cc -shared -fPIC -O2 vm/ffi_test.c
-o libfactor-ffi-test.so` in the repository root: compiler fixtures use that
absolute resource path. The first run placed this library elsewhere and failed
153 FFI tests, plus two library-finder tests for the bug described above. After
correcting the library location and refreshing `alien.libraries.finder.linux`
in the saved image, the entire suite passed.

Local validation logs and generated images are under `temp/zig-audit-*`; they
are not source artifacts. The existing Windows C++ VM executable was preserved.

## Windows gaps still present

The full native Windows `zig build test` fails with ten platform compilation
errors. Standalone Windows tests above do not imply that the complete VM builds.
The failed build and source review identify these remaining porting areas:

- `segments.zig` and image mapping still depend on POSIX memory mapping.
- `signals.zig` uses POSIX signal actions and alternate stacks; Windows exception
  handling and thread-context integration need a platform implementation.
- `c_api.zig` assumes Unix pipe descriptors and pthread signal delivery.
- `primitives/misc.zig` uses `clock_gettime` and `nanosleep`.
- `primitives/alien.zig` assumes `dlopen`/`RTLD` dynamic loading.
- `debugger.zig` assumes integer Unix terminal descriptors.
- Startup and persistence still need Windows path/string, console, and file
  replacement behavior; fixing stdio offsets does not address those interfaces.

Native ARM64, macOS, Windows exception handling, and interactive UI behavior were
not runtime-qualified by this audit. Image-save flush failure handling was
reviewed and exercised on the successful save path; disk-full/close-error fault
injection was not performed.
