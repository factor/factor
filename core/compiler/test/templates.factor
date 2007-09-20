! Black box testing of templater optimization

USING: arrays compiler kernel kernel.private math
hashtables.private math.private math.ratios.private namespaces
sequences sequences.private tools.test namespaces.private
slots.private combinators.private ;
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
    \ foo [ global >n get ndrop ] compile-1
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
    \ foo [ global [ get ] swap >n call ndrop ] compile-1
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

[ 2 ] [
    SBUF" " [ 2 slot 2 [ slot ] keep ] compile-1 nip
] unit-test

! Test slow shuffles
[ 3 1 2 3 4 5 6 7 8 9 ] [
    1 2 3 4 5 6 7 8 9
    [ >r >r >r >r >r >r >r >r >r 3 r> r> r> r> r> r> r> r> r> ]
    compile-1
] unit-test

[ 2 2 2 2 2 2 2 2 2 2 1 ] [
    1 2
    [ swap >r dup dup dup dup dup dup dup dup dup r> ] compile-1
] unit-test

[ ] [ [ 9 [ ] times ] compile-1 ] unit-test

[ ] [
    [
        [ 200 dup [ 200 3array ] curry map drop ] times
    ] compile-quot drop
] unit-test


! Test how dispatch handles the end of a basic block
: try-breaking-dispatch
    float+ swap { [ "hey" ] [ "bye" ] } dispatch ;

: try-breaking-dispatch-2
    1 1.0 2.5 try-breaking-dispatch "bye" = >r 3.5 = r> and ;

[ t ] [
    10000000 [ drop try-breaking-dispatch-2 ] all?
] unit-test

! Regression
: (broken) ( x -- y ) ;

[ 2.0 { 2.0 0.0 } ] [
    2.0 1.0
    [ float/f 0.0 [ drop (broken) ] 2keep 2array ] compile-1
] unit-test

! Regression
: hellish-bug-1 2drop ;

: hellish-bug-2 ( i array x -- x ) 
    2dup 1 slot eq? [ 2drop ] [ 
        2dup array-nth tombstone? [ 
            [
                [ array-nth ] 2keep >r 1 fixnum+fast r> array-nth
                pick 2dup hellish-bug-1 3drop
            ] 2keep
        ] unless >r 2 fixnum+fast r> hellish-bug-2
    ] if ; inline

: hellish-bug-3 ( hash array -- ) 
    0 swap hellish-bug-2 drop ;

[ ] [
    H{ { 1 2 } { 3 4 } } dup hash-array
    [ 0 swap hellish-bug-2 drop ] compile-1
] unit-test

! Regression
: foox
    dup not
    [ drop 3 ] [ dup tuple? [ drop 4 ] [ drop 5 ] if ] if ;

[ 3 ] [ f foox ] unit-test

TUPLE: my-tuple ;

[ 4 ] [ T{ my-tuple } foox ] unit-test

[ 5 ] [ "hi" foox ] unit-test
