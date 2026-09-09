# Lua 5.1 native varargs tests

`lua-tests.factor` checks declaration metadata, literal formatting, mixed typed
arguments, source promotions, and the Lua stack against the real Lua library.
`native/varargs.factor` adds ARM64 cursor forwarding tests using independently
compiled C `va_start`, repeated forwarding, partial consumption, `va-copy`, and
expiry. It also compares pointer formatting with a C caller and tests
`luaL_error` through a C-only protected call. No Factor callback is bypassed by
Lua's longjmp. The error binding and a typed alias are checked as declarations;
the real error function pointer, rather than the unsafe direct Factor call, is
executed by the protected C fixture.

Install Lua 5.1, or build an isolated official Lua 5.1.5 library. Compile
`varargs.c` with the matching Lua headers and library:

```sh
# macOS; LUA_INCLUDE and LUA_LIB identify the isolated build or installation.
cc -Wall -Wextra -Werror -dynamiclib -I "$LUA_INCLUDE" varargs.c \
  -L "$LUA_LIB" -llua5.1 -o liblua-varargs-fixture.dylib
# Linux: use -shared -fPIC and an .so output name instead.
```

Register that library as `lua-varargs-fixture` with `alien.libraries:add-library`.
Load `lua` and register the matching Lua library as `liblua5.1` if its filename
is not already on the loader's search path. Then run:

```factor
USING: tools.test ;
"lua" test
"resource:extra/lua/native/varargs.factor" run-test-file
:test-failures
```

The integration suite requires ARM64 for cursor operations and requires the
fixture; it does not skip missing-library tests. Running `lua` tests alone does
not claim native `va_list` or protected-error coverage. The C fixture can also
be built as an executable with `-DFACTOR_LUA_STANDALONE` for independent controls.
The dated reference directory contains the exact macOS build/run evidence.
