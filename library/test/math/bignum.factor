IN: scratchpad
USE: arithmetic
USE: stack
USE: test
USE: unparser

[ -1 ] [ -1 >bignum >fixnum ] unit-test

[ "8589934592" ]
[ 134217728 dup + dup + dup + dup + dup + dup + unparse ]
unit-test

[ 256 ] [ 65536 -8 shift ] unit-test
[ 256 ] [ 65536 >bignum -8 shift ] unit-test
[ 256 ] [ 65536 -8 >bignum shift ] unit-test
[ 256 ] [ 65536 >bignum -8 >bignum shift ] unit-test
[ 4294967296 ] [ 1 16 shift 16 shift ] unit-test
[ 4294967296 ] [ 1 32 shift ] unit-test
[ 1267650600228229401496703205376 ] [ 1 100 shift ] unit-test
