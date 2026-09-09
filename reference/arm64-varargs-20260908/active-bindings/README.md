# Active variadic binding audit and native regressions

The audit checked active FFI declarations in `basis/` and `extra/`, including
custom X-FUNCTION declarations and typed aliases. It did not treat commented
prototypes or missing library APIs as active binding defects.

## Corrected here

| Binding | Existing use | Correction |
| --- | --- | --- |
| `unix.ffi:ioctl` | macOS/Linux terminal sizing; Linux input-event requests | Mark the existing `void* argp` as anonymous after the two named parameters. |
| Four `curl.ffi:curl_easy_setopt_*` aliases | `curl-set-opt`, URL/file configuration and downloads in `extra/curl/curl.factor` | Preserve each three-input typed shape; mark the value as anonymous. |
| `openssl.libcrypto:BIO_printf` | Active declaration; no repository callers found | Preserve its two-input shape with terminal ellipsis. |

The installed macOS SDK declares `ioctl(int, unsigned long, ...)` in
`usr/include/sys/ioctl.h:97`; its FIONREAD request is defined in
`usr/include/sys/filio.h`. The SDK's `curl/easy.h:42` declares a variadic
`curl_easy_setopt`. Public primary references:

- [libcurl curl_easy_setopt](https://curl.se/libcurl/c/curl_easy_setopt.html)
- [OpenSSL BIO_printf](https://docs.openssl.org/master/man3/BIO_printf/)

## Native fail-before/pass-after

Using the integrated ARM64 VM and `final.image` on macOS:

- Before: **7 failures, 5 passing controls, exit 1** (`before.log`).
- After: **12 passing checks, zero test/compiler errors, exit 0** (`after.log`).

The seven failures were ioctl metadata and native pipe FIONREAD output;
libcurl metadata, negative `curl_off_t` option rejection, stored URL, and stored
private pointer; and BIO_printf metadata. The baseline pipe request returned
success but left the requested output count unchanged. The baseline curl calls
returned the wrong speed-option result and stored the wrong URL/pointer.

The native tests use an ordinary pipe, libcurl handle configuration/getinfo,
and an OpenSSL memory BIO. They never perform a network transfer or depend on a
terminal. BIO_printf's unchanged zero-tail call is a passing native control;
its metadata test distinguishes the corrected declaration. Existing Unix
service-database checks and the libcurl long-option error are also retained
passing controls.

Permanent tests live in the owning Unix/curl test files and
`basis/openssl/libcrypto/tests/varargs.factor`; the latter is included by the
existing libcrypto test suite. The focused runner avoids that suite's older
network-dependent tests:

```sh
/path/to/factor -i=/path/to/final.image -resource-path=/path/to/checkout \
  -no-user-init -no-monitors \
  reference/arm64-varargs-20260908/active-bindings/check.factor
```

It reloads the edited binding sources before testing, so a saved image cannot
hide stale declarations. Native Linux/Windows execution is not claimed here.

## Other audit findings assigned separately

- `basis/x11/xlib/xlib.factor:1343`: XCreateIC has a deliberate name/value tail
  after its XIM parameter but omitted ellipsis. Its caller is
  `x11.xim:create-xic`. XIMStyle width and the terminating NULL pointer also
  require attention. [Xlib reference](https://www.x.org/releases/current/doc/libX11/libX11/libX11.html)
- `basis/x11/syntax/syntax.factor`: X-FUNCTION still used the old five-value
  `make-function` adapter after `(FUNCTION:)` gained its sixth varargs value.
- `extra/file-picker/linux/linux.factor:12`: the chooser constructor has a
  deliberate button/response tail after `first_button_text`; open/save dialogs
  call it. [GTK declaration](https://docs.gtk.org/gtk3/ctor.FileChooserDialog.new.html)

Raylib, SQLite, and curses omissions were already assigned. `fcntl`, `open`, and
`openat` already declare their current typed anonymous tails correctly. Searches
for other known printf/config/logging/exec/prctl/Python variadics found no
additional active declarations requiring expansion in this bounded pass.

## Incremental integration

This patch was reapplied to `d6f31d2616` after concurrent ABI work landed.
That base already has the corrected ioctl declaration. The incremental change
preserves it and all current Unix tests, adding only the FIONREAD/metadata
regressions there. Curl/BIO changes and the original before/after evidence are
retained. The original seven-failure baseline describes the earlier source;
it is not claimed as the baseline of `d6f31d2616`.

The incremental checkout passes **14 checks**, including the existing unsigned
GID and large sparse-file tests, with zero test/compiler errors and exit 0.
See `incremental-after.log`.
