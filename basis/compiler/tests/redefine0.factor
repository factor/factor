IN: compiler.tests.redefine0
USING: tools.test eval compiler compiler.errors compiler.units definitions kernel math ;

! Test ripple-up behavior
: test-1 ( -- a ) 3 ;
: test-2 ( -- ) test-1 ;

[ test-2 ] [ not-compiled? ] must-fail-with

[ ] [ "IN: compiler.tests.redefine0 : test-1 ( -- ) ;" eval( -- ) ] unit-test

{ 0 0 } [ test-1 ] must-infer-as

[ ] [ test-2 ] unit-test

[ ] [
    [
        \ test-1 forget
        \ test-2 forget
    ] with-compilation-unit
] unit-test

: test-3 ( a -- ) drop ;
: test-4 ( -- ) [ 1 2 3 ] test-3 ;

[ ] [ test-4 ] unit-test

[ ] [ "IN: compiler.tests.redefine0 USE: kernel : test-3 ( a -- ) call ; inline" eval( -- ) ] unit-test

[ test-4 ] [ not-compiled? ] must-fail-with

[ ] [
    [
        \ test-3 forget
        \ test-4 forget
    ] with-compilation-unit
] unit-test

: test-5 ( a -- quot ) ;
: test-6 ( a -- b ) test-5 ;

[ 31337 ] [ 31337 test-6 ] unit-test

[ ] [ "IN: compiler.tests.redefine0 USING: macros kernel ; MACRO: test-5 ( a -- quot ) drop [ ] ;" eval( -- ) ] unit-test

[ 31337 test-6 ] [ not-compiled? ] must-fail-with

[ ] [
    [
        \ test-5 forget
        \ test-6 forget
    ] with-compilation-unit
] unit-test

GENERIC: test-7 ( a -- b )

M: integer test-7 + ;

: test-8 ( a -- b ) 255 bitand test-7 ;

[ 1 test-7 ] [ not-compiled? ] must-fail-with
[ 1 test-8 ] [ not-compiled? ] must-fail-with

[ ] [ "IN: compiler.tests.redefine0 USING: macros kernel ; GENERIC: test-7 ( x y -- z )" eval( -- ) ] unit-test

[ 4 ] [ 1 3 test-7 ] unit-test
[ 4 ] [ 1 259 test-8 ] unit-test

[ ] [
    [
        \ test-7 forget
        \ test-8 forget
    ] with-compilation-unit
] unit-test
