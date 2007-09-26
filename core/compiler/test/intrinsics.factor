IN: temporary
USING: arrays compiler kernel kernel.private math
math.private sequences strings tools.test words continuations
sequences.private hashtables.private byte-arrays
strings.private system random math.vectors layouts
vectors.private sbufs.private strings.private slots.private
alien alien.c-types alien.syntax namespaces libc math.constants
math.functions ;

! Make sure that intrinsic ops compile to correct code.
[ ] [ 1 [ drop ] compile-1 ] unit-test
[ ] [ 1 2 [ 2drop ] compile-1 ] unit-test
[ ] [ 1 2 3 [ 3drop ] compile-1 ] unit-test
[ 1 1 ] [ 1 [ dup ] compile-1 ] unit-test
[ 1 2 1 2 ] [ 1 2 [ 2dup ] compile-1 ] unit-test
[ 1 2 3 1 2 3 ] [ 1 2 3 [ 3dup ] compile-1 ] unit-test
[ 2 3 1 ] [ 1 2 3 [ rot ] compile-1 ] unit-test
[ 3 1 2 ] [ 1 2 3 [ -rot ] compile-1 ] unit-test
[ 1 1 2 ] [ 1 2 [ dupd ] compile-1 ] unit-test
[ 2 1 3 ] [ 1 2 3 [ swapd ] compile-1 ] unit-test
[ 2 ] [ 1 2 [ nip ] compile-1 ] unit-test
[ 3 ] [ 1 2 3 [ 2nip ] compile-1 ] unit-test
[ 2 1 2 ] [ 1 2 [ tuck ] compile-1 ] unit-test
[ 1 2 1 ] [ 1 2 [ over ] compile-1 ] unit-test
[ 1 2 3 1 ] [ 1 2 3 [ pick ] compile-1 ] unit-test
[ 2 1 ] [ 1 2 [ swap ] compile-1 ] unit-test

[ 1 ] [ { 1 2 } [ 2 slot ] compile-1 ] unit-test
[ 1 ] [ [ { 1 2 } 2 slot ] compile-1 ] unit-test
[ 3 ] [ 3 1 2 2array [ [ 2 set-slot ] keep ] compile-1 first ] unit-test
[ 3 ] [ 3 1 2 [ 2array [ 2 set-slot ] keep ] compile-1 first ] unit-test
[ 3 ] [ [ 3 1 2 2array [ 2 set-slot ] keep ] compile-1 first ] unit-test
[ 3 ] [ 3 1 2 2array [ [ 3 set-slot ] keep ] compile-1 second ] unit-test
[ 3 ] [ 3 1 2 [ 2array [ 3 set-slot ] keep ] compile-1 second ] unit-test
[ 3 ] [ [ 3 1 2 2array [ 3 set-slot ] keep ] compile-1 second ] unit-test

! Write barrier hits on the wrong value were causing segfaults
[ -3 ] [ -3 1 2 [ 2array [ 3 set-slot ] keep ] compile-1 second ] unit-test

[ CHAR: b ] [ 1 "abc" [ char-slot ] compile-1 ] unit-test
[ CHAR: b ] [ 1 [ "abc" char-slot ] compile-1 ] unit-test
[ CHAR: b ] [ [ 1 "abc" char-slot ] compile-1 ] unit-test

[ "axc" ] [ CHAR: x 1 "abc" [ [ set-char-slot ] keep { string } declare dup rehash-string ] compile-1 ] unit-test
[ "axc" ] [ CHAR: x 1 [ "abc" [ set-char-slot ] keep { string } declare dup rehash-string ] compile-1 ] unit-test
[ "axc" ] [ CHAR: x [ 1 "abc" [ set-char-slot ] keep { string } declare dup rehash-string ] compile-1 ] unit-test

[ ] [ [ 0 getenv ] compile-1 drop ] unit-test
[ ] [ 1 getenv [ 1 setenv ] compile-1 ] unit-test

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

[ 2 1 "hi" ] [ 1 2 [ swap "hi" ] compile-1 ] unit-test

[ 4 ] [ 12 7 [ fixnum-bitand ] compile-1 ] unit-test
[ 4 ] [ 12 [ 7 fixnum-bitand ] compile-1 ] unit-test
[ 4 ] [ [ 12 7 fixnum-bitand ] compile-1 ] unit-test

