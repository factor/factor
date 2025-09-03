USING: continuations kernel math math.functions math.order
math.private namespaces prettyprint prettyprint.config random
sequences tools.test ;
IN: math.integers.tests

10 number-base [
    [ "-8" ] [ -8 unparse ] unit-test
] with-variable

{ t } [ 0 fixnum? ] unit-test
{ t } [ 31415 number? ] unit-test
{ t } [ 31415 >bignum number? ] unit-test
{ t } [ 2345621 fixnum? ] unit-test

{ t } [ 2345621 dup >bignum >fixnum = ] unit-test

{ t } [ 0 >fixnum 0 >bignum = ] unit-test
{ f } [ 0 >fixnum 1 >bignum = ] unit-test
{ f } [ 1 >bignum 0 >bignum = ] unit-test
{ t } [ 0 >bignum 0 >fixnum = ] unit-test

{ t } [ 0 >bignum bignum? ] unit-test
{ f } [ 0 >fixnum bignum? ] unit-test
{ f } [ 0 >fixnum bignum? ] unit-test
{ t } [ 0 >fixnum fixnum? ] unit-test

{ -1 } [ 1 neg ] unit-test
{ -1 } [ 1 >bignum neg ] unit-test
{ 134217728 } [ -134217728 >fixnum -1 * ] unit-test
{ 134217728 } [ -134217728 >fixnum neg ] unit-test

{ 9 3 } [ 93 10 /mod ] unit-test
{ 9 3 } [ 93 >bignum 10 /mod ] unit-test

{ 5 } [ 2 >bignum 3 >bignum + ] unit-test

{ -10000000001981284352 } [
    -10000000000000000000
    -0x100000000 bitand
] unit-test

{ 9999999997686317056 } [
    10000000000000000000
    -0x100000000 bitand
] unit-test

{ 4294967296 } [
    -10000000000000000000
    0x100000000 bitand
] unit-test

{ 0 } [
    10000000000000000000
    0x100000000 bitand
] unit-test

{ -1 } [ -1 >bignum >fixnum ] unit-test

10 number-base [
    [ "8589934592" ]
    [ 134217728 dup + dup + dup + dup + dup + dup + unparse ]
    unit-test
] with-variable

{ 7 } [ 255 log2 ] unit-test
{ 8 } [ 256 log2 ] unit-test
{ 8 } [ 257 log2 ] unit-test
{ 0 } [ 1   log2 ] unit-test

{ 7 } [ 255 >bignum log2 ] unit-test
{ 8 } [ 256 >bignum log2 ] unit-test
{ 8 } [ 257 >bignum log2 ] unit-test
{ 0 } [ 1   >bignum log2 ] unit-test

{ f } [ 0b1101 -1 bit? ] unit-test
{ t } [ 0b1101 0 bit? ] unit-test
{ f } [ 0b1101 1 bit? ] unit-test
{ t } [ 0b1101 2 bit? ] unit-test
{ t } [ 0b1101 3 bit? ] unit-test
{ f } [ 0b1101 4 bit? ] unit-test
{ f } [ 0b1101 1000 bit? ] unit-test

{ f } [ 0b1101 >bignum -1 bit? ] unit-test
{ t } [ 0b1101 >bignum 0 bit? ] unit-test
{ f } [ 0b1101 >bignum 1 bit? ] unit-test
{ t } [ 0b1101 >bignum 2 bit? ] unit-test
{ t } [ 0b1101 >bignum 3 bit? ] unit-test
{ f } [ 0b1101 >bignum 4 bit? ] unit-test
{ f } [ 0b1101 >bignum 1000 bit? ] unit-test

{ t } [ -0b1101 -1 bit? ] unit-test
{ t } [ -0b1101 0 bit? ] unit-test
{ t } [ -0b1101 1 bit? ] unit-test
{ f } [ -0b1101 2 bit? ] unit-test
{ f } [ -0b1101 3 bit? ] unit-test
{ t } [ -0b1101 4 bit? ] unit-test
{ t } [ -0b1101 1000 bit? ] unit-test

