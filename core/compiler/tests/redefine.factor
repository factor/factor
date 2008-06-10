IN: compiler.tests
USING: compiler tools.test math parser ;

GENERIC: method-redefine-test ( a -- b )

M: integer method-redefine-test 3 + ;

: method-redefine-test-1 ( -- b ) 3 method-redefine-test ;

[ 6 ] [ method-redefine-test-1 ] unit-test

[ ] [ "IN: compiler.tests USE: math M: fixnum method-redefine-test 4 + ;" eval ] unit-test

[ 7 ] [ method-redefine-test-1 ] unit-test