[ 15 ] [ 12 7 [ fixnum-bitor ] compile-1 ] unit-test
[ 15 ] [ 12 [ 7 fixnum-bitor ] compile-1 ] unit-test
[ 15 ] [ [ 12 7 fixnum-bitor ] compile-1 ] unit-test

[ 11 ] [ 12 7 [ fixnum-bitxor ] compile-1 ] unit-test
[ 11 ] [ 12 [ 7 fixnum-bitxor ] compile-1 ] unit-test
[ 11 ] [ [ 12 7 fixnum-bitxor ] compile-1 ] unit-test

[ f ] [ 12 7 [ fixnum< [ t ] [ f ] if ] compile-1 ] unit-test
[ f ] [ 12 [ 7 fixnum< [ t ] [ f ] if ] compile-1 ] unit-test
[ f ] [ [ 12 7 fixnum< [ t ] [ f ] if ] compile-1 ] unit-test
[ f ] [ [ 12 12 fixnum< [ t ] [ f ] if ] compile-1 ] unit-test
[ f ] [ 12 12 [ fixnum< [ t ] [ f ] if ] compile-1 ] unit-test

[ t ] [ 12 70 [ fixnum< [ t ] [ f ] if ] compile-1 ] unit-test
[ t ] [ 12 [ 70 fixnum< [ t ] [ f ] if ] compile-1 ] unit-test
[ t ] [ [ 12 70 fixnum< [ t ] [ f ] if ] compile-1 ] unit-test

[ f ] [ 12 7 [ fixnum<= [ t ] [ f ] if ] compile-1 ] unit-test
[ f ] [ 12 [ 7 fixnum<= [ t ] [ f ] if ] compile-1 ] unit-test
[ f ] [ [ 12 7 fixnum<= [ t ] [ f ] if ] compile-1 ] unit-test
[ t ] [ [ 12 12 fixnum<= [ t ] [ f ] if ] compile-1 ] unit-test
[ t ] [ [ 12 12 fixnum<= [ t ] [ f ] if ] compile-1 ] unit-test
[ t ] [ 12 12 [ fixnum<= [ t ] [ f ] if ] compile-1 ] unit-test

[ t ] [ 12 70 [ fixnum<= [ t ] [ f ] if ] compile-1 ] unit-test
[ t ] [ 12 [ 70 fixnum<= [ t ] [ f ] if ] compile-1 ] unit-test
[ t ] [ [ 12 70 fixnum<= [ t ] [ f ] if ] compile-1 ] unit-test

[ t ] [ 12 7 [ fixnum> [ t ] [ f ] if ] compile-1 ] unit-test
[ t ] [ 12 [ 7 fixnum> [ t ] [ f ] if ] compile-1 ] unit-test
[ t ] [ [ 12 7 fixnum> [ t ] [ f ] if ] compile-1 ] unit-test
[ f ] [ [ 12 12 fixnum> [ t ] [ f ] if ] compile-1 ] unit-test
[ f ] [ [ 12 12 fixnum> [ t ] [ f ] if ] compile-1 ] unit-test
[ f ] [ 12 12 [ fixnum> [ t ] [ f ] if ] compile-1 ] unit-test

[ f ] [ 12 70 [ fixnum> [ t ] [ f ] if ] compile-1 ] unit-test
[ f ] [ 12 [ 70 fixnum> [ t ] [ f ] if ] compile-1 ] unit-test
[ f ] [ [ 12 70 fixnum> [ t ] [ f ] if ] compile-1 ] unit-test

[ t ] [ 12 7 [ fixnum>= [ t ] [ f ] if ] compile-1 ] unit-test
[ t ] [ 12 [ 7 fixnum>= [ t ] [ f ] if ] compile-1 ] unit-test
[ t ] [ [ 12 7 fixnum>= [ t ] [ f ] if ] compile-1 ] unit-test
[ t ] [ [ 12 12 fixnum>= [ t ] [ f ] if ] compile-1 ] unit-test
[ t ] [ 12 12 [ fixnum>= [ t ] [ f ] if ] compile-1 ] unit-test

