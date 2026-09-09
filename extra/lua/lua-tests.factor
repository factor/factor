USING: accessors alien.c-types alien.syntax alien.varargs
compiler.test compiler.units continuations io.encodings.ascii kernel
locals lua sequences stack-checker tools.test words ;
IN: lua.tests

LIBRARY: liblua5.1
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
