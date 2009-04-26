USING: accessors arrays compiler.units kernel kernel.private math
math.constants math.private sequences strings tools.test words
continuations sequences.private hashtables.private byte-arrays
strings.private system random layouts vectors
sbufs strings.private slots.private alien math.order
alien.accessors alien.c-types alien.syntax alien.strings
namespaces libc sequences.private io.encodings.ascii
classes compiler ;
IN: compiler.tests.intrinsics

! Make sure that intrinsic ops compile to correct code.
[ ] [ 1 [ drop ] compile-call ] unit-test
[ ] [ 1 2 [ 2drop ] compile-call ] unit-test
[ ] [ 1 2 3 [ 3drop ] compile-call ] unit-test
[ 1 1 ] [ 1 [ dup ] compile-call ] unit-test
[ 1 2 1 2 ] [ 1 2 [ 2dup ] compile-call ] unit-test
[ 1 2 3 1 2 3 ] [ 1 2 3 [ 3dup ] compile-call ] unit-test
[ 2 3 1 ] [ 1 2 3 [ rot ] compile-call ] unit-test
[ 3 1 2 ] [ 1 2 3 [ -rot ] compile-call ] unit-test
[ 1 1 2 ] [ 1 2 [ dupd ] compile-call ] unit-test
[ 2 1 3 ] [ 1 2 3 [ swapd ] compile-call ] unit-test
[ 2 ] [ 1 2 [ nip ] compile-call ] unit-test
[ 3 ] [ 1 2 3 [ 2nip ] compile-call ] unit-test
[ 2 1 2 ] [ 1 2 [ tuck ] compile-call ] unit-test
[ 1 2 1 ] [ 1 2 [ over ] compile-call ] unit-test
[ 1 2 3 1 ] [ 1 2 3 [ pick ] compile-call ] unit-test
[ 2 1 ] [ 1 2 [ swap ] compile-call ] unit-test

[ 1 ] [ { 1 2 } [ 2 slot ] compile-call ] unit-test
[ 1 ] [ [ { 1 2 } 2 slot ] compile-call ] unit-test

[ { f f } ] [ 2 f <array> ] unit-test

[ 3 ] [ 3 1 2 2array [ { array } declare [ 2 set-slot ] keep ] compile-call first ] unit-test
[ 3 ] [ 3 1 2 [ 2array [ 2 set-slot ] keep ] compile-call first ] unit-test
[ 3 ] [ [ 3 1 2 2array [ 2 set-slot ] keep ] compile-call first ] unit-test
[ 3 ] [ 3 1 2 2array [ [ 3 set-slot ] keep ] compile-call second ] unit-test
[ 3 ] [ 3 1 2 [ 2array [ 3 set-slot ] keep ] compile-call second ] unit-test
[ 3 ] [ [ 3 1 2 2array [ 3 set-slot ] keep ] compile-call second ] unit-test

! Write barrier hits on the wrong value were causing segfaults
[ -3 ] [ -3 1 2 [ 2array [ 3 set-slot ] keep ] compile-call second ] unit-test

[ CHAR: a ] [ 0 "abc" [ string-nth ] compile-call ] unit-test
[ CHAR: a ] [ 0 [ "abc" string-nth ] compile-call ] unit-test
[ CHAR: a ] [ [ 0 "abc" string-nth ] compile-call ] unit-test
[ CHAR: b ] [ 1 "abc" [ string-nth ] compile-call ] unit-test
[ CHAR: b ] [ 1 [ "abc" string-nth ] compile-call ] unit-test
[ CHAR: b ] [ [ 1 "abc" string-nth ] compile-call ] unit-test

[ HEX: 123456 ] [ 0 "\u123456bc" [ string-nth ] compile-call ] unit-test
[ HEX: 123456 ] [ 0 [ "\u123456bc" string-nth ] compile-call ] unit-test
[ HEX: 123456 ] [ [ 0 "\u123456bc" string-nth ] compile-call ] unit-test
[ HEX: 123456 ] [ 1 "a\u123456c" [ string-nth ] compile-call ] unit-test
[ HEX: 123456 ] [ 1 [ "a\u123456c" string-nth ] compile-call ] unit-test
[ HEX: 123456 ] [ [ 1 "a\u123456c" string-nth ] compile-call ] unit-test

[ ] [ [ 0 getenv ] compile-call drop ] unit-test
[ ] [ 1 getenv [ 1 setenv ] compile-call ] unit-test

