USING: accessors arrays compiler.units kernel kernel.private
math math.constants math.private math.integers.private sequences
strings tools.test words continuations sequences.private
hashtables.private byte-arrays system random layouts vectors
sbufs strings.private slots.private alien math.order
alien.accessors alien.c-types alien.data alien.syntax alien.strings
namespaces libc io.encodings.ascii classes compiler.test ;
FROM: math => float ;
QUALIFIED-WITH: alien.c-types c
IN: compiler.tests.intrinsics

! Make sure that intrinsic ops compile to correct code.
{ } [ 1 [ drop ] compile-call ] unit-test
{ } [ 1 2 [ 2drop ] compile-call ] unit-test
{ } [ 1 2 3 [ 3drop ] compile-call ] unit-test
{ 1 1 } [ 1 [ dup ] compile-call ] unit-test
{ 1 2 1 2 } [ 1 2 [ 2dup ] compile-call ] unit-test
{ 1 2 3 1 2 3 } [ 1 2 3 [ 3dup ] compile-call ] unit-test
{ 2 3 1 } [ 1 2 3 [ rot ] compile-call ] unit-test
{ 3 1 2 } [ 1 2 3 [ -rot ] compile-call ] unit-test
{ 1 1 2 } [ 1 2 [ dupd ] compile-call ] unit-test
{ 2 1 3 } [ 1 2 3 [ swapd ] compile-call ] unit-test
{ 2 } [ 1 2 [ nip ] compile-call ] unit-test
{ 3 } [ 1 2 3 [ 2nip ] compile-call ] unit-test
{ 1 2 1 } [ 1 2 [ over ] compile-call ] unit-test
{ 1 2 3 1 } [ 1 2 3 [ pick ] compile-call ] unit-test
{ 2 1 } [ 1 2 [ swap ] compile-call ] unit-test

{ 1 } [ { 1 2 } [ 2 slot ] compile-call ] unit-test
{ 1 } [ [ { 1 2 } 2 slot ] compile-call ] unit-test

{ { f f } } [ 2 f <array> ] unit-test

{ 3 } [ 3 1 2 2array [ { array } declare [ 2 set-slot ] keep ] compile-call first ] unit-test
{ 3 } [ 3 1 2 [ 2array [ 2 set-slot ] keep ] compile-call first ] unit-test
{ 3 } [ [ 3 1 2 2array [ 2 set-slot ] keep ] compile-call first ] unit-test
{ 3 } [ 3 1 2 2array [ [ 3 set-slot ] keep ] compile-call second ] unit-test
{ 3 } [ 3 1 2 [ 2array [ 3 set-slot ] keep ] compile-call second ] unit-test
{ 3 } [ [ 3 1 2 2array [ 3 set-slot ] keep ] compile-call second ] unit-test

! Write barrier hits on the wrong value were causing segfaults
{ -3 } [ -3 1 2 [ 2array [ 3 set-slot ] keep ] compile-call second ] unit-test

{ CHAR: a } [ 0 "abc" [ string-nth ] compile-call ] unit-test
{ CHAR: a } [ 0 [ "abc" string-nth ] compile-call ] unit-test
{ CHAR: a } [ [ 0 "abc" string-nth ] compile-call ] unit-test
{ CHAR: b } [ 1 "abc" [ string-nth ] compile-call ] unit-test
{ CHAR: b } [ 1 [ "abc" string-nth ] compile-call ] unit-test
{ CHAR: b } [ [ 1 "abc" string-nth ] compile-call ] unit-test

{ 0x123456 } [ 0 "\u123456bc" [ string-nth ] compile-call ] unit-test
{ 0x123456 } [ 0 [ "\u123456bc" string-nth ] compile-call ] unit-test
{ 0x123456 } [ [ 0 "\u123456bc" string-nth ] compile-call ] unit-test
{ 0x123456 } [ 1 "a\u123456c" [ string-nth ] compile-call ] unit-test
{ 0x123456 } [ 1 [ "a\u123456c" string-nth ] compile-call ] unit-test
{ 0x123456 } [ [ 1 "a\u123456c" string-nth ] compile-call ] unit-test

[ [ 0 special-object ] compile-call ] must-not-fail
{ } [ 1 special-object [ 1 set-special-object ] compile-call ] unit-test

