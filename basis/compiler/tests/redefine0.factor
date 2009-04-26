IN: compiler.tests.redefine0
USING: tools.test eval compiler compiler.errors compiler.units definitions kernel math
namespaces macros assocs ;

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

[ ] [ "IN: compiler.tests.redefine0 USING: macros math kernel ; GENERIC: test-7 ( x y -- z ) : test-8 ( a b -- c ) 255 bitand test-7 ;" eval( -- ) ] unit-test

[ 4 ] [ 1 3 test-7 ] unit-test
[ 4 ] [ 1 259 test-8 ] unit-test

[ ] [
    [
        \ test-7 forget
        \ test-8 forget
    ] with-compilation-unit
] unit-test

! Indirect dependency on an unoptimized word
: test-9 ( -- ) ;
<< SYMBOL: quot
[ test-9 ] quot set-global >>
MACRO: test-10 ( -- quot ) quot get ;
: test-11 ( -- ) test-10 ;

[ ] [ test-11 ] unit-test

[ ] [ "IN: compiler.tests.redefine0 : test-9 ( -- ) 1 ;" eval( -- ) ] unit-test

! test-11 should get recompiled now

[ test-11 ] [ not-compiled? ] must-fail-with

[ ] [ "IN: compiler.tests.redefine0 : test-9 ( -- a ) 1 ;" eval( -- ) ] unit-test

[ ] [ "IN: compiler.tests.redefine0 : test-9 ( -- ) ;" eval( -- ) ] unit-test

[ ] [ test-11 ] unit-test

quot global delete-at

[ ] [
    [
        \ test-9 forget
        \ test-10 forget
        \ test-11 forget
        \ quot forget
    ] with-compilation-unit
] unit-test
