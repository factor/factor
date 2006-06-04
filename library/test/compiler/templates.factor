! Black box testing of templater optimization

USING: arrays compiler kernel kernel-internals math
math-internals namespaces sequences sequences-internals test ;
IN: temporary

! Oops!
[ 5000 ] [ [ 5000 ] compile-1 ] unit-test
[ "hi" ] [ [ "hi" ] compile-1 ] unit-test

[ 1 2 3 4 ] [ [ 1 2 3 4 ] compile-1 ] unit-test

[ 1 1 ] [ 1 [ dup ] compile-1 ] unit-test
[ 0 ] [ 3 [ tag ] compile-1 ] unit-test
[ 0 3 ] [ 3 [ [ tag ] keep ] compile-1 ] unit-test

[ 2 3 ] [ 3 [ 2 swap ] compile-1 ] unit-test

[ 2 1 3 4 ] [ 1 2 [ swap 3 4 ] compile-1 ] unit-test

[ 2 3 4 ] [ 3 [ 2 swap 4 ] compile-1 ] unit-test

[ { 1 2 3 } { 1 4 3 } 3 3 ]
[ { 1 2 3 } { 1 4 3 } [ over tag over tag ] compile-1 ]
unit-test

[ { 1 2 3 } { 1 4 3 } 8 8 ]
[ { 1 2 3 } { 1 4 3 } [ over type over type ] compile-1 ]
unit-test

! Test literals in either side of a shuffle
[ 4 1 ] [ 1 [ [ 3 fixnum+ ] keep ] compile-1 ] unit-test

[ 2 ] [ 1 2 [ swap fixnum/i ] compile-1 ] unit-test

: foo ;

[ 4 4 ]
[ 1/2 [ tag [ foo ] keep ] compile-1 ]
unit-test

[ 1 2 2 ]
[ 1/2 [ dup 1 slot swap 2 slot [ foo ] keep ] compile-1 ]
unit-test

[ 41 5 4 ] [
    5/4 4/5 [
        dup ratio? [
            over ratio? [
                2dup 2>fraction >r * swap r> * swap
                + -rot denominator swap denominator
            ] [
                2drop f f f
            ] if
        ] [
            2drop f f f
        ] if
    ] compile-1
] unit-test

: jxyz
    over bignum? [
        dup ratio? [
            [ >fraction ] 2apply swapd
            >r 2array swap r> 2array swap
        ] when
    ] when ;

\ jxyz compile

[ { 1 2 } { 1 1 } ] [ 1 >bignum 1/2 jxyz ] unit-test

[ 3 ]
[
    global [ 3 \ foo set ] bind
    \ foo [ global >n get n> drop ] compile-1
] unit-test

: blech drop ;

[ 3 ]
[
    global [ 3 \ foo set ] bind
    \ foo [ global [ get ] swap blech call ] compile-1
] unit-test

[ 3 ]
[
    global [ 3 \ foo set ] bind
    \ foo [ global [ get ] swap >n call n> drop ] compile-1
] unit-test

[ 3 ]
[
    global [ 3 \ foo set ] bind
    \ foo [ global [ get ] bind ] compile-1
] unit-test

[ 12 13 ] [
    -12 -13 [ [ 0 swap fixnum-fast ] 2apply ] compile-1
] unit-test

[ -1 2 ] [ 1 2 [ >r 0 swap fixnum- r> ] compile-1 ] unit-test

[ 12 13 ] [
    -12 -13 [ [ 0 swap fixnum- ] 2apply ] compile-1
] unit-test

[ { t t } ] [
    { t } { t } [
        dup array-capacity [
            2dup swap swap 2 fixnum+fast slot
            >r pick swap 2 fixnum+fast slot r> 2array
        ] collect 2nip
    ] compile-1 first
] unit-test

[ { t t } ] [
    { t } { t } [
        dup array-capacity [
            2dup swap swap 2 fixnum+ slot
            >r pick swap 2 fixnum+ slot r> 2array
        ] collect 2nip
    ] compile-1 first
] unit-test

[ 3.5 ] [ 1 >bignum 2 >bignum [ bignum/f 3 + ] compile-1 ] unit-test