{ } [ 1 [ drop ] compile-call ] unit-test
{ } [ [ 1 drop ] compile-call ] unit-test
{ } [ [ 1 2 2drop ] compile-call ] unit-test
{ } [ 1 [ 2 2drop ] compile-call ] unit-test
{ } [ 1 2 [ 2drop ] compile-call ] unit-test
{ 2 1 } [ [ 1 2 swap ] compile-call ] unit-test
{ 2 1 } [ 1 [ 2 swap ] compile-call ] unit-test
{ 2 1 } [ 1 2 [ swap ] compile-call ] unit-test
{ 1 1 } [ 1 [ dup ] compile-call ] unit-test
{ 1 1 } [ [ 1 dup ] compile-call ] unit-test
{ 1 2 1 } [ [ 1 2 over ] compile-call ] unit-test
{ 1 2 1 } [ 1 [ 2 over ] compile-call ] unit-test
{ 1 2 1 } [ 1 2 [ over ] compile-call ] unit-test
{ 1 2 3 1 } [ [ 1 2 3 pick ] compile-call ] unit-test
{ 1 2 3 1 } [ 1 [ 2 3 pick ] compile-call ] unit-test
{ 1 2 3 1 } [ 1 2 [ 3 pick ] compile-call ] unit-test
{ 1 2 3 1 } [ 1 2 3 [ pick ] compile-call ] unit-test
{ 1 1 2 } [ [ 1 2 dupd ] compile-call ] unit-test
{ 1 1 2 } [ 1 [ 2 dupd ] compile-call ] unit-test
{ 1 1 2 } [ 1 2 [ dupd ] compile-call ] unit-test
{ 2 } [ [ 1 2 nip ] compile-call ] unit-test
{ 2 } [ 1 [ 2 nip ] compile-call ] unit-test
{ 2 } [ 1 2 [ nip ] compile-call ] unit-test

{ 2 1 "hi" } [ 1 2 [ swap "hi" ] compile-call ] unit-test

{ 4 } [ 12 7 [ fixnum-bitand ] compile-call ] unit-test
{ 4 } [ 12 [ 7 fixnum-bitand ] compile-call ] unit-test
{ 4 } [ [ 12 7 fixnum-bitand ] compile-call ] unit-test
{ -16 } [ -1 [ -16 fixnum-bitand ] compile-call ] unit-test

{ 15 } [ 12 7 [ fixnum-bitor ] compile-call ] unit-test
{ 15 } [ 12 [ 7 fixnum-bitor ] compile-call ] unit-test
{ 15 } [ [ 12 7 fixnum-bitor ] compile-call ] unit-test
{ -1 } [ -1 [ -16 fixnum-bitor ] compile-call ] unit-test

{ 11 } [ 12 7 [ fixnum-bitxor ] compile-call ] unit-test
{ 11 } [ 12 [ 7 fixnum-bitxor ] compile-call ] unit-test
{ 11 } [ [ 12 7 fixnum-bitxor ] compile-call ] unit-test
{ 15 } [ -1 [ -16 fixnum-bitxor ] compile-call ] unit-test

{ f } [ 12 7 [ fixnum< [ t ] [ f ] if ] compile-call ] unit-test
{ f } [ 12 [ 7 fixnum< [ t ] [ f ] if ] compile-call ] unit-test
{ f } [ [ 12 7 fixnum< [ t ] [ f ] if ] compile-call ] unit-test
{ f } [ [ 12 12 fixnum< [ t ] [ f ] if ] compile-call ] unit-test
{ f } [ 12 12 [ fixnum< [ t ] [ f ] if ] compile-call ] unit-test

{ t } [ 12 70 [ fixnum< [ t ] [ f ] if ] compile-call ] unit-test
{ t } [ 12 [ 70 fixnum< [ t ] [ f ] if ] compile-call ] unit-test
{ t } [ [ 12 70 fixnum< [ t ] [ f ] if ] compile-call ] unit-test

{ f } [ 12 7 [ fixnum<= [ t ] [ f ] if ] compile-call ] unit-test
{ f } [ 12 [ 7 fixnum<= [ t ] [ f ] if ] compile-call ] unit-test
{ f } [ [ 12 7 fixnum<= [ t ] [ f ] if ] compile-call ] unit-test
{ t } [ [ 12 12 fixnum<= [ t ] [ f ] if ] compile-call ] unit-test
{ t } [ [ 12 12 fixnum<= [ t ] [ f ] if ] compile-call ] unit-test
{ t } [ 12 12 [ fixnum<= [ t ] [ f ] if ] compile-call ] unit-test