[ ] [ 1 [ drop ] compile-call ] unit-test
[ ] [ [ 1 drop ] compile-call ] unit-test
[ ] [ [ 1 2 2drop ] compile-call ] unit-test
[ ] [ 1 [ 2 2drop ] compile-call ] unit-test
[ ] [ 1 2 [ 2drop ] compile-call ] unit-test
[ 2 1 ] [ [ 1 2 swap ] compile-call ] unit-test
[ 2 1 ] [ 1 [ 2 swap ] compile-call ] unit-test
[ 2 1 ] [ 1 2 [ swap ] compile-call ] unit-test
[ 1 1 ] [ 1 [ dup ] compile-call ] unit-test
[ 1 1 ] [ [ 1 dup ] compile-call ] unit-test
[ 1 2 1 ] [ [ 1 2 over ] compile-call ] unit-test
[ 1 2 1 ] [ 1 [ 2 over ] compile-call ] unit-test
[ 1 2 1 ] [ 1 2 [ over ] compile-call ] unit-test
[ 1 2 3 1 ] [ [ 1 2 3 pick ] compile-call ] unit-test
[ 1 2 3 1 ] [ 1 [ 2 3 pick ] compile-call ] unit-test
[ 1 2 3 1 ] [ 1 2 [ 3 pick ] compile-call ] unit-test
[ 1 2 3 1 ] [ 1 2 3 [ pick ] compile-call ] unit-test
[ 1 1 2 ] [ [ 1 2 dupd ] compile-call ] unit-test
[ 1 1 2 ] [ 1 [ 2 dupd ] compile-call ] unit-test
[ 1 1 2 ] [ 1 2 [ dupd ] compile-call ] unit-test
[ 2 ] [ [ 1 2 nip ] compile-call ] unit-test
[ 2 ] [ 1 [ 2 nip ] compile-call ] unit-test
[ 2 ] [ 1 2 [ nip ] compile-call ] unit-test

[ 2 1 "hi" ] [ 1 2 [ swap "hi" ] compile-call ] unit-test

[ 4 ] [ 12 7 [ fixnum-bitand ] compile-call ] unit-test
[ 4 ] [ 12 [ 7 fixnum-bitand ] compile-call ] unit-test
[ 4 ] [ [ 12 7 fixnum-bitand ] compile-call ] unit-test

[ 15 ] [ 12 7 [ fixnum-bitor ] compile-call ] unit-test
[ 15 ] [ 12 [ 7 fixnum-bitor ] compile-call ] unit-test
[ 15 ] [ [ 12 7 fixnum-bitor ] compile-call ] unit-test

[ 11 ] [ 12 7 [ fixnum-bitxor ] compile-call ] unit-test
[ 11 ] [ 12 [ 7 fixnum-bitxor ] compile-call ] unit-test
[ 11 ] [ [ 12 7 fixnum-bitxor ] compile-call ] unit-test

[ f ] [ 12 7 [ fixnum< [ t ] [ f ] if ] compile-call ] unit-test
[ f ] [ 12 [ 7 fixnum< [ t ] [ f ] if ] compile-call ] unit-test
[ f ] [ [ 12 7 fixnum< [ t ] [ f ] if ] compile-call ] unit-test
[ f ] [ [ 12 12 fixnum< [ t ] [ f ] if ] compile-call ] unit-test
[ f ] [ 12 12 [ fixnum< [ t ] [ f ] if ] compile-call ] unit-test

[ t ] [ 12 70 [ fixnum< [ t ] [ f ] if ] compile-call ] unit-test
[ t ] [ 12 [ 70 fixnum< [ t ] [ f ] if ] compile-call ] unit-test
[ t ] [ [ 12 70 fixnum< [ t ] [ f ] if ] compile-call ] unit-test

[ f ] [ 12 7 [ fixnum<= [ t ] [ f ] if ] compile-call ] unit-test
[ f ] [ 12 [ 7 fixnum<= [ t ] [ f ] if ] compile-call ] unit-test
[ f ] [ [ 12 7 fixnum<= [ t ] [ f ] if ] compile-call ] unit-test
[ t ] [ [ 12 12 fixnum<= [ t ] [ f ] if ] compile-call ] unit-test
[ t ] [ [ 12 12 fixnum<= [ t ] [ f ] if ] compile-call ] unit-test
[ t ] [ 12 12 [ fixnum<= [ t ] [ f ] if ] compile-call ] unit-test

