# X11 and GTK variadic binding coverage

The incremental patch is based on `d6f31d2616`. That revision already contains
the production fixes, so this patch changes tests and evidence only. Existing
X11 return-pointer tests and GTK display/GUI tests are retained. The new GTK
signature fixture runs before the display check and never opens a dialog.

Current-revision validation: `current-headless-metadata.log` runs 15 checks on
native macOS ARM64 with DISPLAY unset, including the existing no-display skip.
`current-abi.log` and `current-abi-portable.log` each pass both C ABI calls using
current source declarations. All runs exit 0; metadata validation reports zero
compiler errors. Earlier logs below document the original fail/pass proof and
are historical evidence from `5fca65798c`, not new runs against this revision.

`X-FUNCTION:` now forwards the sixth result of `(FUNCTION:)` to
`make-var-function`. It retains its declared public effect and the event-loop
wake appended after the native call. The consumer audit found no other stale
callers: the two built-in alien syntax forms already use the variadic builder;
GObject introspection calls `make-function` directly with five values.
`consumer-audit.log` records all `(FUNCTION:)` source occurrences.

`XCreateIC` has one fixed parameter, followed by the existing typed attribute
list. Its public argument count remains 12. The style field uses `ulong`, matching the C `XIMStyle` typedef, and the final key is a pointer sentinel. The
internal `create-xic` caller consequently passes `f` for that sentinel.
The [Xlib header](https://raw.githubusercontent.com/mirror/libX11/master/include/X11/Xlib.h)
and [Xlib argument reader](https://raw.githubusercontent.com/mirror/libX11/master/src/xlibi18n/ICWrap.c)
confirm the variadic boundary, style width, and pointer-width keys/values.
The installed `/usr/include/X11/Xlib.h` on agent1 was also checked
(`libx11-dev:amd64` package version `2:1.8.13-1`).

`gtk_file_chooser_dialog_new` has four fixed parameters; its first button
response and subsequent button/sentinel values are anonymous arguments. Its
public argument count remains eight. This follows both the
[GTK2 header](https://raw.githubusercontent.com/GNOME/gtk/gtk-2-24/gtk/gtkfilechooserdialog.h)
and [GTK3 header](https://raw.githubusercontent.com/GNOME/gtk/gtk-3-24/gtk/gtkfilechooserdialog.h).
The current GTK2/GTK3 backend selection and dialog behavior are unchanged.

## Historical fail-before/pass-after evidence

- `parser-before.log`: the original `X-FUNCTION:` fails its stack-effect check.
  `parser-after.log`: five parser tests plus six actual XCreateIC metadata tests
  pass, including the unchanged effect/arity and event-loop wake.
- `abi-before.log`: after fixing only the parser wrapper, the original XCreateIC
  declaration returns oracle failure 0 instead of 0x1234.
- `gtk-before.log`: the original GTK declaration returns oracle failure 0 instead
  of 0x5678.
- `abi-after.log` and `abi-portable.log`: both native macOS ARM64 calls pass with
  final declarations, in normal and disabled-extension modes. The X11 control
  includes style bits above 32 and a pointer-width null sentinel.
- `c-controls.log`: the same C callers pass independently of Factor.
- `xim-compile.log`: the updated create-xic helper compiles with zero compiler
  errors.

`oracle.c` supplies headless variadic C functions with the verified prototypes.
The native test invokes the actual XCreateIC binding. It extracts and parses the
GTK declaration directly from the production source with opaque pointer types,
so it does not load a Linux GUI backend on macOS. GTK strings are encoded exactly
as the production helper does. Anonymous pointers are never dereferenced in the
oracle, allowing the old incorrect placement to fail without dereferencing
arbitrary addresses. No GUI is opened.

The before X11 call used the former integer-zero sentinel; the final call uses
`f` for the corrected pointer parameter. The high-bit style value and the GTK
button values remain identical across the corresponding before/after calls.

## Reproduction

From this worktree, using a matching updated ARM64 VM/image (the headless metadata runner also
works on macOS because it parses the GTK signature without loading a GUI backend):

```sh
clang -O2 -shared reference/ffi-varargs-x11-gtk-20260908/oracle.c -o /tmp/ffi-varargs-x11-gtk.dylib
clang -O2 -DORACLE_MAIN reference/ffi-varargs-x11-gtk-20260908/oracle.c -o /tmp/ffi-varargs-x11-gtk-control
/tmp/ffi-varargs-x11-gtk-control
env -u DISPLAY /path/to/factor -i=/path/to/image -resource-path="$PWD" -no-user-init -no-monitors reference/ffi-varargs-x11-gtk-20260908/linux.factor
/path/to/factor -i=/path/to/image -resource-path="$PWD" -no-user-init -no-monitors reference/ffi-varargs-x11-gtk-20260908/abi.factor
/path/to/factor -i=/path/to/image -resource-path="$PWD" -no-user-init -no-monitors -disable-neon-extensions reference/ffi-varargs-x11-gtk-20260908/abi.factor
```

The evidence used `/Users/erg/factor/factor` and
`/Users/erg/factor/reference/arm64-varargs-20260908/final.image` without changing
or saving that image. Runners use explicit `run-test-file` paths because older
saved images can cache test discovery and omit newly added test files.

## Historical Linux headless checks

`headless-xlib.c` links the actual installed Xlib and calls XCreateIC with a null
input method, a complete attribute list, and a null terminator. Xlib consumes
the list and returns null without creating an input context or opening a
display. It passes on agent1's native x86_64 Linux host with DISPLAY unset:

```sh
gcc -O2 -Wall -Wextra -Werror headless-xlib.c -lX11 -o headless-xlib
env -u DISPLAY ./headless-xlib
```

The isolated Linux ARM64 QEMU image ran the original `linux.factor` against
`5fca65798c`, explicitly loading its three test files, including Linux-only GTK
metadata. All 13 checks passed with zero compiler errors and exit 0
(`x11-gtk-linux.log` and `.exit`).
This is emulated Linux parser/metadata validation, not native Linux ARM64 ABI
qualification. The remote environment remains isolated under
`agent1:/tmp/factor-varargs-entry-linux.eAGr27`; no new bootstrap was needed.