{ t } [ 12 70 [ fixnum<= [ t ] [ f ] if ] compile-call ] unit-test
{ t } [ 12 [ 70 fixnum<= [ t ] [ f ] if ] compile-call ] unit-test
{ t } [ [ 12 70 fixnum<= [ t ] [ f ] if ] compile-call ] unit-test

{ t } [ 12 7 [ fixnum> [ t ] [ f ] if ] compile-call ] unit-test
{ t } [ 12 [ 7 fixnum> [ t ] [ f ] if ] compile-call ] unit-test
{ t } [ [ 12 7 fixnum> [ t ] [ f ] if ] compile-call ] unit-test
{ f } [ [ 12 12 fixnum> [ t ] [ f ] if ] compile-call ] unit-test
{ f } [ [ 12 12 fixnum> [ t ] [ f ] if ] compile-call ] unit-test
{ f } [ 12 12 [ fixnum> [ t ] [ f ] if ] compile-call ] unit-test

{ f } [ 12 70 [ fixnum> [ t ] [ f ] if ] compile-call ] unit-test
{ f } [ 12 [ 70 fixnum> [ t ] [ f ] if ] compile-call ] unit-test
{ f } [ [ 12 70 fixnum> [ t ] [ f ] if ] compile-call ] unit-test

{ t } [ 12 7 [ fixnum>= [ t ] [ f ] if ] compile-call ] unit-test
{ t } [ 12 [ 7 fixnum>= [ t ] [ f ] if ] compile-call ] unit-test
{ t } [ [ 12 7 fixnum>= [ t ] [ f ] if ] compile-call ] unit-test
{ t } [ [ 12 12 fixnum>= [ t ] [ f ] if ] compile-call ] unit-test
{ t } [ 12 12 [ fixnum>= [ t ] [ f ] if ] compile-call ] unit-test

{ f } [ 12 70 [ fixnum>= [ t ] [ f ] if ] compile-call ] unit-test
{ f } [ 12 [ 70 fixnum>= [ t ] [ f ] if ] compile-call ] unit-test
{ f } [ [ 12 70 fixnum>= [ t ] [ f ] if ] compile-call ] unit-test

{ f } [ 1 2 [ eq? [ t ] [ f ] if ] compile-call ] unit-test
{ f } [ 1 [ 2 eq? [ t ] [ f ] if ] compile-call ] unit-test
{ f } [ [ 1 2 eq? [ t ] [ f ] if ] compile-call ] unit-test
{ t } [ 3 3 [ eq? [ t ] [ f ] if ] compile-call ] unit-test
{ t } [ 3 [ 3 eq? [ t ] [ f ] if ] compile-call ] unit-test
{ t } [ [ 3 3 eq? [ t ] [ f ] if ] compile-call ] unit-test

{ -1 } [ 0 [ fixnum-bitnot ] compile-call ] unit-test
{ -1 } [ [ 0 fixnum-bitnot ] compile-call ] unit-test

{ 3 } [ 13 10 [ fixnum-mod ] compile-call ] unit-test
{ 3 } [ 13 [ 10 fixnum-mod ] compile-call ] unit-test
{ 3 } [ [ 13 10 fixnum-mod ] compile-call ] unit-test
{ -3 } [ -13 10 [ fixnum-mod ] compile-call ] unit-test
{ -3 } [ -13 [ 10 fixnum-mod ] compile-call ] unit-test
{ -3 } [ [ -13 10 fixnum-mod ] compile-call ] unit-test

{ 2 } [ 4 2 [ fixnum/i ] compile-call ] unit-test
{ 2 } [ 4 [ 2 fixnum/i ] compile-call ] unit-test
{ -2 } [ 4 [ -2 fixnum/i ] compile-call ] unit-test
{ 3 1 } [ 10 3 [ fixnum/mod ] compile-call ] unit-test