[ t ] [ 12 70 [ fixnum<= [ t ] [ f ] if ] compile-call ] unit-test
[ t ] [ 12 [ 70 fixnum<= [ t ] [ f ] if ] compile-call ] unit-test
[ t ] [ [ 12 70 fixnum<= [ t ] [ f ] if ] compile-call ] unit-test

[ t ] [ 12 7 [ fixnum> [ t ] [ f ] if ] compile-call ] unit-test
[ t ] [ 12 [ 7 fixnum> [ t ] [ f ] if ] compile-call ] unit-test
[ t ] [ [ 12 7 fixnum> [ t ] [ f ] if ] compile-call ] unit-test
[ f ] [ [ 12 12 fixnum> [ t ] [ f ] if ] compile-call ] unit-test
[ f ] [ [ 12 12 fixnum> [ t ] [ f ] if ] compile-call ] unit-test
[ f ] [ 12 12 [ fixnum> [ t ] [ f ] if ] compile-call ] unit-test

[ f ] [ 12 70 [ fixnum> [ t ] [ f ] if ] compile-call ] unit-test
[ f ] [ 12 [ 70 fixnum> [ t ] [ f ] if ] compile-call ] unit-test
[ f ] [ [ 12 70 fixnum> [ t ] [ f ] if ] compile-call ] unit-test

[ t ] [ 12 7 [ fixnum>= [ t ] [ f ] if ] compile-call ] unit-test
[ t ] [ 12 [ 7 fixnum>= [ t ] [ f ] if ] compile-call ] unit-test
[ t ] [ [ 12 7 fixnum>= [ t ] [ f ] if ] compile-call ] unit-test
[ t ] [ [ 12 12 fixnum>= [ t ] [ f ] if ] compile-call ] unit-test
[ t ] [ 12 12 [ fixnum>= [ t ] [ f ] if ] compile-call ] unit-test

[ f ] [ 12 70 [ fixnum>= [ t ] [ f ] if ] compile-call ] unit-test
[ f ] [ 12 [ 70 fixnum>= [ t ] [ f ] if ] compile-call ] unit-test
[ f ] [ [ 12 70 fixnum>= [ t ] [ f ] if ] compile-call ] unit-test

[ f ] [ 1 2 [ eq? [ t ] [ f ] if ] compile-call ] unit-test
[ f ] [ 1 [ 2 eq? [ t ] [ f ] if ] compile-call ] unit-test
[ f ] [ [ 1 2 eq? [ t ] [ f ] if ] compile-call ] unit-test
[ t ] [ 3 3 [ eq? [ t ] [ f ] if ] compile-call ] unit-test
[ t ] [ 3 [ 3 eq? [ t ] [ f ] if ] compile-call ] unit-test
[ t ] [ [ 3 3 eq? [ t ] [ f ] if ] compile-call ] unit-test

[ -1 ] [ 0 [ fixnum-bitnot ] compile-call ] unit-test
[ -1 ] [ [ 0 fixnum-bitnot ] compile-call ] unit-test

[ 3 ] [ 13 10 [ fixnum-mod ] compile-call ] unit-test
[ 3 ] [ 13 [ 10 fixnum-mod ] compile-call ] unit-test
[ 3 ] [ [ 13 10 fixnum-mod ] compile-call ] unit-test
[ -3 ] [ -13 10 [ fixnum-mod ] compile-call ] unit-test
[ -3 ] [ -13 [ 10 fixnum-mod ] compile-call ] unit-test
[ -3 ] [ [ -13 10 fixnum-mod ] compile-call ] unit-test

[ 2 ] [ 4 2 [ fixnum/i ] compile-call ] unit-test
[ 2 ] [ 4 [ 2 fixnum/i ] compile-call ] unit-test
[ -2 ] [ 4 [ -2 fixnum/i ] compile-call ] unit-test
[ 3 1 ] [ 10 3 [ fixnum/mod ] compile-call ] unit-test

[ 2 ] [ 4 2 [ fixnum/i-fast ] compile-call ] unit-test
[ 2 ] [ 4 [ 2 fixnum/i-fast ] compile-call ] unit-test
[ -2 ] [ 4 [ -2 fixnum/i-fast ] compile-call ] unit-test
[ 3 1 ] [ 10 3 [ fixnum/mod-fast ] compile-call ] unit-test

