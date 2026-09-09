# Raylib variadic binding verification

The zero-tail TraceLog and TextFormat declarations now record their actual
variadic boundaries. Existing Factor arities are unchanged; documentation gives
typed aliases for calls with values. The logging callback receives native va_list.

Verified on macOS ARM64 against official Raylib 6.0, tag commit
`dbc56a87da87d973a9c5baa4e7438a9d20121d28`.

- `before.log`: two declaration metadata failures (f rather than named counts
  2 and 1). The independent typed aliases and native callback already pass;
  this is not a claim that zero-tail calls previously produced wrong output.
- `after.log`: six checks pass, zero test/compiler errors, exit 0. Includes
  real TextFormat with five mixed arguments and TraceLog invoking a Factor
  callback that reads its C-created va_list. No window or GPU is initialized.
- `fixed-tail.log`: deliberately omitting the ellipsis from the five-value
  alias returns wrong native output and exits 1. It demonstrates the calling
  convention difference independently of the metadata assertions.
- `c-control.log`: real Raylib C-only formatting/callback controls pass.
- `lint.log`: changed Raylib help entries and alien.syntax help lint pass.

Sources: [Raylib 6.0 header](https://github.com/raysan5/raylib/blob/6.0/src/raylib.h).

Reproduce after building the tagged library in an isolated directory:

```sh
make -C /tmp/factor-raylib-varargs-6.0/src -j8 PLATFORM=PLATFORM_DESKTOP RAYLIB_LIBTYPE=SHARED
DYLD_LIBRARY_PATH=/tmp/factor-raylib-varargs-6.0/src /path/to/verified/factor \
  -i=/path/to/compatible.image -resource-path=/path/to/factor \
  -no-user-init -no-monitors reference/ffi-varargs-bindings-20260908/raylib/run.factor
cc -O2 -Wall -Wextra -Werror -I/tmp/factor-raylib-varargs-6.0/src \
  reference/ffi-varargs-bindings-20260908/raylib/control.c \
  -L/tmp/factor-raylib-varargs-6.0/src -lraylib \
  -Wl,-rpath,/tmp/factor-raylib-varargs-6.0/src -o /tmp/raylib-control
/tmp/raylib-control
```

The native test driver reports unavailable Raylib explicitly when the optional
library is absent. The recorded evidence runner requires it. No library or
image binary is committed. This verifies the formatting subset, not all 600
Raylib APIs; the separate release comparison identifies unrelated stale types.