{ 2 } [ 4 2 [ fixnum/i-fast ] compile-call ] unit-test
{ 2 } [ 4 [ 2 fixnum/i-fast ] compile-call ] unit-test
{ -2 } [ 4 [ -2 fixnum/i-fast ] compile-call ] unit-test
{ 3 1 } [ 10 3 [ fixnum/mod-fast ] compile-call ] unit-test

{ 4 } [ 1 3 [ fixnum+ ] compile-call ] unit-test
{ 4 } [ 1 [ 3 fixnum+ ] compile-call ] unit-test
{ 4 } [ [ 1 3 fixnum+ ] compile-call ] unit-test

{ 4 } [ 1 3 [ fixnum+fast ] compile-call ] unit-test
{ 4 } [ 1 [ 3 fixnum+fast ] compile-call ] unit-test
{ 4 } [ [ 1 3 fixnum+fast ] compile-call ] unit-test

{ -2 } [ 1 3 [ fixnum-fast ] compile-call ] unit-test
{ -2 } [ 1 [ 3 fixnum-fast ] compile-call ] unit-test
{ -2 } [ [ 1 3 fixnum-fast ] compile-call ] unit-test

{ 30001 } [ 1 [ 30000 fixnum+fast ] compile-call ] unit-test

{ 6 } [ 2 3 [ fixnum*fast ] compile-call ] unit-test
{ 6 } [ 2 [ 3 fixnum*fast ] compile-call ] unit-test
{ 6 } [ [ 2 3 fixnum*fast ] compile-call ] unit-test
{ -6 } [ 2 -3 [ fixnum*fast ] compile-call ] unit-test
{ -6 } [ 2 [ -3 fixnum*fast ] compile-call ] unit-test
{ -6 } [ [ 2 -3 fixnum*fast ] compile-call ] unit-test

{ 6 } [ 2 3 [ fixnum* ] compile-call ] unit-test
{ 6 } [ 2 [ 3 fixnum* ] compile-call ] unit-test
{ 6 } [ [ 2 3 fixnum* ] compile-call ] unit-test
{ -6 } [ 2 -3 [ fixnum* ] compile-call ] unit-test
{ -6 } [ 2 [ -3 fixnum* ] compile-call ] unit-test
{ -6 } [ [ 2 -3 fixnum* ] compile-call ] unit-test

{ 5 } [ 1 2 [ eq? [ 3 ] [ 5 ] if ] compile-call ] unit-test
{ 3 } [ 2 2 [ eq? [ 3 ] [ 5 ] if ] compile-call ] unit-test
{ 3 } [ 1 2 [ fixnum< [ 3 ] [ 5 ] if ] compile-call ] unit-test
{ 5 } [ 2 2 [ fixnum< [ 3 ] [ 5 ] if ] compile-call ] unit-test

{ 8 } [ 1 3 [ fixnum-shift ] compile-call ] unit-test
{ 8 } [ 1 [ 3 fixnum-shift ] compile-call ] unit-test
{ 8 } [ [ 1 3 fixnum-shift ] compile-call ] unit-test
{ -8 } [ -1 3 [ fixnum-shift ] compile-call ] unit-test
{ -8 } [ -1 [ 3 fixnum-shift ] compile-call ] unit-test
{ -8 } [ [ -1 3 fixnum-shift ] compile-call ] unit-test

{ 2 } [ 8 -2 [ fixnum-shift ] compile-call ] unit-test
{ 2 } [ 8 [ -2 fixnum-shift ] compile-call ] unit-test

{ 0 } [ [ 123 -64 fixnum-shift ] compile-call ] unit-test
{ 0 } [ 123 -64 [ fixnum-shift ] compile-call ] unit-test
{ -1 } [ [ -123 -64 fixnum-shift ] compile-call ] unit-test
{ -1 } [ -123 -64 [ fixnum-shift ] compile-call ] unit-test

{ 4294967296 } [ 1 32 [ fixnum-shift ] compile-call ] unit-test
{ 4294967296 } [ 1 [ 32 fixnum-shift ] compile-call ] unit-test
{ 4294967296 } [ 1 [ 16 fixnum-shift 16 fixnum-shift ] compile-call ] unit-test
{ -4294967296 } [ -1 32 [ fixnum-shift ] compile-call ] unit-test
{ -4294967296 } [ -1 [ 32 fixnum-shift ] compile-call ] unit-test
{ -4294967296 } [ -1 [ 16 fixnum-shift 16 fixnum-shift ] compile-call ] unit-test

