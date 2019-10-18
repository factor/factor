USING: grouping kernel math math.constants math.order sequences
tools.test ;

{ t } [ 0.0 float? ] unit-test
{ t } [ 3.1415 number? ] unit-test
{ f } [ 12 float? ] unit-test

{ f } [ 1 1.0 = ] unit-test
{ t } [ 1 1.0 number= ] unit-test

{ f } [ 1 >bignum 1.0 = ] unit-test
{ t } [ 1 >bignum 1.0 number= ] unit-test

{ f } [ 1.0 1 = ] unit-test
{ t } [ 1.0 1 number= ] unit-test

{ f } [ 1.0 1 >bignum = ] unit-test
{ t } [ 1.0 1 >bignum number= ] unit-test

{ f } [ 1 1.3 = ] unit-test
{ f } [ 1 >bignum 1.3 = ] unit-test
{ f } [ 1.3 1 = ] unit-test
{ f } [ 1.3 1 >bignum = ] unit-test

{ t } [ 134.3 >fixnum 134 = ] unit-test

{ 3 } [ 3.5 >bignum ] unit-test
{ -3 } [ -3.5 >bignum ] unit-test

{ 3 } [ 3.5 >fixnum ] unit-test
{ -3 } [ -3.5 >fixnum ] unit-test

{ 2.1 } [ -2.1 neg ] unit-test

{ 3 } [ 3.1415 >fixnum ] unit-test
{ 3 } [ 3.1415 >bignum ] unit-test

{ t } [ pi 3 > ] unit-test
{ f } [ e 2 <= ] unit-test

{ t } [ 1.0 dup float>bits bits>float = ] unit-test
{ t } [ pi double>bits bits>double pi = ] unit-test
{ t } [ e double>bits bits>double e = ] unit-test

{ 0b11111111111000000000000000000000000000000000000000000000000000 }
[ 1.5 double>bits ] unit-test

{ 1.5 }
[ 0b11111111111000000000000000000000000000000000000000000000000000 bits>double ]
unit-test

{ 2.0 } [ 1.0 1 + ] unit-test
{ 0.0 } [ 1.0 1 - ] unit-test

{ t } [ 0.0 zero? ] unit-test
{ t } [ -0.0 zero? ] unit-test

{ 0 } [ 1/0. >bignum ] unit-test

{ t } [ 64 <iota> [ 2^ 0.5 * ] map [ < ] monotonic? ] unit-test

{ 5 } [ 10.5 1.9 /i ] unit-test

{ t } [ 0   0   /f                 fp-nan? ] unit-test
{ t } [ 0.0 0.0 /f                 fp-nan? ] unit-test
{ t } [ 0.0 0.0 /                  fp-nan? ] unit-test
{ t } [ 0   0   [ >bignum ] bi@ /f fp-nan? ] unit-test

{ 1/0. } [ 1 0 /f ] unit-test
{ 1/0. } [ 1.0 0.0 /f ] unit-test
{ 1/0. } [ 1.0 0.0 / ] unit-test
{ 1/0. } [ 1 0 [ >bignum ] bi@ /f ] unit-test

{ -1/0. } [ -1 0 /f ] unit-test
{ -1/0. } [ -1.0 0.0 /f ] unit-test
{ -1/0. } [ -1.0 0.0 / ] unit-test
{ -1/0. } [ -1 0 [ >bignum ] bi@ /f ] unit-test

{ t } [ 0/0. 0/0. unordered? ] unit-test
{ t } [ 1.0 0/0. unordered? ] unit-test
{ t } [ 0/0. 1.0 unordered? ] unit-test
{ f } [ 1.0 1.0 unordered? ] unit-test

{ t } [ -0.0 fp-sign ] unit-test
{ t } [ -1.0 fp-sign ] unit-test
{ f } [ 0.0 fp-sign ] unit-test
{ f } [ 1.0 fp-sign ] unit-test

{ t } [ -0.0 abs 0.0 fp-bitwise= ] unit-test
{ 1.5 } [ -1.5 abs ] unit-test
{ 1.5 } [ 1.5 abs ] unit-test

{ 5.0 } [ 3 5.0 max ] unit-test
{ 3 } [ 3 5.0 min ] unit-test

{ 39 0x1.999999999998ap-4 } [ 4.0 .1 /mod ] unit-test
{ 38 0x1.9999999999984p-4 } [ 3.9 .1 /mod ] unit-test
{ -39 0x1.999999999998ap-4 } [ 4.0 -.1 /mod ] unit-test
{ -38 0x1.9999999999984p-4 } [ 3.9 -.1 /mod ] unit-test
{ 39 -0x1.999999999998ap-4 } [ -4.0 -.1 /mod ] unit-test
{ 38 -0x1.9999999999984p-4 } [ -3.9 -.1 /mod ] unit-test
{ -39 -0x1.999999999998ap-4 } [ -4.0 .1 /mod ] unit-test
{ -38 -0x1.9999999999984p-4 } [ -3.9 .1 /mod ] unit-test

{ 0.5 } [ 3.5 0.75 mod ] unit-test
{ -0.5 } [ -3.5 0.75 mod ] unit-test
{ -0.5 } [ -3.5 -0.75 mod ] unit-test
{ 0.5 } [ 3.5 -0.75 mod ] unit-test

{ 4 0.5 } [ 3.5 0.75 /mod ] unit-test
{ -4 -0.5 } [ -3.5 0.75 /mod ] unit-test
{ 4 -0.5 } [ -3.5 -0.75 /mod ] unit-test
{ -4 0.5 } [ 3.5 -0.75 /mod ] unit-test
