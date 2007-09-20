USING: math math.bitfields tools.test kernel ;
IN: temporary

[ 0 ] [ { } bitfield ] unit-test
[ 256 ] [ 1 { 8 } bitfield ] unit-test
[ 268 ] [ 3 1 { 8 2 } bitfield ] unit-test
[ 268 ] [ 1 { 8 { 3 2 } } bitfield ] unit-test
[ 512 ] [ 1 { { 1+ 8 } } bitfield ] unit-test
