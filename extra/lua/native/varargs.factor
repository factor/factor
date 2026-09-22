! Explicit native integration suite; see README.md for fixture build and run.
USING: alien alien.c-types alien.libraries alien.syntax alien.varargs
arrays classes.struct compiler.test io.encodings.ascii kernel locals lua lua.tests namespaces sequences sequences.generalizations tools.test ;
IN: lua.tests

LIBRARY: lua-varargs-fixture
CALLBACK: int lua-list-reader ( lua_State* L, c-string[ascii] format, va_list args )
FUNCTION: int factor_lua_call_list ( lua_State* L, lua-list-reader reader )
FUNCTION: c-string[ascii] factor_lua_format_control ( lua_State* L )
FUNCTION: c-string[ascii] factor_lua_pointer_control ( lua_State* L, void* value )
FUNCTION: int factor_lua_protected_error ( lua_State* L, void* error )
FUNCTION: longlong factor_lua_abi_layout ( int index )

{ t } [
    lua_Integer heap-size lua_Unsigned heap-size lua_KContext heap-size
    lua_Debug heap-size
    "srclen" lua_Debug offset-of "nups" lua_Debug offset-of
    "extraargs" lua_Debug offset-of "ftransfer" lua_Debug offset-of
    "short_src" lua_Debug offset-of "i_ci" lua_Debug offset-of
    luaL_Buffer heap-size luaL_Buffer c-type-align
    "init" luaL_Buffer offset-of LUAL_BUFFERSIZE
    LUA_REGISTRYINDEX LUA_RIDX_MAINTHREAD 16 narray
    16 <iota> [ factor_lua_abi_layout ] map =
] unit-test

LIBRARY: liblua5.5
FUNCTION-ALIAS: lua-push-pointer c-string[ascii] lua_pushfstring
    ( lua_State* L, c-string[ascii] fmt, ... void* value )

SYMBOL: lua-list-results
SYMBOL: lua-escaped-list

{ "lua/-37/2.5/Z/%" } [
    [ factor_lua_format_control ] with-lua-test-state
] lua-unit-test

{ t } [
    [| state |
        state "%p" state lua-push-pointer
        state state factor_lua_pointer_control =
    ] with-lua-test-state
] lua-unit-test

! The real exported error function runs only below a pure C protected frame.
{ 2 "failure lua/-37/2.5" 1 } [
    [| state |
        state "luaL_error" "liblua5.5" address-of factor_lua_protected_error
        state -1 f lua_tolstring
        state lua_gettop
    ] with-lua-test-state
] lua-unit-test

{ 73 3 } [
    [| state |
        state [| callback-state format args |
            args va-copy lua-escaped-list set-global
            callback-state format args lua_pushvfstring
            callback-state format args va-copy lua_pushvfstring
            args c-string va-arg
            callback-state "%d/%f/%c/%%" args lua_pushvfstring
            args int va-arg
            5 narray lua-list-results set-global
            73
        ] lua-list-reader factor_lua_call_list
        state lua_gettop
    ] with-lua-test-state
] lua-unit-test
{ { "lua/-37/2.5/Z/%" "lua/-37/2.5/Z/%" "lua" "-37/2.5/Z/%" -37 } }
[ lua-list-results get ] unit-test
[ lua-escaped-list get int va-arg ] [ expired-va-list? ] must-fail-with

f lua-escaped-list set-global
f lua-list-results set-global
