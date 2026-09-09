/* Copyright (C) 2026 Factor contributors.
 * See https://factorcode.org/license.txt for BSD license. */
#include <stdarg.h>
#include <lua.h>
#include <lauxlib.h>

#if defined(_WIN32)
#define EXPORT __declspec(dllexport)
#else
#define EXPORT __attribute__((visibility("default")))
#endif

typedef int (*lua_list_reader)(lua_State *, const char *, va_list);
typedef int (*lua_error_function)(lua_State *, const char *, ...);

static int call_reader(lua_list_reader reader, lua_State *L,
                       const char *format, ...) {
    va_list args;
    va_start(args, format);
    int result = reader(L, format, args);
    va_end(args);
    return result;
}

/* The actual C compiler constructs the list, independently of Factor. */
EXPORT int factor_lua_call_list(lua_State *L, lua_list_reader reader) {
    return call_reader(reader, L, "%s/%d/%f/%c/%%", "lua", -37, 2.5, 'Z');
}

EXPORT const char *factor_lua_format_control(lua_State *L) {
    return lua_pushfstring(L, "%s/%d/%f/%c/%%", "lua", -37, 2.5, 'Z');
}

EXPORT const char *factor_lua_pointer_control(lua_State *L, void *value) {
    return lua_pushfstring(L, "%p", value);
}

/* No Factor callback is on the stack between this C function and pcall.
 * A Lua longjmp may never bypass a Factor callback's runtime cleanup. */
static int raise_from_c(lua_State *L) {
    lua_error_function *error = lua_touserdata(L, lua_upvalueindex(1));
    return (*error)(L, "failure %s/%d/%f", "lua", -37, 2.5);
}

EXPORT int factor_lua_protected_error(lua_State *L, lua_error_function error) {
    lua_error_function *slot = lua_newuserdata(L, sizeof(*slot));
    *slot = error;
    lua_pushcclosure(L, raise_from_c, 1);
    return lua_pcall(L, 0, 0, 0);
}

#ifdef FACTOR_LUA_STANDALONE
#include <assert.h>
#include <stdio.h>
#include <string.h>
static int control_reader(lua_State *L, const char *format, va_list args) {
    assert(strcmp(lua_pushvfstring(L, format, args), "lua/-37/2.5/Z/%") == 0);
    return 73;
}
int main(void) {
    lua_State *L = luaL_newstate();
    assert(L);
    assert(strcmp(factor_lua_format_control(L), "lua/-37/2.5/Z/%") == 0);
    assert(factor_lua_call_list(L, control_reader) == 73);
    assert(factor_lua_protected_error(L, luaL_error) == LUA_ERRRUN);
    assert(strcmp(lua_tostring(L, -1), "failure lua/-37/2.5") == 0);
    lua_close(L);
    puts("Lua 5.1 C controls: formatted call, native va_list, protected error passed");
    return 0;
}
#endif
