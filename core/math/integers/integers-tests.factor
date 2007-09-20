USING: kernel math namespaces prettyprint math.functions
math.private continuations tools.test sequences ;
IN: temporary

[ "-8" ] [ -8 unparse ] unit-test

[ t ] [ 0 fixnum? ] unit-test
[ t ] [ 31415 number? ] unit-test
[ t ] [ 31415 >bignum number? ] unit-test
[ t ] [ 2345621 fixnum? ] unit-test

[ t ] [ 2345621 dup >bignum >fixnum = ] unit-test

[ t ] [ 0 >fixnum 0 >bignum = ] unit-test
[ f ] [ 0 >fixnum 1 >bignum = ] unit-test
[ f ] [ 1 >bignum 0 >bignum = ] unit-test
[ t ] [ 0 >bignum 0 >fixnum = ] unit-test

[ t ] [ 0 >bignum bignum? ] unit-test
[ f ] [ 0 >fixnum bignum? ] unit-test
[ f ] [ 0 >fixnum bignum? ] unit-test
[ t ] [ 0 >fixnum fixnum? ] unit-test

[ -1 ] [ 1 neg ] unit-test
[ -1 ] [ 1 >bignum neg ] unit-test
[ 268435456 ] [ -268435456 >fixnum -1 * ] unit-test
[ 268435456 ] [ -268435456 >fixnum neg ] unit-test

[ 9 3 ] [ 93 10 /mod ] unit-test
[ 9 3 ] [ 93 >bignum 10 /mod ] unit-test

[ 5 ] [ 2 >bignum 3 >bignum + ] unit-test

[ -10000000001981284352 ] [
    -10000000000000000000
    HEX: -100000000 bitand
] unit-test

[ 9999999997686317056 ] [
    10000000000000000000
    HEX: -100000000 bitand
] unit-test

[ 4294967296 ] [
    -10000000000000000000
    HEX: 100000000 bitand
] unit-test

[ 0 ] [
    10000000000000000000
    HEX: 100000000 bitand
] unit-test

[ -1 ] [ -1 >bignum >fixnum ] unit-test

[ "8589934592" ]
[ 134217728 dup + dup + dup + dup + dup + dup + unparse ]
unit-test

[ t ] [ 0 0 ^ fp-nan? ] unit-test
[ 1 ] [ 10 0 ^ ] unit-test
[ 1/8 ] [ 1/2 3 ^ ] unit-test
[ 1/8 ] [ 2 -3 ^ ] unit-test
[ t ] [ 1 100 shift 2 100 ^ = ] unit-test

[ t ] [ 256 power-of-2? ] unit-test
[ f ] [ 123 power-of-2? ] unit-test

[ 7 ] [ 255 log2 ] unit-test
[ 8 ] [ 256 log2 ] unit-test
[ 8 ] [ 257 log2 ] unit-test
[ 0 ] [ 1   log2 ] unit-test

[ 7 ] [ 255 >bignum log2 ] unit-test
[ 8 ] [ 256 >bignum log2 ] unit-test
[ 8 ] [ 257 >bignum log2 ] unit-test
[ 0 ] [ 1   >bignum log2 ] unit-test

[ t ] [ BIN: 1101 0 bit? ] unit-test
[ f ] [ BIN: 1101 1 bit? ] unit-test
[ t ] [ BIN: 1101 2 bit? ] unit-test
[ t ] [ BIN: 1101 3 bit? ] unit-test
[ f ] [ BIN: 1101 4 bit? ] unit-test

[ t ] [ BIN: 1101 >bignum 0 bit? ] unit-test
[ f ] [ BIN: 1101 >bignum 1 bit? ] unit-test
[ t ] [ BIN: 1101 >bignum 2 bit? ] unit-test
[ t ] [ BIN: 1101 >bignum 3 bit? ] unit-test
[ f ] [ BIN: 1101 >bignum 4 bit? ] unit-test

[ t ] [ BIN: -1101 0 bit? ] unit-test
[ t ] [ BIN: -1101 1 bit? ] unit-test
[ f ] [ BIN: -1101 2 bit? ] unit-test
[ f ] [ BIN: -1101 3 bit? ] unit-test
[ t ] [ BIN: -1101 4 bit? ] unit-test

[ t ] [ BIN: -1101 >bignum 0 bit? ] unit-test
[ t ] [ BIN: -1101 >bignum 1 bit? ] unit-test
[ f ] [ BIN: -1101 >bignum 2 bit? ] unit-test
[ f ] [ BIN: -1101 >bignum 3 bit? ] unit-test
[ t ] [ BIN: -1101 >bignum 4 bit? ] unit-test

[ 1 ] [ 7/8 ceiling ] unit-test
[ 2 ] [ 3/2 ceiling ] unit-test
[ 0 ] [ -7/8 ceiling ] unit-test
[ -1 ] [ -3/2 ceiling ] unit-test

[ 2 ] [ 0 next-power-of-2 ] unit-test
[ 2 ] [ 1 next-power-of-2 ] unit-test
[ 2 ] [ 2 next-power-of-2 ] unit-test
[ 4 ] [ 3 next-power-of-2 ] unit-test
[ 16 ] [ 13 next-power-of-2 ] unit-test
[ 16 ] [ 16 next-power-of-2 ] unit-test

[ 268435456 ] [ -268435456 >fixnum -1 / ] unit-test
[ 268435456 ] [ -268435456 >fixnum -1 /i ] unit-test
[ 268435456 0 ] [ -268435456 >fixnum -1 /mod ] unit-test
[ 1/268435456 ] [ -1 -268435456 >fixnum / ] unit-test
[ 0 ] [ -1 -268435456 >fixnum /i ] unit-test
[ 0 -1 ] [ -1 -268435456 >fixnum /mod ] unit-test
[ 14355 ] [ 1591517158873146351817850880000000 32769 mod ] unit-test

[ -351382792 ] [ -43922849 3 shift ] unit-test

[ t ] [ 0 zero? ] unit-test
[ f ] [ 30 zero? ] unit-test
[ t ] [ 0 >bignum zero? ] unit-test

[ 4294967280 ] [ 268435455 >fixnum 16 fixnum* ] unit-test

[ 23603949310011464311086123800853779733506160743636399259558684142844552151041 ]
[
    1957739506503920732625800353008742584087090810400921800808997218266517557963281171906190947801528098188887586755474449585677502695226712388326288208691204
    79562815144503850065234921197651376510595262628033069372760833939060637564931
    bignum-mod
] unit-test

! We don't care if this fails or returns 0 (its CPU-specific)
! as long as it doesn't crash
[ ] [ [ 0 0 /i ] catch clear ] unit-test
[ ] [ [ 100000000000000000 0 /i ] catch clear ] unit-test

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
[ 10 ] [ 10 2 align ] unit-test
[ 14 ] [ 13 2 align ] unit-test
[ 11 ] [ 11 1 align ] unit-test

[ HEX: 332211 ] [
    B{ HEX: 11 HEX: 22 HEX: 33 } byte-array>bignum
] unit-test

[ HEX: 7a2c793b2ff08554 ] [
    B{ HEX: 54 HEX: 85 HEX: f0 HEX: 2f HEX: 3b HEX: 79 HEX: 2c HEX: 7a } byte-array>bignum
] unit-test

[ HEX: 988a259c3433f237 ] [
    B{ HEX: 37 HEX: f2 HEX: 33 HEX: 34 HEX: 9c HEX: 25 HEX: 8a HEX: 98 } byte-array>bignum
] unit-test
