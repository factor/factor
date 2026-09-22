# Lua 5.5 native integration tests

Use matching Lua 5.5 headers and a library built with the default numeric
configuration. These tests compare Factor's struct layouts with the C headers,
forward native `va_list` arguments through Factor callbacks, and exercise Lua
errors entirely inside a protected C call.

From the repository root, on macOS with Apple Silicon Homebrew:

```sh
clang -std=c11 -Wall -Wextra -Werror -fPIC -dynamiclib \
  -I/opt/homebrew/include/lua extra/lua/native/varargs.c \
  -L/opt/homebrew/lib -llua5.5 -o /tmp/factor-lua55-native.dylib

DYLD_LIBRARY_PATH=/opt/homebrew/lib ./factor -no-user-init -e='
USING: alien alien.libraries kernel namespaces sequences system tools.test vocabs.loader ;
"lua" require "lua" test
"lua-varargs-fixture" "/tmp/factor-lua55-native.dylib" cdecl add-library
"resource:extra/lua/native/varargs.factor" run-test-file
:test-failures test-failures get empty? [ 0 ] [ 1 ] if exit'
```

On Linux, use `-shared` instead of `-dynamiclib`, the installed Lua 5.5 include
and library directories, and a `.so` fixture filename. Set `LD_LIBRARY_PATH`
if the Lua library is outside the default loader paths. Intel Homebrew normally
uses `/usr/local` instead of `/opt/homebrew`.

To run the independent C controls, compile the same source with
`-DFACTOR_LUA_STANDALONE` and without `-dynamiclib`/`-shared`, then run the
resulting executable. Ordinary binding tests and documentation checks are:

```sh
./factor -no-user-init -run=tools.test lua
./factor -no-user-init -run=help.lint lua
```