[ f ] [ 12 70 [ fixnum>= [ t ] [ f ] if ] compile-1 ] unit-test
[ f ] [ 12 [ 70 fixnum>= [ t ] [ f ] if ] compile-1 ] unit-test
[ f ] [ [ 12 70 fixnum>= [ t ] [ f ] if ] compile-1 ] unit-test

[ f ] [ 1 2 [ eq? [ t ] [ f ] if ] compile-1 ] unit-test
[ f ] [ 1 [ 2 eq? [ t ] [ f ] if ] compile-1 ] unit-test
[ f ] [ [ 1 2 eq? [ t ] [ f ] if ] compile-1 ] unit-test
[ t ] [ 3 3 [ eq? [ t ] [ f ] if ] compile-1 ] unit-test
[ t ] [ 3 [ 3 eq? [ t ] [ f ] if ] compile-1 ] unit-test
[ t ] [ [ 3 3 eq? [ t ] [ f ] if ] compile-1 ] unit-test

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

[ 4 ] [ 1 3 [ fixnum+fast ] compile-1 ] unit-test
[ 4 ] [ 1 [ 3 fixnum+fast ] compile-1 ] unit-test
[ 4 ] [ [ 1 3 fixnum+fast ] compile-1 ] unit-test

[ 30001 ] [ 1 [ 30000 fixnum+fast ] compile-1 ] unit-test

[ 6 ] [ 2 3 [ fixnum*fast ] compile-1 ] unit-test
[ 6 ] [ 2 [ 3 fixnum*fast ] compile-1 ] unit-test
[ 6 ] [ [ 2 3 fixnum*fast ] compile-1 ] unit-test
[ -6 ] [ 2 -3 [ fixnum*fast ] compile-1 ] unit-test
[ -6 ] [ 2 [ -3 fixnum*fast ] compile-1 ] unit-test
[ -6 ] [ [ 2 -3 fixnum*fast ] compile-1 ] unit-test

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

[ 5 ] [ 1 2 [ eq? [ 3 ] [ 5 ] if ] compile-1 ] unit-test
[ 3 ] [ 2 2 [ eq? [ 3 ] [ 5 ] if ] compile-1 ] unit-test
[ 3 ] [ 1 2 [ fixnum< [ 3 ] [ 5 ] if ] compile-1 ] unit-test
[ 5 ] [ 2 2 [ fixnum< [ 3 ] [ 5 ] if ] compile-1 ] unit-test

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
[ -351382792 ] [ -43922849 [ 3 fixnum-shift ] compile-1 ] unit-test

[ 268435456 ] [ -268435456 >fixnum -1 [ fixnum/i ] compile-1 ] unit-test

[ 268435456 0 ] [ -268435456 >fixnum -1 [ fixnum/mod ] compile-1 ] unit-test

[ t ] [ f [ f eq? ] compile-1 ] unit-test

! regression
[ t ] [ { 1 2 3 } { 1 2 3 } [ over type over type eq? ] compile-1 2nip ] unit-test

! regression
[ 3 ] [
    100001 f <array> 3 100000 pick set-nth
    [ 100000 swap array-nth ] compile-1
] unit-test

! 64-bit overflow
cell 8 = [
    [ t ] [ 1 59 fixnum-shift dup [ fixnum+ ] compile-1 1 60 fixnum-shift = ] unit-test
    [ -1152921504606846977 ] [ 1 60 shift neg >fixnum [ -1 fixnum+ ] compile-1 ] unit-test
    
    [ t ] [ 1 40 shift 1 40 shift [ fixnum* ] compile-1 1 80 shift = ] unit-test
    [ t ] [ 1 40 shift neg 1 40 shift [ fixnum* ] compile-1 1 80 shift neg = ] unit-test
    [ t ] [ 1 40 shift neg 1 40 shift neg [ fixnum* ] compile-1 1 80 shift = ] unit-test
    [ t ] [ 1 30 shift neg 1 50 shift neg [ fixnum* ] compile-1 1 80 shift = ] unit-test
    [ t ] [ 1 50 shift neg 1 30 shift neg [ fixnum* ] compile-1 1 80 shift = ] unit-test

    [ 18446744073709551616 ] [ 1 64 [ fixnum-shift ] compile-1 ] unit-test
    [ 18446744073709551616 ] [ 1 [ 64 fixnum-shift ] compile-1 ] unit-test
    [ 18446744073709551616 ] [ 1 [ 32 fixnum-shift 32 fixnum-shift ] compile-1 ] unit-test
    [ -18446744073709551616 ] [ -1 64 [ fixnum-shift ] compile-1 ] unit-test
    [ -18446744073709551616 ] [ -1 [ 64 fixnum-shift ] compile-1 ] unit-test
    [ -18446744073709551616 ] [ -1 [ 32 fixnum-shift 32 fixnum-shift ] compile-1 ] unit-test
    
    [ 1152921504606846976 ] [ -1152921504606846976 >fixnum -1 [ fixnum/i ] compile-1 ] unit-test

    [ 1152921504606846976 0 ] [ -1152921504606846976 >fixnum -1 [ fixnum/mod ] compile-1 ] unit-test

    [ -268435457 ] [ 28 2^ [ fixnum-bitnot ] compile-1 ] unit-test
] when

