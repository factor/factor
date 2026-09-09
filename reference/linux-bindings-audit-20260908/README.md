# Linux bindings audit — 2026-09-08

Native target: x86-64 Linux, glibc 2.43, GCC 15.2.0, kernel
7.0.0-28-generic. Source was tested in an isolated worktree based on
`f562023c48`, with this audit's changes copied in. Concurrent compiler/ABI
work in the main worktree was deliberately excluded from these runs.

This is a checked audit of the core Linux/Unix interfaces and selected desktop
bindings, **not a certification of every third-party binding available on Linux**.

## Results

| Check | Coverage | Result |
| --- | --- | --- |
| Native function prototypes | 424 declarations | No unexplained ABI mismatches |
| Native structures | 33 sizes/alignments and selected field offsets | No mismatches |
| Native constants | 906 constants/enumerators | No mismatches |
| Targeted regressions | 41 checks | Passed; no compiler errors |
| Linux integration regressions | 57 checks | Passed; no compiler errors |
| GIR-based source loading | GLib, GObject, GIO, GTK2, file-picker | Passed; no compiler errors |

The prototype check covers Unix FFI/process/time, epoll, inotify, statfs/statvfs,
utmpx, scheduler, libc, Linux serial I/O, libudev, Xlib and XInput2. The scripts
contain the exact file/type lists. It compares return/argument ABI categories,
widths, signedness, and variadic fixed-argument counts against C++ type traits
applied to installed headers. It does not call the inspected functions.

Nine intentional adapters discard C return values: `memset`, `memcpy`,
`memmove`, five libudev unref functions, and `XFree`. Their existing Factor
stack effects are preserved. The checker accepts only the return-discard
difference, not argument discrepancies. These exceptions and declarations
absent from this machine's headers are retained in `signature-results.json`.

The layout check includes sockets, name-service records, directory entries,
login records, process attributes, signal sets, time structures, filesystem
records, epoll/inotify, termios and input/force-feedback records. Reserved
storage is not treated as a portable public field: recent glibc versions
repurpose part of spawn attributes as `__cgroup` and statvfs as `f_type`.
Their enclosing size/alignment and established public fields are checked.

Integration tests cover process launching/redirection/timeouts/signals,
inotify, filesystem information, system information, `/proc`, utmpx reading,
and loading the runtime sonames. They create disposable test files/processes.
Device-setting regressions use fd -1 and require EBADF; no input device was
opened, grabbed, or reconfigured. The large-file regression uses sparse files
and verifies lengths above 4 GiB without writing gigabytes of data.

## Fixes committed

- `a864891def`: restore four missing spawn-scheduler arguments; allocate spawn
  attribute/file-action storage without copying from a null pointer.
- `98e89ffdb8`: use `off_t` for truncation, `size_t` for hostname buffers,
  unsigned group IDs, signed inotify watch descriptors, and the correct
  gettimeofday pointer type.
- `a28ecec9b9`: fix signal-set/process-attribute alignment, IPv4 sockaddr
  alignment, x86 utmpx field widths/offsets, signed large-file types, and the
  missing statfs flags slot. Preserve AArch64's native utmpx field widths.
- `c0658d83ee`: correct Linux group counts, clock IDs, path limits, priority
  IDs, and variadic ioctl/open64 declarations; retain the old socket-option
  misspelling as an alias.
- `2e4a94d755`, `80e8b56a9e`: fix byte-array bitfield decoding, inline
  multi-touch layout, property bitmasks, absolute-axis setter arguments and
  force-feedback removal; update switch constants and Linux's spawn-session
  flag. The latter commit also supplies the explicit arrays import required
  for strict source loading.
- `46d89503c4`: repair X-FUNCTION's use of the changed FFI parser, preserve
  XSetErrorHandler's full pointer return, and correct XCreateIC varargs,
  style width and pointer sentinel.
- `8421d29626`: use Linux runtime sonames for librt, libXi and libudev instead
  of depending on development-package `.so` symlinks.
- `25c4273fa2`: mark GTK's file-chooser varargs, use unsigned terminal
  dimensions, and restrict the >4 GiB regression to 64-bit `off_t` platforms.

## Reproduce

Use a matching built `factor` executable and `factor.image` in the source root.
The Factor probes refresh source relative to that executable/image; the
runtime must be compatible with the checked branch. C++17 and the glibc,
X11/XInput2 and libudev development headers are required. No packages are
installed by the scripts.

```sh
mkdir -p logs/linux-bindings/tmp
python3 reference/linux-bindings-audit-20260908/signatures.py . logs/linux-bindings/signatures
python3 reference/linux-bindings-audit-20260908/layouts.py . logs/linux-bindings/layouts
python3 reference/linux-bindings-audit-20260908/constants.py . logs/linux-bindings/constants
./factor -q -no-user-init reference/linux-bindings-audit-20260908/targeted.factor
./factor -q -no-user-init reference/linux-bindings-audit-20260908/integration.factor
./factor -q -no-user-init reference/linux-bindings-audit-20260908/gir-load.factor
```

The native probes generate their C++ source, native output and Factor probes
in the requested output directories. They exit nonzero for unexplained
mismatches. Result snapshots are committed here; detailed local run logs are
under `logs/linux-bindings/` (ignored by Git).

## Remaining coverage and findings

The subsequent [runtime follow-up](../linux-runtime-followup-20260909/README.md) fixes and natively verifies GTK backend selection and save-dialog behavior. The findings below describe the original audit snapshot.

- No native ARM64, 32-bit x86, musl, older-glibc, macOS or FreeBSD execution
  was performed in this binding audit. Platform-specific declarations were
  retained where Linux's signature differs; that is not cross-platform proof.
- GLib/GObject/GIO/GTK are generated from bundled GIR metadata and were
  source-load checked, not compared with native headers (those development
  headers are absent here). The GTK varargs fix was checked against the
  bundled Gtk-2.0 GIR and its generated fixed-argument count was asserted.
- GLX, other third-party libraries, all callback lifetimes/ownership rules,
  every pointer pointee/buffer contract, live displays and physical input or
  serial devices are not covered by the native oracle. Pointer ABI equality
  alone does not validate those contracts.
- Four obsolete libudev entry points and platform/version-specific spawn
  entry points are absent from current headers; the exact inventory is in
  the signature snapshot. Their presence in Factor is not a promise they
  can be called on a current runtime.
- The high-level input-device inspector still assumes 64 multi-touch slots,
  trims trailing zero values, and suppresses errors for some optional ioctls.
  Its event-mask getter does not expose a caller-selected type/output mask.
  These need API/design work and live-device tests beyond the low-level fixes.
- The Linux save-file dialog still selects the OPEN action in its helper.
  This is a separate UI behavior bug; only its FFI declaration was changed.

Primary evidence is the installed headers and generated native probes.
The Linux kernel's [evdev implementation](https://github.com/torvalds/linux/blob/master/drivers/input/evdev.c)
confirms that effect removal takes a scalar ID and property retrieval returns
a bitmask. The glibc [utmpx seconds change](https://sourceware.org/pipermail/glibc-cvs/2024q3/085706.html)
documents the unsigned 32-bit seconds field used by newer x86 glibc; older
glibc has the same field layout but interpreted its signedness differently.
