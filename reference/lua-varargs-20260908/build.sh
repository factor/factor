#!/bin/sh
# Reproduce the isolated macOS ARM64 Lua 5.1.5 library and C controls.
set -eu
cd "$(dirname "$0")/../.."
build="$PWD/reference/lua-varargs-20260908/build"
mkdir -p "$build"
curl -fsSL https://www.lua.org/ftp/lua-5.1.5.tar.gz -o "$build/lua-5.1.5.tar.gz"
printf '%s  %s\n' 2640fc56a795f29d28ef15e13c34a47e223960b0240e8cb0a82d9b0738695333 "$build/lua-5.1.5.tar.gz" | shasum -a 256 -c -
tar -xzf "$build/lua-5.1.5.tar.gz" -C "$build"
make -C "$build/lua-5.1.5/src" macosx -j4
cc -dynamiclib -Wl,-force_load,"$build/lua-5.1.5/src/liblua.a" \
  -o "$build/liblua5.1.dylib" -install_name "$build/liblua5.1.dylib"
cc -Wall -Wextra -Werror -dynamiclib -I "$build/lua-5.1.5/src" \
  extra/lua/native/varargs.c -L "$build" -llua5.1 \
  -o "$build/liblua-varargs-fixture.dylib"
cc -Wall -Wextra -Werror -DFACTOR_LUA_STANDALONE \
  -I "$build/lua-5.1.5/src" extra/lua/native/varargs.c \
  -L "$build" -llua5.1 -o "$build/c-controls"
"$build/c-controls"
