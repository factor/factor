! Copyright (C) 2018 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel ryu math math.bitwise tools.test ;
IN: ryu.tests

! Basic
{ "0e0" } [ 0.0 d2s ] unit-test
{ "-0e0" } [ -0.0 d2s ] unit-test
{ "1e0" } [ 1.0 d2s ] unit-test
{ "-1e0" } [ -1.0 d2s ] unit-test
{ "NaN" } [ 0/0. d2s ] unit-test
{ "Inf" } [ 1/0. d2s ] unit-test
{ "-Inf" } [ -1/0. d2s ] unit-test

! SwitchToSubnormal
{ "2.2250738585072014e-308" } [ 2.2250738585072014e-308 d2s ] unit-test

! MinAndMax
{ "1.7976931348623157e308" } [ 0x7fefffffffffffff bits>double d2s ] unit-test
{ "5e-324" } [ 1 bits>double d2s ] unit-test

! LotsOfTrailingZeros
{ "2.9802322387695312e-8" } [ 2.98023223876953125e-8 d2s ] unit-test

! Regression
{ "-2.109808898695963e16" } [ -2.109808898695963e16 d2s ] unit-test
{ "4.940656e-318" } [ 4.940656e-318 d2s ] unit-test
{ "1.18575755e-316" } [ 1.18575755e-316 d2s ] unit-test
{ "2.989102097996e-312" } [ 2.989102097996e-312 d2s ] unit-test
{ "9.0608011534336e15" } [ 9.0608011534336e15 d2s ] unit-test
{ "4.708356024711512e18" } [ 4.708356024711512e18 d2s ] unit-test
{ "9.409340012568248e18" } [ 9.409340012568248e18 d2s ] unit-test
{ "1.2345678e0" } [ 1.2345678 d2s ] unit-test


! LooksLikePow5
! These numbers have a mantissa that is a multiple of the largest power of
! 5 that fits, and an exponent that causes the computation for q to result
! in 22, which is a corner case for Ryu.
{ "5.764607523034235e39" } [ 0x4830F0CF064DD592 bits>double d2s ] unit-test
{ "1.152921504606847e40" } [ 0x4840F0CF064DD592 bits>double d2s ] unit-test
{ "2.305843009213694e40" } [ 0x4850F0CF064DD592 bits>double d2s ] unit-test

! OutputLength
{ "1e0" } [ 1 d2s ] unit-test ! already tested in Basic
{ "1.2e0" } [ 1.2 d2s ] unit-test
{ "1.23e0" } [ 1.23 d2s ] unit-test
{ "1.234e0" } [ 1.234 d2s ] unit-test
{ "1.2345e0" } [ 1.2345 d2s ] unit-test
{ "1.23456e0" } [ 1.23456 d2s ] unit-test
{ "1.234567e0" } [ 1.234567 d2s ] unit-test
{ "1.2345678e0" } [ 1.2345678 d2s ] unit-test ! already tested in Regression
{ "1.23456789e0" } [ 1.23456789 d2s ] unit-test
{ "1.234567895e0" } [ 1.234567895 d2s ] unit-test ! 1.234567890 would be trimmed
{ "1.2345678901e0" } [ 1.2345678901 d2s ] unit-test
{ "1.23456789012e0" } [ 1.23456789012 d2s ] unit-test
{ "1.234567890123e0" } [ 1.234567890123 d2s ] unit-test
{ "1.2345678901234e0" } [ 1.2345678901234 d2s ] unit-test
{ "1.23456789012345e0" } [ 1.23456789012345 d2s ] unit-test
{ "1.234567890123456e0" } [ 1.234567890123456 d2s ] unit-test
{ "1.2345678901234567e0" } [ 1.2345678901234567 d2s ] unit-test

! Test 32-bit chunking
{ "4.294967294e0" } [ 4.294967294 d2s ] unit-test ! 2^32 - 2
{ "4.294967295e0" } [ 4.294967295 d2s ] unit-test ! 2^32 - 1
{ "4.294967296e0" } [ 4.294967296 d2s ] unit-test ! 2^32
{ "4.294967297e0" } [ 4.294967297 d2s ] unit-test ! 2^32 + 1
{ "4.294967298e0" } [ 4.294967298 d2s ] unit-test ! 2^32 + 2

! Test min, max shift values in shiftright128
! MinMaxShift

: make-double ( mantissa exponent neg? -- float )
    [ 11 set-bit ] when 52 shift bitor bits>double ;

CONSTANT: maxMantissa 9007199254740991 ! (1 << 53) - 1;

{ "1.7800590868057611e-307" } [ 0 4 f make-double d2s ] unit-test
{ "2.8480945388892175e-306" } [ maxMantissa 6 f make-double d2s ] unit-test
{ "2.446494580089078e-296" } [ 0 41 f make-double d2s ] unit-test
{ "4.8929891601781557e-296" } [ maxMantissa 40 f make-double d2s ] unit-test
{ "1.8014398509481984e16" } [ 0 1077 f make-double d2s ] unit-test
{ "3.6028797018963964e16" } [ maxMantissa 1076 f make-double d2s ] unit-test
{ "2.900835519859558e-216" } [ 0 307 f make-double d2s ] unit-test
{ "5.801671039719115e-216" } [ maxMantissa 306 f make-double d2s ] unit-test
{ "3.196104012172126e-27" } [ 0x000FA7161A4D6e0C 934 f make-double d2s ] unit-test
