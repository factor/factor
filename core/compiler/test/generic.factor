IN: temporary
USING: compiler generic tools.test math kernel words arrays
sequences quotations ;

GENERIC: single-combination-test

M: object single-combination-test drop ;
M: f single-combination-test nip ;
M: array single-combination-test drop ;
M: integer single-combination-test drop ;

[ 2 3 ] [ 2 3 t single-combination-test ] unit-test
[ 2 3 ] [ 2 3 4 single-combination-test ] unit-test
[ 2 f ] [ 2 3 f single-combination-test ] unit-test

DEFER: single-combination-test-2

: single-combination-test-4
    dup [ single-combination-test-2 ] when ;

: single-combination-test-3
    drop 3 ;

GENERIC: single-combination-test-2
M: object single-combination-test-2 single-combination-test-3 ;
M: f single-combination-test-2 single-combination-test-4 ;

[ 3 ] [ t single-combination-test-2 ] unit-test
[ 3 ] [ 3 single-combination-test-2 ] unit-test
[ f ] [ f single-combination-test-2 ] unit-test
