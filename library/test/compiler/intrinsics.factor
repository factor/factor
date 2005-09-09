IN: temporary
USING: compiler kernel kernel-internals lists math
math-internals test words ;

! Make sure that intrinsic ops compile to correct code.
[ 1 ] [ [[ 1 2 ]] [ 0 slot ] compile-1 ] unit-test
[ 1 ] [ [ [[ 1 2 ]] 0 slot ] compile-1 ] unit-test
[ 3 ] [ 3 1 2 cons [ [ 0 set-slot ] keep ] compile-1 car ] unit-test
[ 3 ] [ 3 1 2 [ cons [ 0 set-slot ] keep ] compile-1 car ] unit-test
[ 3 ] [ [ 3 1 2 cons [ 0 set-slot ] keep ] compile-1 car ] unit-test
[ 3 ] [ 3 1 2 cons [ [ 1 set-slot ] keep ] compile-1 cdr ] unit-test
[ 3 ] [ 3 1 2 [ cons [ 1 set-slot ] keep ] compile-1 cdr ] unit-test
[ 3 ] [ [ 3 1 2 cons [ 1 set-slot ] keep ] compile-1 cdr ] unit-test

! Write barrier hits on the wrong value were causing segfaults
[ -3 ] [ -3 1 2 [ cons [ 1 set-slot ] keep ] compile-1 cdr ] unit-test

[ ] [ 1 [ drop ] compile-1 ] unit-test
[ ] [ [ 1 drop ] compile-1 ] unit-test
[ ] [ [ 1 2 2drop ] compile-1 ] unit-test
[ ] [ 1 [ 2 2drop ] compile-1 ] unit-test
[ ] [ 1 2 [ 2drop ] compile-1 ] unit-test
[ 2 1 ] [ [ 1 2 swap ] compile-1 ] unit-test
[ 2 1 ] [ 1 [ 2 swap ] compile-1 ] unit-test
[ 2 1 ] [ 1 2 [ swap ] compile-1 ] unit-test
[ 1 1 ] [ 1 [ dup ] compile-1 ] unit-test
[ 1 1 ] [ [ 1 dup ] compile-1 ] unit-test
[ 1 2 1 ] [ [ 1 2 over ] compile-1 ] unit-test
[ 1 2 1 ] [ 1 [ 2 over ] compile-1 ] unit-test
[ 1 2 1 ] [ 1 2 [ over ] compile-1 ] unit-test
[ 1 2 3 1 ] [ [ 1 2 3 pick ] compile-1 ] unit-test
[ 1 2 3 1 ] [ 1 [ 2 3 pick ] compile-1 ] unit-test
[ 1 2 3 1 ] [ 1 2 [ 3 pick ] compile-1 ] unit-test
[ 1 2 3 1 ] [ 1 2 3 [ pick ] compile-1 ] unit-test
[ 1 1 2 ] [ [ 1 2 dupd ] compile-1 ] unit-test
[ 1 1 2 ] [ 1 [ 2 dupd ] compile-1 ] unit-test
[ 1 1 2 ] [ 1 2 [ dupd ] compile-1 ] unit-test
[ 2 ] [ [ 1 2 nip ] compile-1 ] unit-test
[ 2 ] [ 1 [ 2 nip ] compile-1 ] unit-test
[ 2 ] [ 1 2 [ nip ] compile-1 ] unit-test

[ 4 ] [ 12 7 [ fixnum-bitand ] compile-1 ] unit-test
[ 4 ] [ 12 [ 7 fixnum-bitand ] compile-1 ] unit-test
[ 4 ] [ [ 12 7 fixnum-bitand ] compile-1 ] unit-test

[ 15 ] [ 12 7 [ fixnum-bitor ] compile-1 ] unit-test
[ 15 ] [ 12 [ 7 fixnum-bitor ] compile-1 ] unit-test
[ 15 ] [ [ 12 7 fixnum-bitor ] compile-1 ] unit-test

[ 11 ] [ 12 7 [ fixnum-bitxor ] compile-1 ] unit-test
[ 11 ] [ 12 [ 7 fixnum-bitxor ] compile-1 ] unit-test
[ 11 ] [ [ 12 7 fixnum-bitxor ] compile-1 ] unit-test

[ f ] [ 12 7 [ fixnum< ] compile-1 ] unit-test
[ f ] [ 12 [ 7 fixnum< ] compile-1 ] unit-test
[ f ] [ [ 12 7 fixnum< ] compile-1 ] unit-test
[ f ] [ [ 12 12 fixnum< ] compile-1 ] unit-test

