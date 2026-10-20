USING: accessors alien alien.c-types alien.libraries alien.syntax
kernel sequences tools.test words ;
IN: alien.syntax.tests

C-LIBRARY: alien-syntax-test-first {
    { object "alien-syntax-test-first-library" }
}

FUNCTION: int syntax-test-function ( )
FUNCTION-ALIAS: syntax-test-alias int syntax_test_function ( )
CALLBACK: int syntax-test-callback ( )
C-GLOBAL: int syntax_test_global

: syntax-test-address ( -- alien ) &: syntax_test_global ;

{ "alien-syntax-test-first-library" cdecl } [
    "alien-syntax-test-first" lookup-library [ path>> ] [ abi>> ] bi
] unit-test

{ "alien-syntax-test-first" } [
    \ syntax-test-function def>> second
] unit-test

{ "alien-syntax-test-first" } [
    \ syntax-test-alias def>> second
] unit-test

{ "alien-syntax-test-first" } [
    \ syntax-test-callback "callback-library" word-prop
] unit-test

{ "alien-syntax-test-first" } [
    \ syntax_test_global def>> second
] unit-test

{ "alien-syntax-test-first" } [
    \ set-syntax_test_global def>> second
] unit-test

{ "alien-syntax-test-first" } [
    \ syntax-test-address def>> second
] unit-test

C-LIBRARY: alien-syntax-test-second {
    { object "alien-syntax-test-second-library" }
}

FUNCTION: int syntax-test-second-function ( )

{ "alien-syntax-test-second" } [
    \ syntax-test-second-function def>> second
] unit-test

LIBRARY: alien-syntax-test-first

FUNCTION: int syntax-test-switched-function ( )

{ "alien-syntax-test-first" } [
    \ syntax-test-switched-function def>> second
] unit-test

"alien-syntax-test-first" remove-library
"alien-syntax-test-second" remove-library