[ 4 ] [ 1 3 [ fixnum+ ] compile-call ] unit-test
[ 4 ] [ 1 [ 3 fixnum+ ] compile-call ] unit-test
[ 4 ] [ [ 1 3 fixnum+ ] compile-call ] unit-test

[ 4 ] [ 1 3 [ fixnum+fast ] compile-call ] unit-test
[ 4 ] [ 1 [ 3 fixnum+fast ] compile-call ] unit-test
[ 4 ] [ [ 1 3 fixnum+fast ] compile-call ] unit-test

[ -2 ] [ 1 3 [ fixnum-fast ] compile-call ] unit-test
[ -2 ] [ 1 [ 3 fixnum-fast ] compile-call ] unit-test
[ -2 ] [ [ 1 3 fixnum-fast ] compile-call ] unit-test

[ 30001 ] [ 1 [ 30000 fixnum+fast ] compile-call ] unit-test

[ 6 ] [ 2 3 [ fixnum*fast ] compile-call ] unit-test
[ 6 ] [ 2 [ 3 fixnum*fast ] compile-call ] unit-test
[ 6 ] [ [ 2 3 fixnum*fast ] compile-call ] unit-test
[ -6 ] [ 2 -3 [ fixnum*fast ] compile-call ] unit-test
[ -6 ] [ 2 [ -3 fixnum*fast ] compile-call ] unit-test
[ -6 ] [ [ 2 -3 fixnum*fast ] compile-call ] unit-test

[ 6 ] [ 2 3 [ fixnum* ] compile-call ] unit-test
[ 6 ] [ 2 [ 3 fixnum* ] compile-call ] unit-test
[ 6 ] [ [ 2 3 fixnum* ] compile-call ] unit-test
[ -6 ] [ 2 -3 [ fixnum* ] compile-call ] unit-test
[ -6 ] [ 2 [ -3 fixnum* ] compile-call ] unit-test
[ -6 ] [ [ 2 -3 fixnum* ] compile-call ] unit-test

[ 5 ] [ 1 2 [ eq? [ 3 ] [ 5 ] if ] compile-call ] unit-test
[ 3 ] [ 2 2 [ eq? [ 3 ] [ 5 ] if ] compile-call ] unit-test
[ 3 ] [ 1 2 [ fixnum< [ 3 ] [ 5 ] if ] compile-call ] unit-test
[ 5 ] [ 2 2 [ fixnum< [ 3 ] [ 5 ] if ] compile-call ] unit-test

[ 8 ] [ 1 3 [ fixnum-shift ] compile-call ] unit-test
[ 8 ] [ 1 [ 3 fixnum-shift ] compile-call ] unit-test
[ 8 ] [ [ 1 3 fixnum-shift ] compile-call ] unit-test
[ -8 ] [ -1 3 [ fixnum-shift ] compile-call ] unit-test
[ -8 ] [ -1 [ 3 fixnum-shift ] compile-call ] unit-test
[ -8 ] [ [ -1 3 fixnum-shift ] compile-call ] unit-test

[ 2 ] [ 8 -2 [ fixnum-shift ] compile-call ] unit-test
[ 2 ] [ 8 [ -2 fixnum-shift ] compile-call ] unit-test

[ 0 ] [ [ 123 -64 fixnum-shift ] compile-call ] unit-test
[ 0 ] [ 123 -64 [ fixnum-shift ] compile-call ] unit-test
[ -1 ] [ [ -123 -64 fixnum-shift ] compile-call ] unit-test
[ -1 ] [ -123 -64 [ fixnum-shift ] compile-call ] unit-test

[ HEX: 10000000 ] [ HEX: 1000000 HEX: 10 [ fixnum* ] compile-call ] unit-test
[ HEX: 10000000 ] [ HEX: -10000000 >fixnum [ 0 swap fixnum- ] compile-call ] unit-test
[ HEX: 10000000 ] [ HEX: -fffffff >fixnum [ 1 swap fixnum- ] compile-call ] unit-test

[ t ] [ 1 27 fixnum-shift dup [ fixnum+ ] compile-call 1 28 fixnum-shift = ] unit-test
[ -268435457 ] [ 1 28 shift neg >fixnum [ -1 fixnum+ ] compile-call ] unit-test