! Some randomized tests
: compiled-fixnum* fixnum* ;
\ compiled-fixnum* compile

: test-fixnum*
    (random) >fixnum (random) >fixnum
    2dup
    [ fixnum* ] 2keep compiled-fixnum* =
    [ 2drop ] [ "Oops" throw ] if ;

[ ] [ 10000 [ test-fixnum* ] times ] unit-test

: compiled-fixnum>bignum fixnum>bignum ;
\ compiled-fixnum>bignum compile

: test-fixnum>bignum
    (random) >fixnum
    dup [ fixnum>bignum ] keep compiled-fixnum>bignum =
    [ drop ] [ "Oops" throw ] if ;

[ ] [ 10000 [ test-fixnum>bignum ] times ] unit-test

: compiled-bignum>fixnum bignum>fixnum ;
\ compiled-bignum>fixnum compile

: test-bignum>fixnum
    5 random [ drop (random) ] map product >bignum
    dup [ bignum>fixnum ] keep compiled-bignum>fixnum =
    [ drop ] [ "Oops" throw ] if ;

[ ] [ 10000 [ test-bignum>fixnum ] times ] unit-test

! Test overflow check removal
[ t ] [
    most-positive-fixnum 100 - >fixnum
    200
    [ [ fixnum+ ] compile-1 [ bignum>fixnum ] compile-1 ] 2keep
    [ fixnum+ >fixnum ] compile-1
    =
] unit-test

[ t ] [
    most-negative-fixnum 100 + >fixnum
    -200
    [ [ fixnum+ ] compile-1 [ bignum>fixnum ] compile-1 ] 2keep
    [ fixnum+ >fixnum ] compile-1
    =
] unit-test

[ t ] [
    most-negative-fixnum 100 + >fixnum
    200
    [ [ fixnum- ] compile-1 [ bignum>fixnum ] compile-1 ] 2keep
    [ fixnum- >fixnum ] compile-1
    =
] unit-test

! Test inline allocators
[ { 1 1 1 } ] [
    [ 3 1 <array> ] compile-1
] unit-test

[ B{ 0 0 0 } ] [
    [ 3 <byte-array> ] compile-1
] unit-test

[ 500 ] [
    [ 500 <byte-array> length ] compile-1
] unit-test

[ C{ 1 2 } ] [ 1 2 [ <complex> ] compile-1 ] unit-test

[ 1/2 ] [ 1 2 [ <ratio> ] compile-1 ] unit-test

[ \ + ] [ \ + [ <wrapper> ] compile-1 ] unit-test

[ H{ } ] [
    100 [ (hashtable) ] compile-1 [ reset-hash ] keep
] unit-test

[ B{ 0 0 0 0 0 } ] [
    [ 5 <byte-array> ] compile-1
] unit-test

[ V{ 1 2 } ] [
    { 1 2 3 } 2 [ array>vector ] compile-1
] unit-test

[ SBUF" hello" ] [
    "hello world" 5 [ string>sbuf ] compile-1
] unit-test

[ [ 3 + ] ] [
    3 [ + ] [ curry ] compile-1
] unit-test

