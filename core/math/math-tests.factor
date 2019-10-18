USING: kernel math namespaces make tools.test ;
IN: math.tests

[ ] [ 5 [ ] times ] unit-test
[ ] [ 0 [ ] times ] unit-test
[ ] [ -1 [ ] times ] unit-test

[ ] [ 5 [ drop ] each-integer ] unit-test
[ [ 0 1 2 3 4 ] ] [ [ 5 [ , ] each-integer ] [ ] make ] unit-test
[ [ ] ] [ [ -1 [ , ] each-integer ] [ ] make ] unit-test

[ f ] [ 1/0. fp-nan? ] unit-test
[ f ] [ -1/0. fp-nan? ] unit-test
[ t ] [ -0/0. fp-nan? ] unit-test
[ t ] [ 1 <fp-nan> fp-nan? ] unit-test
! [ t ] [ 1 <fp-nan> fp-snan? ] unit-test
! [ f ] [ 1 <fp-nan> fp-qnan? ] unit-test
[ t ] [ 0x8000000000001 <fp-nan> fp-nan? ] unit-test
[ f ] [ 0x8000000000001 <fp-nan> fp-snan? ] unit-test
[ t ] [ 0x8000000000001 <fp-nan> fp-qnan? ] unit-test

[ t ] [ 1/0. fp-infinity? ] unit-test
[ t ] [ -1/0. fp-infinity? ] unit-test
[ f ] [ -0/0. fp-infinity? ] unit-test

[ f ] [ 0 <fp-nan> fp-nan? ] unit-test
[ t ] [ 0 <fp-nan> fp-infinity? ] unit-test

[ t ] [  0.0 neg -0.0 fp-bitwise= ] unit-test
[ t ] [ -0.0 neg  0.0 fp-bitwise= ] unit-test

[ 0.0 ] [ -0.0 next-float ] unit-test
[ t ] [ 1.0 dup next-float < ] unit-test
[ t ] [ -1.0 dup next-float < ] unit-test

[ -0.0 ] [ 0.0 prev-float ] unit-test
[ t ] [ 1.0 dup prev-float > ] unit-test
[ t ] [ -1.0 dup prev-float > ] unit-test

[ f ] [ 0/0.  0/0. = ] unit-test
[ f ] [ 0/0.  1.0  = ] unit-test
[ f ] [ 0/0.  1/0. = ] unit-test
[ f ] [ 0/0. -1/0. = ] unit-test

[ f ] [  0/0. 0/0. = ] unit-test
[ f ] [  1.0  0/0. = ] unit-test
[ f ] [ -1/0. 0/0. = ] unit-test
[ f ] [  1/0. 0/0. = ] unit-test

[ f ] [ 0/0.  0/0. < ] unit-test
[ f ] [ 0/0.  1.0  < ] unit-test
[ f ] [ 0/0.  1/0. < ] unit-test
[ f ] [ 0/0. -1/0. < ] unit-test

[ f ] [ 0/0.  0/0. <= ] unit-test
[ f ] [ 0/0.  1.0  <= ] unit-test
[ f ] [ 0/0.  1/0. <= ] unit-test
[ f ] [ 0/0. -1/0. <= ] unit-test

[ f ] [  0/0. 0/0. > ] unit-test
[ f ] [  1.0  0/0. > ] unit-test
[ f ] [ -1/0. 0/0. > ] unit-test
[ f ] [  1/0. 0/0. > ] unit-test

[ f ] [  0/0. 0/0. >= ] unit-test
[ f ] [  1.0  0/0. >= ] unit-test
[ f ] [ -1/0. 0/0. >= ] unit-test
[ f ] [  1/0. 0/0. >= ] unit-test

[ f ] [ 0 neg? ] unit-test
[ f ] [ 1/2 neg? ] unit-test
[ f ] [ 1 neg? ] unit-test
[ t ] [ -1/2 neg? ] unit-test
[ t ] [ -1 neg? ] unit-test

[ f ] [ 0.0 neg? ] unit-test
[ f ] [ 1.0 neg? ] unit-test
[ f ] [ 1/0. neg? ] unit-test
[ t ] [ -0.0 neg? ] unit-test
[ t ] [ -1.0 neg? ] unit-test
[ t ] [ -1/0. neg? ] unit-test

{ -0x3fffffff } [ 0x3ffffffe >bignum bitnot ] unit-test
{ -0x40000000 } [ 0x3fffffff >bignum bitnot ] unit-test
{ -0x40000001 } [ 0x40000000 >bignum bitnot ] unit-test
{ -0x3fffffffffffffff } [ 0x3ffffffffffffffe >bignum bitnot ] unit-test
{ -0x4000000000000000 } [ 0x3fffffffffffffff >bignum bitnot ] unit-test
{ -0x4000000000000001 } [ 0x4000000000000000 >bignum bitnot ] unit-test