{ 8 } [ 1 3 [ fixnum-shift-fast ] compile-call ] unit-test
{ 8 } [ 1 3 [ 15 bitand fixnum-shift-fast ] compile-call ] unit-test
{ 8 } [ 1 [ 3 fixnum-shift-fast ] compile-call ] unit-test
{ 8 } [ [ 1 3 fixnum-shift-fast ] compile-call ] unit-test
{ -8 } [ -1 3 [ fixnum-shift-fast ] compile-call ] unit-test
{ -8 } [ -1 3 [ 15 bitand fixnum-shift-fast ] compile-call ] unit-test
{ -8 } [ -1 [ 3 fixnum-shift-fast ] compile-call ] unit-test
{ -8 } [ [ -1 3 fixnum-shift-fast ] compile-call ] unit-test

{ 2 } [ 8 -2 [ fixnum-shift-fast ] compile-call ] unit-test
{ 2 } [ 8 2 [ 15 bitand neg fixnum-shift-fast ] compile-call ] unit-test
{ 2 } [ 8 [ -2 fixnum-shift-fast ] compile-call ] unit-test

{ 4294967296 } [ 1 32 [ fixnum-shift ] compile-call ] unit-test
{ 4294967296 } [ 1 [ 32 fixnum-shift ] compile-call ] unit-test
{ 4294967296 } [ 1 [ 16 fixnum-shift 16 fixnum-shift ] compile-call ] unit-test
{ -4294967296 } [ -1 32 [ fixnum-shift ] compile-call ] unit-test
{ -4294967296 } [ -1 [ 32 fixnum-shift ] compile-call ] unit-test
{ -4294967296 } [ -1 [ 16 fixnum-shift 16 fixnum-shift ] compile-call ] unit-test

{ 0x10000000 } [ 0x1000000 0x10 [ fixnum* ] compile-call ] unit-test
{ 0x8000000 } [ -0x8000000 >fixnum [ 0 swap fixnum- ] compile-call ] unit-test
{ 0x8000000 } [ -0x7ffffff >fixnum [ 1 swap fixnum- ] compile-call ] unit-test

{ t } [ 1 26 fixnum-shift dup [ fixnum+ ] compile-call 1 27 fixnum-shift = ] unit-test
{ -134217729 } [ 1 27 shift neg >fixnum [ -1 fixnum+ ] compile-call ] unit-test

{ t } [ 1 20 shift 1 20 shift [ fixnum* ] compile-call 1 40 shift = ] unit-test
{ t } [ 1 20 shift neg 1 20 shift [ fixnum* ] compile-call 1 40 shift neg = ] unit-test
{ t } [ 1 20 shift neg 1 20 shift neg [ fixnum* ] compile-call 1 40 shift = ] unit-test
{ -351382792 } [ -43922849 [ 3 fixnum-shift ] compile-call ] unit-test

{ 134217728 } [ -134217728 >fixnum -1 [ fixnum/i ] compile-call ] unit-test

{ 134217728 0 } [ -134217728 >fixnum -1 [ fixnum/mod ] compile-call ] unit-test

{ t } [ f [ f eq? ] compile-call ] unit-test

cell 8 = [
    { 0x40400000 } [
        0x4200 [ 0x7fff fixnum-bitand 13 fixnum-shift-fast 112 23 fixnum-shift-fast fixnum+fast ]
        compile-call
    ] unit-test
] when

! regression
{ 3 } [
    100001 f <array> 3 100000 pick set-nth
    [ 100000 swap array-nth ] compile-call
] unit-test

{ 2 } [ 2 4 [ fixnum-min ] compile-call ] unit-test
{ 2 } [ 4 2 [ fixnum-min ] compile-call ] unit-test
{ 4 } [ 2 4 [ fixnum-max ] compile-call ] unit-test
{ 4 } [ 4 2 [ fixnum-max ] compile-call ] unit-test
{ -2 } [ -2 -4 [ fixnum-max ] compile-call ] unit-test
{ -2 } [ -4 -2 [ fixnum-max ] compile-call ] unit-test
{ -4 } [ -2 -4 [ fixnum-min ] compile-call ] unit-test
{ -4 } [ -4 -2 [ fixnum-min ] compile-call ] unit-test

