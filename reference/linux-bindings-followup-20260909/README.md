# Remaining Linux bindings fixes — 2026-09-09

These changes follow the 2026-09-08 audit. **Tests and compilation were not
run for this batch, at the user's request.** Added regressions are pending
execution; none of the earlier passing audit counts qualify this new source.

## Changes

- Input inspection derives the number of multi-touch slots from ABS_MT_SLOT,
  queries advertised MT axes, and preserves zero-valued slots. Requests that
  cannot fit the ioctl size field fail explicitly instead of truncating.
- The event-mask getter now takes `(handle type length -- bytes/f)` and owns
  a native output buffer for the ioctl's integer-valued pointer. The inspector
  reports masks for the supported event-mask categories. This replaces the
  old one-argument getter, which supplied no useful output buffer.
- Optional input queries tolerate unsupported ioctl errors but propagate bad
  descriptors, permission failures, memory faults and Factor errors. Unique
  identifiers also tolerate ENOENT, the kernel's absent-string response.
- Library discovery checks PATH for ldconfig, then conventional sbin paths;
  absence or a failing ldconfig command no longer makes the cache mandatory.
  It searches LD_LIBRARY_PATH, musl path configuration, and conventional
  library directories for runtime `.so.*` files. ELF class, byte order, machine
  and shared-object type are checked without executing library constructors.
  An unavailable linker is skipped. This is not native musl/NixOS qualification.
- Four obsolete libudev calls retain their names behind explicit capability
  checks. Missing functions raise `unavailable-udev-function`; callers can
  query `udev-function-available?`. Their historical semantics are not faked.
- Variable SIMD byte shuffles now mask indices to 0–15 before native lowering,
  matching the existing scalar and ARM64 behavior. The contract is documented;
  all 256 byte-index values have a regression pending execution under SSE caps.
- Zig Linux ARM64 signal handling now scans bounded FPSIMD extension records.
  The scanner rejects malformed/truncated records, skips unknown records,
  does no allocation or I/O, and does not follow external extension pointers.
  Clearing exception flags preserves FPCR, vector registers and unrelated FPSR
  bits. Parser unit tests are included, but native signal delivery and image
  restart remain unqualified.

The preceding GTK/OpenGL WIP was committed separately before rebasing. Its
live-dialog tests still require a UI and were not run here. The build-time
runtime-soname probe was also already committed; this batch changes runtime
library discovery, not that build probe.

## Pending validation

Run the changed Factor vocabularies' unit tests, the prior binding oracles,
the SIMD suite under SSE2 and SSSE3/SSE4 caps, and the library finder on glibc,
musl and NixOS. Run `zig test src/linux_arm64_fpsimd.zig`, then qualify the
complete Zig VM on native Linux ARM64 with signal/trap/recovery and restart
checks. Physical input devices and GUI behavior still require integration
testing. No system libraries, devices, displays, or remote Git refs were
modified by this batch.

The ARM64 record format follows the kernel's
[sigcontext UAPI](https://github.com/torvalds/linux/blob/master/arch/arm64/include/uapi/asm/sigcontext.h):
FPSIMD must reside in the fixed reserved area, and records are 16-byte aligned.
