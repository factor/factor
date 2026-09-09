# Lua 5.1 variadic binding qualification — 2026-09-08

Base: `fa62cb4cb7`. Host: macOS ARM64. Runtime:
`/Users/erg/factor.worktrees/arm64-varargs-entry/factor`, image
`/Users/erg/factor/reference/arm64-varargs-20260908/final.image`.
The isolated source checkout is `arm64-varargs-lua`.

The installed LuaJIT provides a compatible 5.1 API, but these checks used the
unmodified official Lua **5.1.5** source release to match `extra/lua` exactly.
`build.sh` downloads, checks the archive digest, and builds an isolated dylib
plus the independent C fixture. No downloaded sources or binaries are committed.
The archive's SHA-256 is
`2640fc56a795f29d28ef15e13c34a47e223960b0240e8cb0a82d9b0738695333`.

Header audit: `src/lua.h` declares `lua_pushfstring(lua_State*, const char*, ...)`
and `lua_pushvfstring(lua_State*, const char*, va_list)` at lines165–167;
`src/lauxlib.h` declares `luaL_error(lua_State*, const char*, ...)` at line69.
The official manual confirms the limited format vocabulary and that
`luaL_error` never returns:

- https://www.lua.org/manual/5.1/manual.html#lua_pushfstring
- https://www.lua.org/manual/5.1/manual.html#lua_pushvfstring
- https://www.lua.org/manual/5.1/manual.html#luaL_error

## Reproduction

From the repository root:

```sh
sh reference/lua-varargs-20260908/build.sh
/path/to/factor -i=/path/to/final.image -resource-path="$PWD" \
  -no-user-init -no-monitors reference/lua-varargs-20260908/run.factor
```

The harness overrides only its process's library registrations with the
isolated official Lua and fixture dylibs. It exits nonzero on test or compiler
failure. `api-probe.factor` directly checks the three newly enabled API words.

## Evidence

- `c-controls.log`: standalone C formatting, native va_list forwarding, and
  protected error calls pass independently of Factor.
- `before.log`: original Lua source, same harness. All three availability
  assertions fail; the main and native suites fail to load because the public
  bindings are absent. This is absence-of-feature evidence, not a claim that
  native calls executed before the bindings existed.
- `after.log`: all 15 checks pass (14 unit checks and one expected lifetime
  failure), with zero compiler errors. This includes compiled real Lua calls
  for literal/%%, mixed string/int/double/char, source promotions, and pointer
  formatting; declaration metadata and compilation of a typed luaL_error alias;
  a protected C-only call of the real luaL_error address; and C-created va_list
  forwarding, copying, partial consumption, and expiry.
- `docs.log`: documentation loads successfully.

The Lua error runtime check intentionally invokes its exported function pointer
inside a pure C `lua_pcall` frame. Direct Factor invocation of this non-returning
longjmp entry point is not runtime-tested or safe from a Factor callback.
The additional native suite is explicitly invoked; `"lua" test` alone does not
claim va_list forwarding or protected-error fixture coverage. No native test is
silently skipped. This run qualifies macOS ARM64; it does not claim Linux or
Windows Lua execution.
