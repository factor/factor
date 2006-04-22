! Black box testing of templater optimization

IN: temporary
USING: arrays compiler kernel kernel-internals math
math-internals namespaces test ;

! Oops!
[ 5000 ] [ [ 5000 ] compile-1 ] unit-test
[ "hi" ] [ [ "hi" ] compile-1 ] unit-test

[ 1 2 3 4 ] [ [ 1 2 3 4 ] compile-1 ] unit-test

[ 1 1 ] [ 1 [ dup ] compile-1 ] unit-test
[ 0 ] [ 3 [ tag ] compile-1 ] unit-test
[ 0 3 ] [ 3 [ [ tag ] keep ] compile-1 ] unit-test

[ 2 3 ] [ 3 [ 2 swap ] compile-1 ] unit-test

[ 2 3 4 ] [ 3 [ 2 swap 4 ] compile-1 ] unit-test

[ { 1 2 3 } { 1 4 3 } 3 3 ]
[ { 1 2 3 } { 1 4 3 } [ over tag over tag ] compile-1 ]
unit-test

[ { 1 2 3 } { 1 4 3 } 8 8 ]
[ { 1 2 3 } { 1 4 3 } [ over type over type ] compile-1 ]
unit-test

! Test literals in either side of a shuffle
[ 4 1 ] [ 1 [ [ 3 fixnum+ ] keep ] compile-1 ] unit-test

: foo ;

[ 4 4 ]
[ 1/2 [ tag [ foo ] keep ] compile-1 ]
unit-test

[ 1 2 2 ]
[ 1/2 [ dup 0 slot swap 1 slot [ foo ] keep ] compile-1 ]
unit-test

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
