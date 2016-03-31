USING: kernel layouts make math math.private tools.test ;
IN: math.tests

{ } [ 5 [ ] times ] unit-test
{ } [ 0 [ ] times ] unit-test
{ } [ -1 [ ] times ] unit-test

{ } [ 5 [ drop ] each-integer ] unit-test
{ [ 0 1 2 3 4 ] } [ [ 5 [ , ] each-integer ] [ ] make ] unit-test
{ [ ] } [ [ -1 [ , ] each-integer ] [ ] make ] unit-test

{ f } [ 1/0. fp-nan? ] unit-test
{ f } [ -1/0. fp-nan? ] unit-test
{ t } [ -0/0. fp-nan? ] unit-test
{ t } [ 1 <fp-nan> fp-nan? ] unit-test
! [ t ] [ 1 <fp-nan> fp-snan? ] unit-test
! [ f ] [ 1 <fp-nan> fp-qnan? ] unit-test
{ t } [ 0x8000000000001 <fp-nan> fp-nan? ] unit-test
{ f } [ 0x8000000000001 <fp-nan> fp-snan? ] unit-test
{ t } [ 0x8000000000001 <fp-nan> fp-qnan? ] unit-test

{ t } [ 1/0. fp-infinity? ] unit-test
{ t } [ -1/0. fp-infinity? ] unit-test
{ f } [ -0/0. fp-infinity? ] unit-test

{ f } [ 0 <fp-nan> fp-nan? ] unit-test
{ t } [ 0 <fp-nan> fp-infinity? ] unit-test

{ t } [  0.0 neg -0.0 fp-bitwise= ] unit-test
{ t } [ -0.0 neg  0.0 fp-bitwise= ] unit-test

{ 0.0 } [ -0.0 next-float ] unit-test
{ t } [ 1.0 dup next-float < ] unit-test
{ t } [ -1.0 dup next-float < ] unit-test

{ -0.0 } [ 0.0 prev-float ] unit-test
{ t } [ 1.0 dup prev-float > ] unit-test
{ t } [ -1.0 dup prev-float > ] unit-test

{ f } [ 0/0.  0/0. = ] unit-test
{ f } [ 0/0.  1.0  = ] unit-test
{ f } [ 0/0.  1/0. = ] unit-test
{ f } [ 0/0. -1/0. = ] unit-test

{ f } [  0/0. 0/0. = ] unit-test
{ f } [  1.0  0/0. = ] unit-test
{ f } [ -1/0. 0/0. = ] unit-test
{ f } [  1/0. 0/0. = ] unit-test

{ f } [ 0/0.  0/0. < ] unit-test
{ f } [ 0/0.  1.0  < ] unit-test
{ f } [ 0/0.  1/0. < ] unit-test
{ f } [ 0/0. -1/0. < ] unit-test

{ f } [ 0/0.  0/0. <= ] unit-test
{ f } [ 0/0.  1.0  <= ] unit-test
{ f } [ 0/0.  1/0. <= ] unit-test
{ f } [ 0/0. -1/0. <= ] unit-test

{ f } [  0/0. 0/0. > ] unit-test
{ f } [  1.0  0/0. > ] unit-test
{ f } [ -1/0. 0/0. > ] unit-test
{ f } [  1/0. 0/0. > ] unit-test

{ f } [  0/0. 0/0. >= ] unit-test
{ f } [  1.0  0/0. >= ] unit-test
{ f } [ -1/0. 0/0. >= ] unit-test
{ f } [  1/0. 0/0. >= ] unit-test

{ f } [ 0 neg? ] unit-test
{ f } [ 1/2 neg? ] unit-test
{ f } [ 1 neg? ] unit-test
{ t } [ -1/2 neg? ] unit-test
{ t } [ -1 neg? ] unit-test

{ f } [ 0.0 neg? ] unit-test
{ f } [ 1.0 neg? ] unit-test
{ f } [ 1/0. neg? ] unit-test
{ t } [ -0.0 neg? ] unit-test
{ t } [ -1.0 neg? ] unit-test
{ t } [ -1/0. neg? ] unit-test

{ -0x3fffffff } [ 0x3ffffffe >bignum bitnot ] unit-test
{ -0x40000000 } [ 0x3fffffff >bignum bitnot ] unit-test
{ -0x40000001 } [ 0x40000000 >bignum bitnot ] unit-test
{ -0x3fffffffffffffff } [ 0x3ffffffffffffffe >bignum bitnot ] unit-test
{ -0x4000000000000000 } [ 0x3fffffffffffffff >bignum bitnot ] unit-test
{ -0x4000000000000001 } [ 0x4000000000000000 >bignum bitnot ] unit-test

{ 2 } [ 0 next-power-of-2 ] unit-test
{ 2 } [ 1 next-power-of-2 ] unit-test
{ 2 } [ 2 next-power-of-2 ] unit-test
{ 4 } [ 3 next-power-of-2 ] unit-test
{ 4 } [ 4 next-power-of-2 ] unit-test
{ 8 } [ 5 next-power-of-2 ] unit-test

{ t } [ 128 2^ sq 256 2^ = ] unit-test
{ t } [ 128 2^ neg sq 256 2^ = ] unit-test

{ t } [ most-negative-fixnum dup >bignum bignum>fixnum-strict = ] unit-test

{ 100 } [ 100 100 gcd nip ] unit-test
{ 100 } [ 1000 100 gcd nip ] unit-test
{ 100 } [ 100 1000 gcd nip ] unit-test
{ 4 } [ 132 64 gcd nip ] unit-test
{ 4 } [ -132 64 gcd nip ] unit-test
{ 4 } [ -132 -64 gcd nip ] unit-test
{ 4 } [ 132 -64 gcd nip ] unit-test
{ 4 } [ -132 -64 gcd nip ] unit-test

{ 100 } [ 100 >bignum 100 >bignum gcd nip ] unit-test
{ 100 } [ 1000 >bignum 100 >bignum gcd nip ] unit-test
{ 100 } [ 100 >bignum 1000 >bignum gcd nip ] unit-test
{ 4 } [ 132 >bignum 64 >bignum gcd nip ] unit-test
{ 4 } [ -132 >bignum 64 >bignum gcd nip ] unit-test
{ 4 } [ -132 >bignum -64 >bignum gcd nip ] unit-test
{ 4 } [ 132 >bignum -64 >bignum gcd nip ] unit-test
{ 4 } [ -132 >bignum -64 >bignum gcd nip ] unit-test

{ 6 } [
    1326264299060955293181542400000006
    1591517158873146351817850880000000
    gcd nip
] unit-test

{ 11 } [
    13262642990609552931815424
    159151715887314635181785
    gcd nip
] unit-test

{ 3 } [
    13262642990609552931
    1591517158873146351
    gcd nip
] unit-test

{ 26525285981219 } [
    132626429906095
    159151715887314
    gcd nip
] unit-test


: verify-gcd ( a b -- ? )
    2dup gcd
    [ rot * swap rem ] dip = ;

{ t } [ 123 124 verify-gcd ] unit-test
{ t } [ 50 120 verify-gcd ] unit-test