{ t } [ -0b1101 >bignum -1 bit? ] unit-test
{ t } [ -0b1101 >bignum 0 bit? ] unit-test
{ t } [ -0b1101 >bignum 1 bit? ] unit-test
{ f } [ -0b1101 >bignum 2 bit? ] unit-test
{ f } [ -0b1101 >bignum 3 bit? ] unit-test
{ t } [ -0b1101 >bignum 4 bit? ] unit-test
{ t } [ -0b1101 >bignum 1000 bit? ] unit-test

{ t } [ 1067811677921310779 >bignum 59 bit? ] unit-test

{ 2 } [ 0 next-power-of-2 ] unit-test
{ 2 } [ 1 next-power-of-2 ] unit-test
{ 2 } [ 2 next-power-of-2 ] unit-test
{ 4 } [ 3 next-power-of-2 ] unit-test
{ 16 } [ 13 next-power-of-2 ] unit-test
{ 16 } [ 16 next-power-of-2 ] unit-test

{ 134217728 } [ -134217728 >fixnum -1 /i ] unit-test
{ 134217728 0 } [ -134217728 >fixnum -1 /mod ] unit-test
{ 0 } [ -1 -134217728 >fixnum /i ] unit-test
{ 4420880996869850977 } [ 13262642990609552931 3 /i ] unit-test
{ 0 -1 } [ -1 -134217728 >fixnum /mod ] unit-test
{ 0 -1 } [ -1 -134217728 >bignum /mod ] unit-test
{ 14355 } [ 1591517158873146351817850880000000 32769 mod ] unit-test
{ 8 530505719624382123 } [ 13262642990609552931 1591517158873146351 /mod ] unit-test
{ 8 } [ 13262642990609552931 1591517158873146351 /i ] unit-test
{ 530505719624382123 } [ 13262642990609552931 1591517158873146351 mod ] unit-test

{ -351382792 } [ -43922849 3 shift ] unit-test

{ t } [ 0 zero? ] unit-test
{ f } [ 30 zero? ] unit-test
{ t } [ 0 >bignum zero? ] unit-test

{ 2147483632 } [ 134217727 >fixnum 16 fixnum* ] unit-test

{ 23603949310011464311086123800853779733506160743636399259558684142844552151041 }
[
    1957739506503920732625800353008742584087090810400921800808997218266517557963281171906190947801528098188887586755474449585677502695226712388326288208691204
    79562815144503850065234921197651376510595262628033069372760833939060637564931
    bignum-mod
] unit-test

! We don't care if this fails or returns 0 (its CPU-specific)
! as long as it doesn't crash
[ 0 0 /i drop ] must-fail
[ 100000000000000000 0 /i drop ] must-fail

{ -2 } [ 1 bitnot ] unit-test
{ -2 } [ 1 >bignum bitnot ] unit-test
{ -2 } [ 1 >bignum bitnot ] unit-test
{ 0 } [ 123 dup bitnot bitand ] unit-test
{ 0 } [ 123 >bignum dup bitnot bitand ] unit-test
{ 0 } [ 123 dup bitnot >bignum bitand ] unit-test
{ 0 } [ 123 dup bitnot bitand >bignum ] unit-test
{ -1 } [ 123 dup bitnot bitor ] unit-test
{ -1 } [ 123 >bignum dup bitnot bitor ] unit-test
{ -1 } [ 123 dup bitnot >bignum bitor ] unit-test
{ -1 } [ 123 dup bitnot bitor >bignum ] unit-test
{ -1 } [ 123 dup bitnot bitxor ] unit-test
{ -1 } [ 123 >bignum dup bitnot bitxor ] unit-test
{ -1 } [ 123 dup bitnot >bignum bitxor ] unit-test
{ -1 } [ 123 dup bitnot bitxor >bignum ] unit-test
{ 4 } [ 4 7 bitand ] unit-test

{ 256 } [ 65536 -8 shift ] unit-test
{ 256 } [ 65536 >bignum -8 shift ] unit-test
{ 256 } [ 65536 -8 >bignum shift ] unit-test
{ 256 } [ 65536 >bignum -8 >bignum shift ] unit-test
{ 4294967296 } [ 1 16 shift 16 shift ] unit-test
{ 4294967296 } [ 1 32 shift ] unit-test
{ 1267650600228229401496703205376 } [ 1 100 shift ] unit-test

{ t } [ 1 26 shift fixnum? ] unit-test

{ t } [
    t
    [ 27 28 29 30 31 32 59 60 61 62 63 64 ]
    [
        1 over shift swap 1 >bignum swap shift = and
    ] each
] unit-test