! 64-bit overflow
cell 8 = [
    { t } [ 1 fixnum-bits 2 - fixnum-shift dup [ fixnum+ ] compile-call 1 fixnum-bits 1 - fixnum-shift = ] unit-test
    { t } [ most-negative-fixnum [ -1 fixnum+ ] compile-call first-bignum 1 + neg = ] unit-test

    { t } [ 1 40 shift 1 40 shift [ fixnum* ] compile-call 1 80 shift = ] unit-test
    { t } [ 1 40 shift neg 1 40 shift [ fixnum* ] compile-call 1 80 shift neg = ] unit-test
    { t } [ 1 40 shift neg 1 40 shift neg [ fixnum* ] compile-call 1 80 shift = ] unit-test
    { t } [ 1 30 shift neg 1 50 shift neg [ fixnum* ] compile-call 1 80 shift = ] unit-test
    { t } [ 1 50 shift neg 1 30 shift neg [ fixnum* ] compile-call 1 80 shift = ] unit-test

    { 18446744073709551616 } [ 1 64 [ fixnum-shift ] compile-call ] unit-test
    { 18446744073709551616 } [ 1 [ 64 fixnum-shift ] compile-call ] unit-test
    { 18446744073709551616 } [ 1 [ 32 fixnum-shift 32 fixnum-shift ] compile-call ] unit-test
    { -18446744073709551616 } [ -1 64 [ fixnum-shift ] compile-call ] unit-test
    { -18446744073709551616 } [ -1 [ 64 fixnum-shift ] compile-call ] unit-test
    { -18446744073709551616 } [ -1 [ 32 fixnum-shift 32 fixnum-shift ] compile-call ] unit-test

    { t } [ most-negative-fixnum -1 [ fixnum/i ] compile-call first-bignum = ] unit-test

    { t } [ most-negative-fixnum -1 [ fixnum/mod ] compile-call [ first-bignum = ] [ zero? ] bi* and ] unit-test

    { -268435457 } [ 28 2^ [ fixnum-bitnot ] compile-call ] unit-test
] when

! Some randomized tests
: compiled-fixnum* ( a b -- c ) fixnum* ;

ERROR: bug-in-fixnum* x y a b ;

{ } [
    10000 [
        32 random-bits >fixnum
        32 random-bits >fixnum
        2dup [ fixnum* ] [ compiled-fixnum* ] 2bi 2dup =
        [ 4drop ] [ bug-in-fixnum* ] if
    ] times
] unit-test

: compiled-fixnum>bignum ( a -- b ) fixnum>bignum ;

{ bignum } [ 0 compiled-fixnum>bignum class-of ] unit-test

{ } [
    10000 [
        32 random-bits >fixnum
        dup [ fixnum>bignum ] keep compiled-fixnum>bignum =
        [ drop ] [ "Oops" throw ] if
    ] times
] unit-test

: compiled-bignum>fixnum ( a -- b ) bignum>fixnum ;

{ } [
    10000 [
        5 random <iota> [ drop 32 random-bits ] map product >bignum
        dup [ bignum>fixnum ] keep compiled-bignum>fixnum =
        [ drop ] [ "Oops" throw ] if
    ] times
] unit-test

! Test overflow check removal
{ t } [
    most-positive-fixnum 100 - >fixnum
    200
    [ [ fixnum+ ] compile-call [ bignum>fixnum ] compile-call ] 2keep
    [ fixnum+ >fixnum ] compile-call
    =
] unit-test

{ t } [
    most-negative-fixnum 100 + >fixnum
    -200
    [ [ fixnum+ ] compile-call [ bignum>fixnum ] compile-call ] 2keep
    [ fixnum+ >fixnum ] compile-call
    =
] unit-test

{ t } [
    most-negative-fixnum 100 + >fixnum
    200
    [ [ fixnum- ] compile-call [ bignum>fixnum ] compile-call ] 2keep
    [ fixnum- >fixnum ] compile-call
    =
] unit-test

! Test inline allocators
{ { 1 1 1 } } [
    [ 3 1 <array> ] compile-call
] unit-test

{ B{ 0 0 0 } } [
    [ 3 <byte-array> ] compile-call
] unit-test

{ 500 } [
    [ 500 <byte-array> length ] compile-call
] unit-test