[ t ] [ 12 70 [ fixnum< ] compile-1 ] unit-test
[ t ] [ 12 [ 70 fixnum< ] compile-1 ] unit-test
[ t ] [ [ 12 70 fixnum< ] compile-1 ] unit-test

[ f ] [ 12 7 [ fixnum<= ] compile-1 ] unit-test
[ f ] [ 12 [ 7 fixnum<= ] compile-1 ] unit-test
[ f ] [ [ 12 7 fixnum<= ] compile-1 ] unit-test
[ t ] [ [ 12 12 fixnum<= ] compile-1 ] unit-test

[ t ] [ 12 70 [ fixnum<= ] compile-1 ] unit-test
[ t ] [ 12 [ 70 fixnum<= ] compile-1 ] unit-test
[ t ] [ [ 12 70 fixnum<= ] compile-1 ] unit-test

[ t ] [ 12 7 [ fixnum> ] compile-1 ] unit-test
[ t ] [ 12 [ 7 fixnum> ] compile-1 ] unit-test
[ t ] [ [ 12 7 fixnum> ] compile-1 ] unit-test
[ f ] [ [ 12 12 fixnum> ] compile-1 ] unit-test

[ f ] [ 12 70 [ fixnum> ] compile-1 ] unit-test
[ f ] [ 12 [ 70 fixnum> ] compile-1 ] unit-test
[ f ] [ [ 12 70 fixnum> ] compile-1 ] unit-test

[ t ] [ 12 7 [ fixnum>= ] compile-1 ] unit-test
[ t ] [ 12 [ 7 fixnum>= ] compile-1 ] unit-test
[ t ] [ [ 12 7 fixnum>= ] compile-1 ] unit-test
[ t ] [ [ 12 12 fixnum>= ] compile-1 ] unit-test

[ f ] [ 12 70 [ fixnum>= ] compile-1 ] unit-test
[ f ] [ 12 [ 70 fixnum>= ] compile-1 ] unit-test
[ f ] [ [ 12 70 fixnum>= ] compile-1 ] unit-test

[ f ] [ 1 2 [ eq? ] compile-1 ] unit-test
[ f ] [ 1 [ 2 eq? ] compile-1 ] unit-test
[ f ] [ [ 1 2 eq? ] compile-1 ] unit-test
[ t ] [ 3 3 [ eq? ] compile-1 ] unit-test
[ t ] [ 3 [ 3 eq? ] compile-1 ] unit-test
[ t ] [ [ 3 3 eq? ] compile-1 ] unit-test

[ -1 ] [ 0 [ fixnum-bitnot ] compile-1 ] unit-test
[ -1 ] [ [ 0 fixnum-bitnot ] compile-1 ] unit-test

[ 3 ] [ 13 10 [ fixnum-mod ] compile-1 ] unit-test
[ 3 ] [ 13 [ 10 fixnum-mod ] compile-1 ] unit-test
[ 3 ] [ [ 13 10 fixnum-mod ] compile-1 ] unit-test
[ -3 ] [ -13 10 [ fixnum-mod ] compile-1 ] unit-test
[ -3 ] [ -13 [ 10 fixnum-mod ] compile-1 ] unit-test
[ -3 ] [ [ -13 10 fixnum-mod ] compile-1 ] unit-test

[ 2 ] [ 4 2 [ fixnum/i ] compile-1 ] unit-test
[ 2 ] [ 4 [ 2 fixnum/i ] compile-1 ] unit-test
[ -2 ] [ 4 [ -2 fixnum/i ] compile-1 ] unit-test
[ 3 1 ] [ 10 3 [ fixnum/mod ] compile-1 ] unit-test

[ 4 ] [ 1 3 [ fixnum+ ] compile-1 ] unit-test
[ 4 ] [ 1 [ 3 fixnum+ ] compile-1 ] unit-test
[ 4 ] [ [ 1 3 fixnum+ ] compile-1 ] unit-test

[ 6 ] [ 2 3 [ fixnum* ] compile-1 ] unit-test
[ 6 ] [ 2 [ 3 fixnum* ] compile-1 ] unit-test
[ 6 ] [ [ 2 3 fixnum* ] compile-1 ] unit-test
[ -6 ] [ 2 -3 [ fixnum* ] compile-1 ] unit-test
[ -6 ] [ 2 [ -3 fixnum* ] compile-1 ] unit-test
[ -6 ] [ [ 2 -3 fixnum* ] compile-1 ] unit-test

