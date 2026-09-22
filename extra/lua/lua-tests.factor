USING: accessors alien alien.c-types alien.data alien.libraries alien.syntax alien.varargs
classes.struct compiler.test compiler.units continuations destructors
io.encodings.ascii kernel libc locals lua math sequences stack-checker
strings tools.test words ;
FROM: alien.c-types => float ;
IN: lua.tests

LIBRARY: liblua5.5
FUNCTION-ALIAS: lua-push-mixed c-string[ascii] lua_pushfstring
    ( lua_State* L, c-string[ascii] fmt, ... c-string[ascii] text,
      int number, double real, int character )
FUNCTION-ALIAS: lua-push-promoted c-string[ascii] lua_pushfstring
    ( lua_State* L, c-string[ascii] fmt, ... char number, float real )
FUNCTION-ALIAS: lua-error-mixed int luaL_error
    ( lua_State* L, c-string[ascii] fmt, ... c-string[ascii] text,
      int number, double real )

: lua-unit-test ( expected quot -- ) [ compile-call ] curry unit-test ;

:: with-lua-test-state ( quot -- )
    luaL_newstate :> state
    [ state quot call ] [ state lua_close ] finally ; inline

! The marker's position distinguishes varargs even with an empty tail.
{ 2 2 2 2 } [
    \ lua_pushfstring def>> 4 swap nth
    \ luaL_error def>> 4 swap nth
    \ lua-push-mixed def>> 4 swap nth
    \ lua-error-mixed def>> 4 swap nth
] unit-test

! Lua 5.5 uses 64-bit integers and a seeded three-argument constructor.
{ 505.0 9223372036854775807 } [
    [let
        "luaL_alloc" "liblua5.5" address-of f 12345 lua_newstate :> state
        [
            state lua_version
            state luaL_checkversion
            state 9223372036854775807 lua_pushinteger
            state -1 lua_tointeger
        ] [ state lua_close ] finally
    ]
] lua-unit-test

{ 0 "Lua 5.5" 42 "λ ✓" } [
    [| state |
        state luaL_openlibs
        state "return _VERSION, 6 * 7, 'λ ✓'" luaL_dostring
        state -3 lua_tostring state -2 lua_tointeger state -1 lua_tostring
    ] with-lua-test-state
] lua-unit-test

{ 3 2 } [
    [| state |
        state "this is not Lua" luaL_dostring
        state 1 lua_pop
        state "local x = nil; return x.field" luaL_dostring
    ] with-lua-test-state
] lua-unit-test

! Byte strings must preserve NUL and invalid UTF-8 without C-string decoding.
{ B{ 65 0 255 66 } 4 } [
    [| state |
        state B{ 65 0 255 66 } 4 lua_pushlstring drop
        state -1 { size_t } [ lua_tolstring-raw ] with-out-parameters
        [ memory>byte-array ] keep
    ] with-lua-test-state
] lua-unit-test

{ 3 4294967297 3 19 } [
    [| state |
        state 4294967297 lua_pushinteger state "large" lua_setglobal
        state "large" lua_getglobal state -1 lua_tointeger
        state lua_newtable
        state 19 lua_pushinteger state -2 4294967297 lua_rawseti
        state -1 4294967297 lua_rawgeti state -1 lua_tointeger
    ] with-lua-test-state
] lua-unit-test

{ 3 1 2 2 2 } [
    [| state |
        state 1 lua_pushinteger state 2 lua_pushinteger state 3 lua_pushinteger
        state 1 lua_insert
        state 1 lua_tointeger state 2 lua_tointeger state 3 lua_tointeger
        state 2 lua_remove state lua_gettop
        state 1 lua_replace state 1 lua_tointeger
    ] with-lua-test-state
] lua-unit-test

{ 1 4 "user value" } [
    [| state |
        state 32 2 lua_newuserdatauv drop
        state "user value" lua_pushstring drop
        state -2 2 lua_setiuservalue
        state -1 2 lua_getiuservalue state -1 lua_tostring
    ] with-lua-test-state
] lua-unit-test

{ 0 1 1 17 0 1 23 0 } [
    [| state |
        state luaL_openlibs
        state lua_newthread :> co
        co "coroutine.yield(17); return 23" luaL_loadstring
        co state 0 { int } [ lua_resume ] with-out-parameters
        co -1 lua_tointeger co 1 lua_pop
        co state 0 { int } [ lua_resume ] with-out-parameters
        co -1 lua_tointeger
        co lua_resetthread
    ] with-lua-test-state
] lua-unit-test

{ 0 1 1 0 } [
    [| state |
        state "return 42" luaL_loadstring
        lua_Debug new :> debug
        state ">Snu" debug lua_getinfo
        debug what>> f = not 1 0 ?
        debug nparams>>
    ] with-lua-test-state
] lua-unit-test

! luaL_Buffer contains a pointer into its initial storage: keep it off the
! moving Factor heap, and exercise growth past the embedded buffer as well.
{ t } [
    [| state |
        [
            luaL_Buffer malloc-struct &free :> buffer
            state buffer luaL_buffinit
            5000 [ buffer CHAR: x luaL_addchar ] times
            buffer luaL_pushresult
            state -1 lua_tostring 5000 CHAR: x <string> =
        ] with-destructors
    ] with-lua-test-state
] lua-unit-test

FUNCTION-ALIAS: lua-gc-param int lua_gc
    ( lua_State* L, int what, ... int param, int value )
FUNCTION-ALIAS: lua-gc-step int lua_gc
    ( lua_State* L, int what, ... size_t bytes )
FUNCTION-ALIAS: lua-push-modern c-string lua_pushfstring
    ( lua_State* L, c-string fmt, ... lua_Integer value, ulong codepoint )

{ 0 1 t } [
    [| state |
        state LUA_GCSTOP lua_gc drop state LUA_GCISRUNNING lua_gc
        state LUA_GCRESTART lua_gc drop state LUA_GCISRUNNING lua_gc
        state LUA_GCPARAM LUA_GCPPAUSE -1 lua-gc-param 0 >
        state LUA_GCSTEP 0 lua-gc-step drop
    ] with-lua-test-state
] lua-unit-test

{ "4294967297/λ" } [
    [ "%I/%U" 4294967297 CHAR: λ lua-push-modern ] with-lua-test-state
] lua-unit-test
{ t } [
    \ lua_pushvfstring def>> 3 swap nth last va_list =
] unit-test

{ "literal %" 1 "literal %" } [
    [| state |
        state "literal %%" lua_pushfstring
        state lua_gettop
        state -1 f lua_tolstring
    ] with-lua-test-state
] lua-unit-test

{ "lua/-37/2.5/Z/%" 1 "lua/-37/2.5/Z/%" } [
    [| state |
        state "%s/%d/%f/%c/%%" "lua" -37 2.5 CHAR: Z lua-push-mixed
        state lua_gettop
        state -1 f lua_tolstring
    ] with-lua-test-state
] lua-unit-test

{ "-1/2.5" } [
    [ "%d/%f" 255 2.5 lua-push-promoted ] with-lua-test-state
] lua-unit-test

! Compile the error alias without executing its non-returning longjmp.
{ } [
    [ [ lua-error-mixed ] dup infer define-temp drop ] with-compilation-unit
] unit-test