{ 1 2 } [
    1 2 [ complex boa ] compile-call
    dup real-part swap imaginary-part
] unit-test

{ 1 2 } [
    1 2 [ ratio boa ] compile-call dup numerator swap denominator
] unit-test

{ \ + } [ \ + [ <wrapper> ] compile-call ] unit-test

{ B{ 0 0 0 0 0 } } [
    [ 5 <byte-array> ] compile-call
] unit-test

{ V{ 1 2 } } [
    { 1 2 3 } 2 [ vector boa ] compile-call
] unit-test

{ SBUF" hello" } [
    "hello world" 5 [ sbuf boa ] compile-call
] unit-test

{ [ 3 + ] } [
    3 [ + ] [ curry ] compile-call
] unit-test

! Alien intrinsics
{ 3 } [ B{ 1 2 3 4 5 } 2 [ alien-unsigned-1 ] compile-call ] unit-test
{ 3 } [ [ B{ 1 2 3 4 5 } 2 alien-unsigned-1 ] compile-call ] unit-test
{ 3 } [ B{ 1 2 3 4 5 } 2 [ { byte-array fixnum } declare alien-unsigned-1 ] compile-call ] unit-test
{ 3 } [ B{ 1 2 3 4 5 } 2 [ { c-ptr fixnum } declare alien-unsigned-1 ] compile-call ] unit-test

{ } [ B{ 1 2 3 4 5 } malloc-byte-array "b" set ] unit-test
{ t } [ "b" get >boolean ] unit-test

"b" get [
    { 3 } [ "b" get 2 [ alien-unsigned-1 ] compile-call ] unit-test
    { 3 } [ "b" get [ { alien } declare 2 alien-unsigned-1 ] compile-call ] unit-test
    { 3 } [ "b" get 2 [ { alien fixnum } declare alien-unsigned-1 ] compile-call ] unit-test
    { 3 } [ "b" get 2 [ { c-ptr fixnum } declare alien-unsigned-1 ] compile-call ] unit-test

    { } [ "b" get free ] unit-test
] when

{ } [ "hello world" ascii malloc-string "s" set ] unit-test

"s" get [
    { "hello world" } [ "s" get void* <ref> [ { byte-array } declare void* deref ] compile-call ascii alien>string ] unit-test
    { "hello world" } [ "s" get void* <ref> [ { c-ptr } declare void* deref ] compile-call ascii alien>string ] unit-test

    { } [ "s" get free ] unit-test
] when

{ ALIEN: 1234 } [ ALIEN: 1234 [ { alien } declare void* <ref> ] compile-call void* deref ] unit-test
{ ALIEN: 1234 } [ ALIEN: 1234 [ { c-ptr } declare void* <ref> ] compile-call void* deref ] unit-test
{ f } [ f [ { POSTPONE: f } declare void* <ref> ] compile-call void* deref ] unit-test

{ 252 } [ B{ 1 2 3 -4 5 } 3 [ { byte-array fixnum } declare alien-unsigned-1 ] compile-call ] unit-test
{ -4 } [ B{ 1 2 3 -4 5 } 3 [ { byte-array fixnum } declare alien-signed-1 ] compile-call ] unit-test

{ -100 } [ -100 char <ref> [ { byte-array } declare char deref ] compile-call ] unit-test
{ 156 } [ -100 uchar <ref> [ { byte-array } declare uchar deref ] compile-call ] unit-test

{ -100 } [ -100 [ char <ref> ] [ { fixnum } declare ] prepend compile-call char deref ] unit-test
{ 156 } [ -100 [ uchar <ref> ] [ { fixnum } declare ] prepend compile-call uchar deref ] unit-test

{ -1000 } [ -1000 short <ref> [ { byte-array } declare short deref ] compile-call ] unit-test
{ 64536 } [ -1000 ushort <ref> [ { byte-array } declare ushort deref ] compile-call ] unit-test

{ -1000 } [ -1000 [ short <ref> ] [ { fixnum } declare ] prepend compile-call short deref ] unit-test
{ 64536 } [ -1000 [ ushort <ref> ] [ { fixnum } declare ] prepend compile-call ushort deref ] unit-test

{ -100000 } [ -100000 int <ref> [ { byte-array } declare int deref ] compile-call ] unit-test
{ 4294867296 } [ -100000 uint <ref> [ { byte-array } declare uint deref ] compile-call ] unit-test

