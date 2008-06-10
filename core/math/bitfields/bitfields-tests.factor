USING: math math.bitfields tools.test kernel words ;
IN: math.bitfields.tests

[ 0 ] [ { } bitfield ] unit-test
[ 256 ] [ 1 { 8 } bitfield ] unit-test
[ 268 ] [ 3 1 { 8 2 } bitfield ] unit-test
[ 268 ] [ 1 { 8 { 3 2 } } bitfield ] unit-test
[ 512 ] [ 1 { { 1+ 8 } } bitfield ] unit-test

: a 1 ; inline
: b 2 ; inline

: foo ( -- flags ) { a b } flags ;

[ 3 ] [ foo ] unit-test
[ 3 ] [ { a b } flags ] unit-test
[ t ] [ \ foo compiled? ] unit-test
