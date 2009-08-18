IN: multi-methods.tests
USING: math strings sequences tools.test ;

GENERIC: legacy-test ( a -- b )

M: integer legacy-test sq ;
M: string legacy-test " hey" append ;

[ 25 ] [ 5 legacy-test ] unit-test
[ "hello hey" ] [ "hello" legacy-test ] unit-test