{ t } [
    t
    [ 27 28 29 30 31 32 59 60 61 62 63 64 ]
    [
        -1 over shift swap -1 >bignum swap shift = and
    ] each
] unit-test

{ 12 } [ 11 4 align ] unit-test
{ 12 } [ 12 4 align ] unit-test
{ 10 } [ 10 2 align ] unit-test
{ 14 } [ 13 2 align ] unit-test
{ 11 } [ 11 1 align ] unit-test

{ t } [ 256 power-of-2? ] unit-test
{ f } [ 123 power-of-2? ] unit-test

{ f } [ -128 power-of-2? ] unit-test
{ f } [ 0 power-of-2? ] unit-test
{ t } [ 1 power-of-2? ] unit-test

: ratio>float ( a b -- f ) [ >bignum ] bi@ /f ;

{ 5. } [ 5 1 ratio>float ] unit-test
{ 4. } [ 4 1 ratio>float ] unit-test
{ 2. } [ 2 1 ratio>float ] unit-test
{ .5 } [ 1 2 ratio>float ] unit-test
{ .75 } [ 3 4 ratio>float ] unit-test
{ 1. } [ 2000 2^ 2000 2^ 1 + ratio>float ] unit-test
{ -1. } [ 2000 2^ neg 2000 2^ 1 + ratio>float ] unit-test
{ 0.4 } [ 6 15 ratio>float ] unit-test

{ 0x3fe553522d230931 }
[ 61967020039 92984792073 ratio>float double>bits ] unit-test

: random-integer ( -- n )
    32 random-bits
    { t f } random [ neg ] when
    { t f } random [ >bignum ] when ;

{ t } [
    10000 [
        drop
        random-integer
        random-integer
        [ >float / ] [ /f ] 2bi 0.1 ~
    ] all-integers?
] unit-test

! Ensure that /f is accurate for fixnums > 2^53 on 64-bit platforms
{ 0x1.758bec11492f9p-54 } [ 1 12345678901234567 /f ] unit-test
{ -0x1.758bec11492f9p-54 } [ 1 -12345678901234567 /f ] unit-test

! Ensure that /f rounds to nearest and not to zero
{ 0x1.0p55 } [ 0x7f,ffff,ffff,ffff >bignum 1 /f ] unit-test
{ 0x1.0p55 } [ -0x7f,ffff,ffff,ffff >bignum -1 /f ] unit-test
{ -0x1.0p55 } [ -0x7f,ffff,ffff,ffff >bignum 1 /f ] unit-test
{ -0x1.0p55 } [ 0x7f,ffff,ffff,ffff >bignum -1 /f ] unit-test

{ 0x1.0000,0000,0000,0p56 } [ 0x100,0000,0000,0007 >bignum 1 /f ] unit-test
{ 0x1.0000,0000,0000,0p56 } [ -0x100,0000,0000,0007 >bignum -1 /f ] unit-test
{ 0x1.0000,0000,0000,0p120 } [ 0x100,0000,0000,0007,FFFF,FFFF,FFFF,FFFF >bignum 1 /f ] unit-test
{ 0x1.0000,0000,0000,0p120 } [ -0x100,0000,0000,0007,FFFF,FFFF,FFFF,FFFF >bignum -1 /f ] unit-test
{ 0x1.0000,0000,0000,0p56 } [ 0x100,0000,0000,0008 >bignum 1 /f ] unit-test
{ 0x1.0000,0000,0000,0p56 } [ -0x100,0000,0000,0008 >bignum -1 /f ] unit-test
{ 0x1.0000,0000,0000,1p56 } [ 0x100,0000,0000,0009 >bignum 1 /f ] unit-test
{ 0x1.0000,0000,0000,1p56 } [ -0x100,0000,0000,0009 >bignum -1 /f ] unit-test
{ 0x1.0000,0000,0000,1p120 } [ 0x100,0000,0000,0008,0000,0000,0000,0001 >bignum 1 /f ] unit-test
{ 0x1.0000,0000,0000,1p120 } [ -0x100,0000,0000,0008,0000,0000,0000,0001 >bignum -1 /f ] unit-test