! Alien intrinsics
[ 3 ] [ B{ 1 2 3 4 5 } 2 [ alien-unsigned-1 ] compile-1 ] unit-test
[ 3 ] [ [ B{ 1 2 3 4 5 } 2 alien-unsigned-1 ] compile-1 ] unit-test
[ 3 ] [ B{ 1 2 3 4 5 } 2 [ { byte-array fixnum } declare alien-unsigned-1 ] compile-1 ] unit-test
[ 3 ] [ B{ 1 2 3 4 5 } 2 [ { simple-c-ptr fixnum } declare alien-unsigned-1 ] compile-1 ] unit-test

[ ] [ B{ 1 2 3 4 5 } malloc-byte-array "b" set ] unit-test
[ t ] [ "b" get >boolean ] unit-test

"b" get [
    [ 3 ] [ "b" get 2 [ alien-unsigned-1 ] compile-1 ] unit-test
    [ 3 ] [ "b" get [ { simple-alien } declare 2 alien-unsigned-1 ] compile-1 ] unit-test
    [ 3 ] [ "b" get 2 [ { simple-alien fixnum } declare alien-unsigned-1 ] compile-1 ] unit-test
    [ 3 ] [ "b" get 2 [ { simple-c-ptr fixnum } declare alien-unsigned-1 ] compile-1 ] unit-test

    [ ] [ "b" get free ] unit-test
] when

[ t ] [ "hello world" malloc-char-string "s" set ] unit-test
[ t ] [ "s" get >boolean ] unit-test

"s" get [
    [ "hello world" ] [ "s" get <void*> [ { byte-array } declare *void* ] compile-1 alien>char-string ] unit-test
    [ "hello world" ] [ "s" get <void*> [ { simple-c-ptr } declare *void* ] compile-1 alien>char-string ] unit-test

    [ ] [ "s" get free ] unit-test
] when

[ ALIEN: 1234 ] [ ALIEN: 1234 [ { simple-alien } declare <void*> ] compile-1 *void* ] unit-test
[ ALIEN: 1234 ] [ ALIEN: 1234 [ { simple-c-ptr } declare <void*> ] compile-1 *void* ] unit-test
[ f ] [ f [ { POSTPONE: f } declare <void*> ] compile-1 *void* ] unit-test

[ 252 ] [ B{ 1 2 3 -4 5 } 3 [ { byte-array fixnum } declare alien-unsigned-1 ] compile-1 ] unit-test
[ -4 ] [ B{ 1 2 3 -4 5 } 3 [ { byte-array fixnum } declare alien-signed-1 ] compile-1 ] unit-test

: xword-def word-def [ { fixnum } declare ] swap append ;

[ -100 ] [ -100 <char> [ { byte-array } declare *char ] compile-1 ] unit-test
[ 156 ] [ -100 <uchar> [ { byte-array } declare *uchar ] compile-1 ] unit-test

[ -100 ] [ -100 \ <char> xword-def compile-1 *char ] unit-test
[ 156 ] [ -100 \ <uchar> xword-def compile-1 *uchar ] unit-test

[ -1000 ] [ -1000 <short> [ { byte-array } declare *short ] compile-1 ] unit-test
[ 64536 ] [ -1000 <ushort> [ { byte-array } declare *ushort ] compile-1 ] unit-test

[ -1000 ] [ -1000 \ <short> xword-def compile-1 *short ] unit-test
[ 64536 ] [ -1000 \ <ushort> xword-def compile-1 *ushort ] unit-test

[ -100000 ] [ -100000 <int> [ { byte-array } declare *int ] compile-1 ] unit-test
[ 4294867296 ] [ -100000 <uint> [ { byte-array } declare *uint ] compile-1 ] unit-test

[ -100000 ] [ -100000 \ <int> xword-def compile-1 *int ] unit-test
[ 4294867296 ] [ -100000 \ <uint> xword-def compile-1 *uint ] unit-test

[ t ] [ pi pi <double> *double = ] unit-test

[ t ] [ pi <double> [ { byte-array } declare *double ] compile-1 pi = ] unit-test

! Silly
[ t ] [ pi 4 <byte-array> [ [ { float byte-array } declare 0 set-alien-float ] compile-1 ] keep *float pi - abs 0.001 < ] unit-test
[ t ] [ pi <float> [ { byte-array } declare *float ] compile-1 pi - abs 0.001 < ] unit-test

[ t ] [ pi 8 <byte-array> [ [ { float byte-array } declare 0 set-alien-double ] compile-1 ] keep *double pi = ] unit-test