[ 4294967296 ] [ 1 32 [ fixnum-shift ] compile-call ] unit-test
[ 4294967296 ] [ 1 [ 32 fixnum-shift ] compile-call ] unit-test
[ 4294967296 ] [ 1 [ 16 fixnum-shift 16 fixnum-shift ] compile-call ] unit-test
[ -4294967296 ] [ -1 32 [ fixnum-shift ] compile-call ] unit-test
[ -4294967296 ] [ -1 [ 32 fixnum-shift ] compile-call ] unit-test
[ -4294967296 ] [ -1 [ 16 fixnum-shift 16 fixnum-shift ] compile-call ] unit-test

[ t ] [ 1 20 shift 1 20 shift [ fixnum* ] compile-call 1 40 shift = ] unit-test
[ t ] [ 1 20 shift neg 1 20 shift [ fixnum* ] compile-call 1 40 shift neg = ] unit-test
[ t ] [ 1 20 shift neg 1 20 shift neg [ fixnum* ] compile-call 1 40 shift = ] unit-test
[ -351382792 ] [ -43922849 [ 3 fixnum-shift ] compile-call ] unit-test

[ 268435456 ] [ -268435456 >fixnum -1 [ fixnum/i ] compile-call ] unit-test

[ 268435456 0 ] [ -268435456 >fixnum -1 [ fixnum/mod ] compile-call ] unit-test

[ t ] [ f [ f eq? ] compile-call ] unit-test

! regression
[ 3 ] [
    100001 f <array> 3 100000 pick set-nth
    [ 100000 swap array-nth ] compile-call
] unit-test

! 64-bit overflow
cell 8 = [
    [ t ] [ 1 59 fixnum-shift dup [ fixnum+ ] compile-call 1 60 fixnum-shift = ] unit-test
    [ -1152921504606846977 ] [ 1 60 shift neg >fixnum [ -1 fixnum+ ] compile-call ] unit-test
    
    [ t ] [ 1 40 shift 1 40 shift [ fixnum* ] compile-call 1 80 shift = ] unit-test
    [ t ] [ 1 40 shift neg 1 40 shift [ fixnum* ] compile-call 1 80 shift neg = ] unit-test
    [ t ] [ 1 40 shift neg 1 40 shift neg [ fixnum* ] compile-call 1 80 shift = ] unit-test
    [ t ] [ 1 30 shift neg 1 50 shift neg [ fixnum* ] compile-call 1 80 shift = ] unit-test
    [ t ] [ 1 50 shift neg 1 30 shift neg [ fixnum* ] compile-call 1 80 shift = ] unit-test

    [ 18446744073709551616 ] [ 1 64 [ fixnum-shift ] compile-call ] unit-test
    [ 18446744073709551616 ] [ 1 [ 64 fixnum-shift ] compile-call ] unit-test
    [ 18446744073709551616 ] [ 1 [ 32 fixnum-shift 32 fixnum-shift ] compile-call ] unit-test
    [ -18446744073709551616 ] [ -1 64 [ fixnum-shift ] compile-call ] unit-test
    [ -18446744073709551616 ] [ -1 [ 64 fixnum-shift ] compile-call ] unit-test
    [ -18446744073709551616 ] [ -1 [ 32 fixnum-shift 32 fixnum-shift ] compile-call ] unit-test
    
    [ 1152921504606846976 ] [ -1152921504606846976 >fixnum -1 [ fixnum/i ] compile-call ] unit-test

    [ 1152921504606846976 0 ] [ -1152921504606846976 >fixnum -1 [ fixnum/mod ] compile-call ] unit-test

    [ -268435457 ] [ 28 2^ [ fixnum-bitnot ] compile-call ] unit-test
] when

! Some randomized tests
: compiled-fixnum* ( a b -- c ) fixnum* ;

[ ] [
    10000 [ 
        32 random-bits >fixnum 32 random-bits >fixnum
        2dup
        [ fixnum* ] 2keep compiled-fixnum* =
        [ 2drop ] [ "Oops" throw ] if
    ] times
] unit-test

: compiled-fixnum>bignum ( a -- b ) fixnum>bignum ;

[ bignum ] [ 0 compiled-fixnum>bignum class ] unit-test

[ ] [
    10000 [
        32 random-bits >fixnum
        dup [ fixnum>bignum ] keep compiled-fixnum>bignum =
        [ drop ] [ "Oops" throw ] if
    ] times
] unit-test