! Ensure that /f rounds to even on tie
{ 0x1.0000,0000,0000,1p56 } [ 0x100,0000,0000,0017 >bignum 1 /f ] unit-test
{ 0x1.0000,0000,0000,1p56 } [ -0x100,0000,0000,0017 >bignum -1 /f ] unit-test
{ 0x1.0000,0000,0000,1p120 } [ 0x100,0000,0000,0017,FFFF,FFFF,FFFF,FFFF >bignum 1 /f ] unit-test
{ 0x1.0000,0000,0000,1p120 } [ -0x100,0000,0000,0017,FFFF,FFFF,FFFF,FFFF >bignum -1 /f ] unit-test
{ 0x1.0000,0000,0000,2p56 } [ 0x100,0000,0000,0018 >bignum 1 /f ] unit-test
{ 0x1.0000,0000,0000,2p56 } [ -0x100,0000,0000,0018 >bignum -1 /f ] unit-test
{ 0x1.0000,0000,0000,2p56 } [ 0x100,0000,0000,0019 >bignum 1 /f ] unit-test
{ 0x1.0000,0000,0000,2p56 } [ -0x100,0000,0000,0019 >bignum -1 /f ] unit-test
{ 0x1.0000,0000,0000,2p120 } [ 0x100,0000,0000,0018,0000,0000,0000,0001 >bignum 1 /f ] unit-test
{ 0x1.0000,0000,0000,2p120 } [ -0x100,0000,0000,0018,0000,0000,0000,0001 >bignum -1 /f ] unit-test

{ 17 } [ 17 >bignum 5 max ] unit-test
{ 5 } [ 17 >bignum 5 min ] unit-test

{ 1 } [ 1 202402253307310618352495346718917307049556649764142118356901358027430339567995346891960383701437124495187077864316811911389808737385793476867013399940738509921517424276566361364466907742093216341239767678472745068562007483424692698618103355649159556340810056512358769552333414615230502532186327508646006263307707741093494784 /f double>bits ] unit-test
{ 12 } [ 3 50600563326827654588123836679729326762389162441035529589225339506857584891998836722990095925359281123796769466079202977847452184346448369216753349985184627480379356069141590341116726935523304085309941919618186267140501870856173174654525838912289889085202514128089692388083353653807625633046581877161501565826926935273373696 /f double>bits ] unit-test
{ 123 } [ 123 202402253307310618352495346718917307049556649764142118356901358027430339567995346891960383701437124495187077864316811911389808737385793476867013399940738509921517424276566361364466907742093216341239767678472745068562007483424692698618103355649159556340810056512358769552333414615230502532186327508646006263307707741093494784 /f double>bits ] unit-test
{ 1234 } [ 617 101201126653655309176247673359458653524778324882071059178450679013715169783997673445980191850718562247593538932158405955694904368692896738433506699970369254960758712138283180682233453871046608170619883839236372534281003741712346349309051677824579778170405028256179384776166707307615251266093163754323003131653853870546747392 /f double>bits ] unit-test
{ 1/0. } [ 2048 2^ 1 /f ] unit-test
{ -1/0. } [ 2048 2^ -1 /f ] unit-test
{ -1/0. } [ 2048 2^ neg 1 /f ] unit-test
{ 1/0. } [ 2048 2^ neg -1 /f ] unit-test

! bignum/f had a bug for results in ]0x1.0p-1022,0x0.4p-1022]
! these are the first subnormals...
{ 0x0.cp-1022 } [ 12 1026 2^ /f ] unit-test
{ 0x0.8p-1022 } [ 8 1026 2^ /f ] unit-test
{ 0x0.6p-1022 } [ 6 1026 2^ /f ] unit-test
{ 0x0.4p-1022 } [ 4 1026 2^ /f ] unit-test

! bignum/f didn't round subnormals
! biggest subnormal to smallest normal rounding
{ 0x1.0p-1022 } [ 0xfffffffffffffffffffffffff 1122 2^ /f ] unit-test
! almost half less than smallest subnormal to smallest subnormal rounding
{ 0x1.0p-1074 } [ 0x8000000000000000000000001 1122 52 + 2^ /f ] unit-test
! half less than smallest subnormal to 0
{ 0.0 } [ 0x8000000000000000000000000 1122 52 + 2^ /f ] unit-test

! rounding triggering special case in post-scale
{ 1.0 } [ 300 2^ 1 - 300 2^ /f ] unit-test
