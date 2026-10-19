USING: compiler.test.literal-metadata compiler.test grouping kernel math math.constants math.order sequences
tools.test ;

{ t } [ 0.0 float? ] unit-test
{ t } [ 3.1415 number? ] unit-test
{ f } [ 12 float? ] unit-test

{ f } [ 1 1.0 = ] unit-test
{ t } [ 1 1.0 number= ] floating-point-unit-test

{ f } [ 1 >bignum 1.0 = ] unit-test
{ t } [ 1 >bignum 1.0 number= ] floating-point-unit-test

{ f } [ 1.0 1 = ] unit-test
{ t } [ 1.0 1 number= ] floating-point-unit-test

{ f } [ 1.0 1 >bignum = ] unit-test
{ t } [ 1.0 1 >bignum number= ] floating-point-unit-test

{ f } [ 1 1.3 = ] unit-test
{ f } [ 1 >bignum 1.3 = ] unit-test
{ f } [ 1.3 1 = ] unit-test
{ f } [ 1.3 1 >bignum = ] unit-test

{ t } [ 134.3 >fixnum 134 = ] floating-point-unit-test

{ 3 } [ 3.5 >bignum ] floating-point-unit-test
{ -3 } [ -3.5 >bignum ] floating-point-unit-test

{ 3 } [ 3.5 >fixnum ] floating-point-unit-test
{ -3 } [ -3.5 >fixnum ] floating-point-unit-test

{ 2.1 } [ -2.1 neg ] floating-point-unit-test

{ 3 } [ 3.1415 >fixnum ] floating-point-unit-test
{ 3 } [ 3.1415 >bignum ] floating-point-unit-test

{ t } [ pi 3 > ] floating-point-unit-test
{ f } [ e 2 <= ] floating-point-unit-test

{ t } [ 1.0 dup float>bits bits>float fp-bitwise= ] unit-test

! #2182: preserve the sign, payload and signaling bit of binary32 NaNs.
{ t } [
    {
        0x00000000 0x80000000 0x00000001 0x007fffff
        0x00800000 0x3f800000 0x7f7fffff 0x7f800000 0xff800000
        0x7f800001 0x7f802000 0x7fbfffff 0x7fc00000 0x7fffffff
        0xff800001 0xff802000 0xffbfffff 0xffc00000 0xffffffff
    } [ dup [ bits>float float>bits ] compile-call = ] all?
] unit-test
{ 0x7f800001 } [ 0x7ff0000000000001 bits>double float>bits ] unit-test
{ 0xff800001 } [ 0xfff0000000000001 bits>double float>bits ] unit-test
{ 0x7fc00000 } [ 0x7ff8000000000001 bits>double float>bits ] unit-test

! #2594: transporting a double's bits must not quiet signaling NaNs either.
{ t } [
    {
        0x7ff0000000000123 0x7ff8000000000123
        0xfff0000000000123 0xfff8000000000123
    } [ dup [ bits>double double>bits ] compile-call = ] all?
] unit-test
{ t } [ pi double>bits bits>double pi fp-bitwise= ] unit-test
{ t } [ e double>bits bits>double e fp-bitwise= ] unit-test

{ 0b11111111111000000000000000000000000000000000000000000000000000 }
[ 1.5 double>bits ] unit-test

{ 1.5 }
[ 0b11111111111000000000000000000000000000000000000000000000000000 bits>double ]
literal-metadata-unit-test

{ 2.0 } [ 1.0 1 + ] floating-point-unit-test
{ 0.0 } [ 1.0 1 - ] floating-point-unit-test

{ t } [ 0.0 zero? ] floating-point-unit-test
{ t } [ -0.0 zero? ] floating-point-unit-test

{ 0 } [ 1/0. >bignum ] floating-point-unit-test

{ t } [ 64 <iota> [ 2^ 0.5 * ] map [ < ] monotonic? ] floating-point-unit-test

{ 5 } [ 10.5 1.9 /i ] floating-point-unit-test

{ t } [ 0   0   /f                 fp-nan? ] floating-point-unit-test
{ t } [ 0.0 0.0 /f                 fp-nan? ] floating-point-unit-test
{ t } [ 0.0 0.0 /                  fp-nan? ] floating-point-unit-test
{ t } [ 0   0   [ >bignum ] bi@ /f fp-nan? ] floating-point-unit-test

{ 1/0. } [ 1 0 /f ] floating-point-unit-test
{ 1/0. } [ 1.0 0.0 /f ] floating-point-unit-test
{ 1/0. } [ 1.0 0.0 / ] floating-point-unit-test
{ 1/0. } [ 1 0 [ >bignum ] bi@ /f ] floating-point-unit-test

{ -1/0. } [ -1 0 /f ] floating-point-unit-test
{ -1/0. } [ -1.0 0.0 /f ] floating-point-unit-test
{ -1/0. } [ -1.0 0.0 / ] floating-point-unit-test
{ -1/0. } [ -1 0 [ >bignum ] bi@ /f ] floating-point-unit-test

{ t } [ 0/0. 0/0. unordered? ] unit-test
{ t } [ 1.0 0/0. unordered? ] unit-test
{ t } [ 0/0. 1.0 unordered? ] unit-test
{ f } [ 1.0 1.0 unordered? ] unit-test

{ t } [ -0.0 fp-sign ] unit-test
{ t } [ -1.0 fp-sign ] unit-test
{ f } [ 0.0 fp-sign ] unit-test
{ f } [ 1.0 fp-sign ] unit-test

{ t } [ -0.0 abs 0.0 fp-bitwise= ] unit-test
{ 1.5 } [ -1.5 abs ] floating-point-unit-test
{ 1.5 } [ 1.5 abs ] floating-point-unit-test

{ 5.0 } [ 3 5.0 max ] floating-point-unit-test
{ 3 } [ 3 5.0 min ] floating-point-unit-test

{ 39 0x1.999999999998ap-4 } [ 4.0 .1 /mod ] floating-point-unit-test
{ 38 0x1.9999999999984p-4 } [ 3.9 .1 /mod ] floating-point-unit-test
{ -39 0x1.999999999998ap-4 } [ 4.0 -.1 /mod ] floating-point-unit-test
{ -38 0x1.9999999999984p-4 } [ 3.9 -.1 /mod ] floating-point-unit-test
{ 39 -0x1.999999999998ap-4 } [ -4.0 -.1 /mod ] floating-point-unit-test
{ 38 -0x1.9999999999984p-4 } [ -3.9 -.1 /mod ] floating-point-unit-test
{ -39 -0x1.999999999998ap-4 } [ -4.0 .1 /mod ] floating-point-unit-test
{ -38 -0x1.9999999999984p-4 } [ -3.9 .1 /mod ] floating-point-unit-test

{ 0.5 } [ 3.5 0.75 mod ] floating-point-unit-test
{ -0.5 } [ -3.5 0.75 mod ] floating-point-unit-test
{ -0.5 } [ -3.5 -0.75 mod ] floating-point-unit-test
{ 0.5 } [ 3.5 -0.75 mod ] floating-point-unit-test

{ 4 0.5 } [ 3.5 0.75 /mod ] floating-point-unit-test
{ -4 -0.5 } [ -3.5 0.75 /mod ] floating-point-unit-test
{ 4 -0.5 } [ -3.5 -0.75 /mod ] floating-point-unit-test
{ -4 0.5 } [ 3.5 -0.75 /mod ] floating-point-unit-test