[ t ] [ 3 type 3 [ type ] compile-1 eq? ] unit-test
[ t ] [ 3 >bignum type 3 >bignum [ type ] compile-1 eq? ] unit-test
[ t ] [ "hey" type "hey" [ type ] compile-1 eq? ] unit-test
[ t ] [ f type f [ type ] compile-1 eq? ] unit-test

[ 5 ] [ 1 2 [ eq? [ 3 ] [ 5 ] ifte ] compile-1 ] unit-test
[ 3 ] [ 2 2 [ eq? [ 3 ] [ 5 ] ifte ] compile-1 ] unit-test
[ 3 ] [ 1 2 [ fixnum< [ 3 ] [ 5 ] ifte ] compile-1 ] unit-test
[ 5 ] [ 2 2 [ fixnum< [ 3 ] [ 5 ] ifte ] compile-1 ] unit-test

[ 8 ] [ 1 3 [ fixnum-shift ] compile-1 ] unit-test
[ 8 ] [ 1 [ 3 fixnum-shift ] compile-1 ] unit-test
[ 8 ] [ [ 1 3 fixnum-shift ] compile-1 ] unit-test
[ -8 ] [ -1 3 [ fixnum-shift ] compile-1 ] unit-test
[ -8 ] [ -1 [ 3 fixnum-shift ] compile-1 ] unit-test
[ -8 ] [ [ -1 3 fixnum-shift ] compile-1 ] unit-test

[ 2 ] [ 8 -2 [ fixnum-shift ] compile-1 ] unit-test
[ 2 ] [ 8 [ -2 fixnum-shift ] compile-1 ] unit-test

[ 0 ] [ [ 123 -64 fixnum-shift ] compile-1 ] unit-test
[ 0 ] [ 123 -64 [ fixnum-shift ] compile-1 ] unit-test
[ -1 ] [ [ -123 -64 fixnum-shift ] compile-1 ] unit-test
[ -1 ] [ -123 -64 [ fixnum-shift ] compile-1 ] unit-test

[ HEX: 10000000 ] [ HEX: -10000000 >fixnum [ 0 swap fixnum- ] compile-1 ] unit-test
[ HEX: 10000000 ] [ HEX: -fffffff >fixnum [ 1 swap fixnum- ] compile-1 ] unit-test

[ t ] [ 1 27 fixnum-shift dup [ fixnum+ ] compile-1 1 28 fixnum-shift = ] unit-test
[ -268435457 ] [ 1 28 shift neg >fixnum [ -1 fixnum+ ] compile-1 ] unit-test

[ 4294967296 ] [ 1 32 [ fixnum-shift ] compile-1 ] unit-test
[ 4294967296 ] [ 1 [ 32 fixnum-shift ] compile-1 ] unit-test
[ 4294967296 ] [ 1 [ 16 fixnum-shift 16 fixnum-shift ] compile-1 ] unit-test
[ -4294967296 ] [ -1 32 [ fixnum-shift ] compile-1 ] unit-test
[ -4294967296 ] [ -1 [ 32 fixnum-shift ] compile-1 ] unit-test
[ -4294967296 ] [ -1 [ 16 fixnum-shift 16 fixnum-shift ] compile-1 ] unit-test

[ t ] [ 1 20 shift 1 20 shift [ fixnum* ] compile-1 1 40 shift = ] unit-test
[ t ] [ 1 20 shift neg 1 20 shift [ fixnum* ] compile-1 1 40 shift neg = ] unit-test
[ t ] [ 1 20 shift neg 1 20 shift neg [ fixnum* ] compile-1 1 40 shift = ] unit-test

[ 268435456 ] [ -268435456 >fixnum -1 [ fixnum/i ] compile-1 ] unit-test

[ 268435456 0 ] [ -268435456 >fixnum -1 [ fixnum/mod ] compile-1 ] unit-test

[ t ] [ f [ f eq? ] compile-1 ] unit-test

! regression
[ t ] [ { 1 2 3 } { 1 2 3 } [ over type over type eq? ] compile-1 2nip ] unit-test

! regression
: blah over cons? [ "x" get >r 2cdr r> ] [ 2drop f f f ] ifte ; compiled

[ f ] [ f "x" set [ 1 2 3 ] [ 1 3 2 ] blah drop 2car = ] unit-test
