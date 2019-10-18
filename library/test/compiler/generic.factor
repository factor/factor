IN: scratchpad
USE: compiler
USE: generic
USE: test
USE: math
USE: kernel
USE: words

GENERIC: single-combination-test

M: object single-combination-test drop ;
M: f single-combination-test nip ;

\ single-combination-test compile

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

\ single-combination-test-2 compile

[ 3 ] [ t single-combination-test-2 ] unit-test
[ 3 ] [ 3 single-combination-test-2 ] unit-test
[ f ] [ f single-combination-test-2 ] unit-test

GENERIC: broken-generic

M: fixnum broken-generic 1.0 * broken-generic ;
M: float broken-generic neg ;

: broken-partial-eval 5 broken-generic ;

\ broken-partial-eval compile

[ -5.0 ] [ broken-partial-eval ] unit-test
