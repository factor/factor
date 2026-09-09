# Variadic binding cleanup — integration results

Completed the remaining active variadic declarations identified by the binding
audit: Raylib, SQLite, Lua, curses, curl, BIO_printf, ioctl, X11 and GTK. Some
Unix/X11/GTK corrections were also present in concurrent work; integration
preserved those changes and merged the missing regression coverage.

## Native evidence

- [Raylib](raylib/README.md): six checks pass against official 6.0; two metadata
  failures before, plus a deliberately fixed-signature five-value call that
  demonstrates incorrect native output. Real C-only formatting controls pass.
- [SQLite](../arm64-varargs-bindings-20260908/sqlite/README.md): four baseline
  failures become passes; 16 checks pass in both modes, including real SQLite
  native va_list forwarding. Allocated returns and writable buffers retain
  their raw pointers. Callers must free allocating results with sqlite3_free.
- [Lua](../lua-varargs-20260908/README.md): missing APIs fail before; official
  Lua 5.1.5 passes 14 unit checks and one expected cursor-lifetime failure.
  The error-call runtime test uses a protected C-only trampoline.
- [Curses](../curses-varargs-20260908/README.md): four real formatting failures
  before; 16 checks pass on ARM64 and Rosetta using headless temporary files.
- [Unix/curl/BIO](../arm64-varargs-20260908/active-bindings/README.md): seven
  baseline failures; the incremental current-source suite passes 14 checks,
  including existing Unix ABI tests. No network transfers are performed.
- [X11/GTK](../ffi-varargs-x11-gtk-20260908/README.md): preserved current fixes,
  parser/type/arity tests, native C ABI oracles and Linux emulation evidence.
  The current merged headless metadata suite passes 15 checks.

`integration.factor` explicitly reloads and executes the merged owning-vocabulary
regressions, SQLite compiler/native driver, and Lua native fixture suite in one
macOS ARM64 process. `integration.log` and `.exit` record zero test failures and
zero compiler errors, exit 0. It uses the isolated verified VM/image from the
ARM64 varargs implementation; production runtimes/images are not replaced.

Reproduction requires the isolated Raylib and Lua libraries described in their
linked evidence, the Lua C fixture, and the existing libfactor-ffi-test library:

```sh
DYLD_LIBRARY_PATH=/tmp/factor-raylib-varargs-6.0/src:/path/to/lua/build \
  /path/to/verified/factor -i=/path/to/compatible.image \
  -resource-path=/path/to/factor -no-user-init -no-monitors \
  reference/ffi-varargs-bindings-20260908/integration.factor
```

Adjust the local Lua fixture path in the evidence harness for another checkout.
Native Linux/Windows execution is not claimed by this macOS integration run.
The separate [latest-release comparison](../library-release-comparison-20260908/README.md)
records unrelated API gaps; this cleanup does not assert every SQLite or Raylib
signature is current, nor upgrade the SQLite runtime.
