IN: scratchpad
USE: stack
USE: math
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
[ 268435456 ] [ -268435456 >fixnum -1 / ] unit-test
[ 268435456 ] [ -268435456 >fixnum -1 /i ] unit-test
[ 268435456 0 ] [ -268435456 >fixnum -1 /mod ] unit-test
[ 1/268435456 ] [ -1 -268435456 >fixnum / ] unit-test
[ 0 ] [ -1 -268435456 >fixnum /i ] unit-test
[ 0 -1 ] [ -1 -268435456 >fixnum /mod ] unit-test
[ 14355 ] [ 1591517158873146351817850880000000 32769 mod ] unit-test