: compiled-bignum>fixnum ( a -- b ) bignum>fixnum ;

[ ] [
    10000 [
        5 random [ drop 32 random-bits ] map product >bignum
        dup [ bignum>fixnum ] keep compiled-bignum>fixnum =
        [ drop ] [ "Oops" throw ] if
    ] times
] unit-test

! Test overflow check removal
[ t ] [
    most-positive-fixnum 100 - >fixnum
    200
    [ [ fixnum+ ] compile-call [ bignum>fixnum ] compile-call ] 2keep
    [ fixnum+ >fixnum ] compile-call
    =
] unit-test

[ t ] [
    most-negative-fixnum 100 + >fixnum
    -200
    [ [ fixnum+ ] compile-call [ bignum>fixnum ] compile-call ] 2keep
    [ fixnum+ >fixnum ] compile-call
    =
] unit-test

[ t ] [
    most-negative-fixnum 100 + >fixnum
    200
    [ [ fixnum- ] compile-call [ bignum>fixnum ] compile-call ] 2keep
    [ fixnum- >fixnum ] compile-call
    =
] unit-test

! Test inline allocators
[ { 1 1 1 } ] [
    [ 3 1 <array> ] compile-call
] unit-test

[ B{ 0 0 0 } ] [
    [ 3 <byte-array> ] compile-call
] unit-test

[ 500 ] [
    [ 500 <byte-array> length ] compile-call
] unit-test

[ 1 2 ] [
    1 2 [ <complex> ] compile-call
    dup real-part swap imaginary-part
] unit-test

[ 1 2 ] [
    1 2 [ <ratio> ] compile-call dup numerator swap denominator
] unit-test

[ \ + ] [ \ + [ <wrapper> ] compile-call ] unit-test

[ B{ 0 0 0 0 0 } ] [
    [ 5 <byte-array> ] compile-call
] unit-test

[ V{ 1 2 } ] [
    { 1 2 3 } 2 [ vector boa ] compile-call
] unit-test

[ SBUF" hello" ] [
    "hello world" 5 [ sbuf boa ] compile-call
] unit-test

[ [ 3 + ] ] [
    3 [ + ] [ curry ] compile-call
] unit-test

! Alien intrinsics
[ 3 ] [ B{ 1 2 3 4 5 } 2 [ alien-unsigned-1 ] compile-call ] unit-test
[ 3 ] [ [ B{ 1 2 3 4 5 } 2 alien-unsigned-1 ] compile-call ] unit-test
[ 3 ] [ B{ 1 2 3 4 5 } 2 [ { byte-array fixnum } declare alien-unsigned-1 ] compile-call ] unit-test
[ 3 ] [ B{ 1 2 3 4 5 } 2 [ { c-ptr fixnum } declare alien-unsigned-1 ] compile-call ] unit-test

[ ] [ B{ 1 2 3 4 5 } malloc-byte-array "b" set ] unit-test
[ t ] [ "b" get >boolean ] unit-test

"b" get [
    [ 3 ] [ "b" get 2 [ alien-unsigned-1 ] compile-call ] unit-test
    [ 3 ] [ "b" get [ { alien } declare 2 alien-unsigned-1 ] compile-call ] unit-test
    [ 3 ] [ "b" get 2 [ { simple-alien fixnum } declare alien-unsigned-1 ] compile-call ] unit-test
    [ 3 ] [ "b" get 2 [ { c-ptr fixnum } declare alien-unsigned-1 ] compile-call ] unit-test

    [ ] [ "b" get free ] unit-test
] when

[ ] [ "hello world" ascii malloc-string "s" set ] unit-test

"s" get [
    [ "hello world" ] [ "s" get <void*> [ { byte-array } declare *void* ] compile-call ascii alien>string ] unit-test
    [ "hello world" ] [ "s" get <void*> [ { c-ptr } declare *void* ] compile-call ascii alien>string ] unit-test

    [ ] [ "s" get free ] unit-test
] when

[ ALIEN: 1234 ] [ ALIEN: 1234 [ { alien } declare <void*> ] compile-call *void* ] unit-test
[ ALIEN: 1234 ] [ ALIEN: 1234 [ { c-ptr } declare <void*> ] compile-call *void* ] unit-test
[ f ] [ f [ { POSTPONE: f } declare <void*> ] compile-call *void* ] unit-test

