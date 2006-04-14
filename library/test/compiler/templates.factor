! Black box testing of templater optimization

IN: temporary
USING: compiler kernel kernel-internals math-internals test ;

! Oops!
[ 5000 ] [ [ 5000 ] compile-1 ] unit-test
[ "hi" ] [ [ "hi" ] compile-1 ] unit-test

[ 1 1 ] [ 1 [ dup ] compile-1 ] unit-test
[ 0 ] [ 3 [ tag ] compile-1 ] unit-test
[ 0 3 ] [ 3 [ [ tag ] keep ] compile-1 ] unit-test

[ { 1 2 3 } { 1 4 3 } 8 8 ]
[ { 1 2 3 } { 1 4 3 } [ over type over type ] compile-1 ]
unit-test

! Test literals in either side of a shuffle
[ 4 1 ] [ 1 [ [ 3 fixnum+ ] keep ] compile-1 ] unit-test

: foo ;

[ 4 4 ]
[ 1/2 [ tag [ foo ] keep ] compile-1 ]
unit-test

[ 1 2 2 ]
[ 1/2 [ dup 0 slot swap 1 slot [ foo ] keep ] compile-1 ]
unit-test
