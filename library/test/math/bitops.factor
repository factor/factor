IN: scratchpad
USE: kernel
USE: math
USE: stack
USE: test
USE: logic
USE: lists

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
[ 4 ] [ 4 7 bitand ] unit-test

[ 256 ] [ 65536 -8 shift ] unit-test
[ 256 ] [ 65536 >bignum -8 shift ] unit-test
[ 256 ] [ 65536 -8 >bignum shift ] unit-test
[ 256 ] [ 65536 >bignum -8 >bignum shift ] unit-test
[ 4294967296 ] [ 1 16 shift 16 shift ] unit-test
[ 4294967296 ] [ 1 32 shift ] unit-test
[ 1267650600228229401496703205376 ] [ 1 100 shift ] unit-test

[ t ] [ 1 27 shift fixnum? ] unit-test

[ t ] [
    t
    [ 27 28 29 30 31 32 59 60 61 62 63 64 ]
    [
        1 over shift swap 1 >bignum swap shift = and
    ] each
] unit-test

[ t ] [
    t
    [ 27 28 29 30 31 32 59 60 61 62 63 64 ]
    [
        -1 over shift swap -1 >bignum swap shift = and
    ] each
] unit-test

[ 12 ] [ 11 4 align ] unit-test
[ 12 ] [ 12 4 align ] unit-test
[ 12 ] [ 10 2 align ] unit-test
[ 14 ] [ 13 2 align ] unit-test
[ 11 ] [ 11 1 align ] unit-test