[ 252 ] [ B{ 1 2 3 -4 5 } 3 [ { byte-array fixnum } declare alien-unsigned-1 ] compile-call ] unit-test
[ -4 ] [ B{ 1 2 3 -4 5 } 3 [ { byte-array fixnum } declare alien-signed-1 ] compile-call ] unit-test

[ -100 ] [ -100 <char> [ { byte-array } declare *char ] compile-call ] unit-test
[ 156 ] [ -100 <uchar> [ { byte-array } declare *uchar ] compile-call ] unit-test

[ -100 ] [ -100 \ <char> def>> [ { fixnum } declare ] prepend compile-call *char ] unit-test
[ 156 ] [ -100 \ <uchar> def>> [ { fixnum } declare ] prepend compile-call *uchar ] unit-test

[ -1000 ] [ -1000 <short> [ { byte-array } declare *short ] compile-call ] unit-test
[ 64536 ] [ -1000 <ushort> [ { byte-array } declare *ushort ] compile-call ] unit-test

[ -1000 ] [ -1000 \ <short> def>> [ { fixnum } declare ] prepend compile-call *short ] unit-test
[ 64536 ] [ -1000 \ <ushort> def>> [ { fixnum } declare ] prepend compile-call *ushort ] unit-test

[ -100000 ] [ -100000 <int> [ { byte-array } declare *int ] compile-call ] unit-test
[ 4294867296 ] [ -100000 <uint> [ { byte-array } declare *uint ] compile-call ] unit-test

[ -100000 ] [ -100000 \ <int> def>> [ { fixnum } declare ] prepend compile-call *int ] unit-test
[ 4294867296 ] [ -100000 \ <uint> def>> [ { fixnum } declare ] prepend compile-call *uint ] unit-test

[ t ] [ pi pi <double> *double = ] unit-test

[ t ] [ pi <double> [ { byte-array } declare *double ] compile-call pi = ] unit-test

! Silly
[ t ] [ pi 4 <byte-array> [ [ { float byte-array } declare 0 set-alien-float ] compile-call ] keep *float pi - -0.001 0.001 between? ] unit-test
[ t ] [ pi <float> [ { byte-array } declare *float ] compile-call pi - -0.001 0.001 between? ] unit-test

[ t ] [ pi 8 <byte-array> [ [ { float byte-array } declare 0 set-alien-double ] compile-call ] keep *double pi = ] unit-test

[ 4 ] [
    2 B{ 1 2 3 4 5 6 } <displaced-alien> [
        { alien } declare 1 alien-unsigned-1
    ] compile-call
] unit-test

[
    B{ 0 0 0 0 } [ { byte-array } declare <void*> ] compile-call
] must-fail

[
    B{ 0 0 0 0 } [ { c-ptr } declare <void*> ] compile-call
] must-fail

[
    4 5
] [
    3 [
        [
            { [ 4444 ] [ 444 ] [ 44 ] [ 4 ] } dispatch
        ] keep 2 fixnum+fast
    ] compile-call
] unit-test

[ 1 ] [
    8 -3 [ fixnum-shift-fast ] compile-call
] unit-test

[ 2 ] [
    16 -3 [ fixnum-shift-fast ] compile-call
] unit-test

[ 2 ] [
    16 [ -3 fixnum-shift-fast ] compile-call
] unit-test

[ 8 ] [
    1 3 [ fixnum-shift-fast ] compile-call
] unit-test

[ 8 ] [
    1 [ 3 fixnum-shift-fast ] compile-call
] unit-test

TUPLE: alien-accessor-regression { b byte-array } { i fixnum } ;

[ B{ 0 1 } ] [
    B{ 0 0 } 1 alien-accessor-regression boa
    dup [
        { alien-accessor-regression } declare
        [ i>> ] [ b>> ] bi over set-alien-unsigned-1
    ] compile-call
    b>>
] unit-test

: mutable-value-bug-1 ( a b -- c )
    swap [
        { tuple } declare 1 slot
    ] [
        0 slot
    ] if ;

[ t ] [ f B{ } mutable-value-bug-1 byte-array type-number = ] unit-test

: mutable-value-bug-2 ( a b -- c )
    swap [
        0 slot
    ] [
        { tuple } declare 1 slot
    ] if ;

[ t ] [ t B{ } mutable-value-bug-2 byte-array type-number = ] unit-test
