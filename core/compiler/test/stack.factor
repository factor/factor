IN: temporary
USING: compiler kernel math-internals test ;

! Test shuffle intrinsics
[ ] [ 1 [ drop ] compile-1 ] unit-test
[ ] [ 1 2 [ 2drop ] compile-1 ] unit-test
[ ] [ 1 2 3 [ 3drop ] compile-1 ] unit-test
[ 1 1 ] [ 1 [ dup ] compile-1 ] unit-test
[ 1 2 1 2 ] [ 1 2 [ 2dup ] compile-1 ] unit-test
[ 1 2 3 1 2 3 ] [ 1 2 3 [ 3dup ] compile-1 ] unit-test
[ 2 3 1 ] [ 1 2 3 [ rot ] compile-1 ] unit-test
[ 3 1 2 ] [ 1 2 3 [ -rot ] compile-1 ] unit-test
[ 1 1 2 ] [ 1 2 [ dupd ] compile-1 ] unit-test
[ 2 1 3 ] [ 1 2 3 [ swapd ] compile-1 ] unit-test
[ 2 ] [ 1 2 [ nip ] compile-1 ] unit-test
[ 3 ] [ 1 2 3 [ 2nip ] compile-1 ] unit-test
[ 2 1 2 ] [ 1 2 [ tuck ] compile-1 ] unit-test
[ 1 2 1 ] [ 1 2 [ over ] compile-1 ] unit-test
[ 1 2 3 1 ] [ 1 2 3 [ pick ] compile-1 ] unit-test
[ 2 1 ] [ 1 2 [ swap ] compile-1 ] unit-test
