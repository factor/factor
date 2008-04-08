USING: math.bitfields.lib tools.test ;
IN: math.bitfields.lib.test

[ 0 ] [ 1 0 0 bitroll ] unit-test
[ 1 ] [ 1 0 1 bitroll ] unit-test
[ 1 ] [ 1 1 1 bitroll ] unit-test
[ 1 ] [ 1 0 2 bitroll ] unit-test
[ 1 ] [ 1 0 1 bitroll ] unit-test
[ 1 ] [ 1 20 2 bitroll ] unit-test
[ 1 ] [ 1 8 8 bitroll ] unit-test
[ 1 ] [ 1 -8 8 bitroll ] unit-test
[ 1 ] [ 1 -32 8 bitroll ] unit-test
[ 128 ] [ 1 -1 8 bitroll ] unit-test
[ 8 ] [ 1 3 32 bitroll ] unit-test
