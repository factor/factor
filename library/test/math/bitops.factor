IN: scratchpad
USE: kernel
USE: math
USE: stack
USE: test

[ -2 ] [ 1 bitnot ] unit-test
[ -2 ] [ 1 >bignum bitnot ] unit-test
[ -2 ] [ 1 >bignum bitnot ] unit-test
[ 0 ] [ 123 dup bitnot bitand ] unit-test
[ 0 ] [ 123 >bignum dup bitnot bitand ] unit-test
[ 0 ] [ 123 dup bitnot >bignum bitand ] unit-test
[ 0 ] [ 123 dup bitnot bitand >bignum ] unit-test
[ -1 ] [ 123 dup bitnot bitor ] unit-test
[ -1 ] [ 123 >bignum dup bitnot bitor ] unit-test
[ -1 ] [ 123 dup bitnot >bignum bitor ] unit-test
[ -1 ] [ 123 dup bitnot bitor >bignum ] unit-test
[ -1 ] [ 123 dup bitnot bitxor ] unit-test
[ -1 ] [ 123 >bignum dup bitnot bitxor ] unit-test
[ -1 ] [ 123 dup bitnot >bignum bitxor ] unit-test
[ -1 ] [ 123 dup bitnot bitxor >bignum ] unit-test