{ -100000 } [ -100000 [ int <ref> ] [ { fixnum } declare ] prepend compile-call int deref ] unit-test
{ 4294867296 } [ -100000 [ uint <ref> ] [ { fixnum } declare ] prepend compile-call uint deref ] unit-test

{ t } [ pi pi double <ref> double deref = ] unit-test

{ t } [ pi double <ref> [ { byte-array } declare double deref ] compile-call pi = ] unit-test

! Silly
{ t } [ pi 4 <byte-array> [ [ { float byte-array } declare 0 set-alien-float ] compile-call ] keep c:float deref pi - -0.001 0.001 between? ] unit-test
{ t } [ pi c:float <ref> [ { byte-array } declare c:float deref ] compile-call pi - -0.001 0.001 between? ] unit-test

{ t } [ pi 8 <byte-array> [ [ { float byte-array } declare 0 set-alien-double ] compile-call ] keep double deref pi = ] unit-test

{ 4 } [
    2 B{ 1 2 3 4 5 6 } <displaced-alien> [
        { alien } declare 1 alien-unsigned-1
    ] compile-call
] unit-test

{ ALIEN: 123 } [
    0x123 [ <alien> ] compile-call
] unit-test

{ ALIEN: 123 } [
    0x123 [ { fixnum } declare <alien> ] compile-call
] unit-test

{ ALIEN: 123 } [
    [ 0x123 <alien> ] compile-call
] unit-test

{ f } [
    0 [ <alien> ] compile-call
] unit-test

{ f } [
    0 [ { fixnum } declare <alien> ] compile-call
] unit-test

{ f } [
    [ 0 <alien> ] compile-call
] unit-test

{ ALIEN: 321 } [
    0 ALIEN: 321 [ <displaced-alien> ] compile-call
] unit-test

{ ALIEN: 321 } [
    0 ALIEN: 321 [ { fixnum c-ptr } declare <displaced-alien> ] compile-call
] unit-test

{ ALIEN: 321 } [
    ALIEN: 321 [ 0 swap <displaced-alien> ] compile-call
] unit-test

{ B{ 0 1 2 3 4 } } [
    2 B{ 0 1 2 3 4 } <displaced-alien>
    [ 1 swap <displaced-alien> ] compile-call
    underlying>>
] unit-test

{ B{ 0 1 2 3 4 } } [
    2 B{ 0 1 2 3 4 } <displaced-alien>
    [ 1 swap { c-ptr } declare <displaced-alien> ] compile-call
    underlying>>
] unit-test

{ ALIEN: 1234 ALIEN: 2234 } [
    ALIEN: 234 [
        { c-ptr } declare
        [ 0x1000 swap <displaced-alien> ]
        [ 0x2000 swap <displaced-alien> ] bi
    ] compile-call
] unit-test

! These tests must fail because we're not allowed to store
! a pointer to a byte array inside of an alien object
[
    B{ 0 0 0 0 } [ { byte-array } declare void* <ref> ] compile-call
] must-fail

[
    B{ 0 0 0 0 } [ { c-ptr } declare void* <ref> ] compile-call
] must-fail

{ 4 5 } [
    3 [
        [
            { [ 4444 ] [ 444 ] [ 44 ] [ 4 ] } dispatch
        ] keep 2 fixnum+fast
    ] compile-call
] unit-test

{ 1 } [
    8 -3 [ fixnum-shift-fast ] compile-call
] unit-test

{ 2 } [
    16 -3 [ fixnum-shift-fast ] compile-call
] unit-test

{ 2 } [
    16 [ -3 fixnum-shift-fast ] compile-call
] unit-test

{ 8 } [
    1 3 [ fixnum-shift-fast ] compile-call
] unit-test

{ 8 } [
    1 [ 3 fixnum-shift-fast ] compile-call
] unit-test

TUPLE: alien-accessor-regression { b byte-array } { i fixnum } ;

{ B{ 0 1 } } [
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
        1 slot
    ] if ;

{ 0 } [ f { } mutable-value-bug-1 ] unit-test

: mutable-value-bug-2 ( a b -- c )
    swap [
        1 slot
    ] [
        { tuple } declare 1 slot
    ] if ;

{ 0 } [ t { } mutable-value-bug-2 ] unit-test
