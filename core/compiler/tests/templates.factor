! Black box testing of templating optimization
USING: arrays compiler kernel kernel.private math
hashtables.private math.private namespaces sequences
sequences.private tools.test namespaces.private slots.private
sequences.private byte-arrays alien alien.accessors layouts
words definitions compiler.units io combinators ;
IN: compiler.tests

! Oops!
[ 5000 ] [ [ 5000 ] compile-call ] unit-test
[ "hi" ] [ [ "hi" ] compile-call ] unit-test

[ 1 2 3 4 ] [ [ 1 2 3 4 ] compile-call ] unit-test

[ 1 1 ] [ 1 [ dup ] compile-call ] unit-test
[ 0 ] [ 3 [ tag ] compile-call ] unit-test
[ 0 3 ] [ 3 [ [ tag ] keep ] compile-call ] unit-test

[ 2 3 ] [ 3 [ 2 swap ] compile-call ] unit-test

[ 2 1 3 4 ] [ 1 2 [ swap 3 4 ] compile-call ] unit-test

[ 2 3 4 ] [ 3 [ 2 swap 4 ] compile-call ] unit-test

[ { 1 2 3 } { 1 4 3 } 3 3 ]
[ { 1 2 3 } { 1 4 3 } [ over tag over tag ] compile-call ]
unit-test

[ { 1 2 3 } { 1 4 3 } 8 8 ]
[ { 1 2 3 } { 1 4 3 } [ over type over type ] compile-call ]
unit-test

! Test literals in either side of a shuffle
[ 4 1 ] [ 1 [ [ 3 fixnum+ ] keep ] compile-call ] unit-test

[ 2 ] [ 1 2 [ swap fixnum/i ] compile-call ] unit-test

: foo ;

[ 5 5 ]
[ 1.2 [ tag [ foo ] keep ] compile-call ]
unit-test

[ 1 2 2 ]
[ { 1 2 } [ dup 2 slot swap 3 slot [ foo ] keep ] compile-call ]
unit-test

[ 3 ]
[
    global [ 3 \ foo set ] bind
    \ foo [ global >n get ndrop ] compile-call
] unit-test

: blech drop ;

[ 3 ]
[
    global [ 3 \ foo set ] bind
    \ foo [ global [ get ] swap blech call ] compile-call
] unit-test

[ 3 ]
[
    global [ 3 \ foo set ] bind
    \ foo [ global [ get ] swap >n call ndrop ] compile-call
] unit-test

[ 3 ]
[
    global [ 3 \ foo set ] bind
    \ foo [ global [ get ] bind ] compile-call
] unit-test

[ 12 13 ] [
    -12 -13 [ [ 0 swap fixnum-fast ] 2apply ] compile-call
] unit-test

[ -1 2 ] [ 1 2 [ >r 0 swap fixnum- r> ] compile-call ] unit-test

[ 12 13 ] [
    -12 -13 [ [ 0 swap fixnum- ] 2apply ] compile-call
] unit-test

[ 1 ] [
    SBUF" " [ 1 slot 1 [ slot ] keep ] compile-call nip
] unit-test

! Test slow shuffles
[ 3 1 2 3 4 5 6 7 8 9 ] [
    1 2 3 4 5 6 7 8 9
    [ >r >r >r >r >r >r >r >r >r 3 r> r> r> r> r> r> r> r> r> ]
    compile-call
] unit-test

[ 2 2 2 2 2 2 2 2 2 2 1 ] [
    1 2
    [ swap >r dup dup dup dup dup dup dup dup dup r> ] compile-call
] unit-test

[ ] [ [ 9 [ ] times ] compile-call ] unit-test

[ ] [
    [
        [ 200 dup [ 200 3array ] curry map drop ] times
    ] [ define-temp ] with-compilation-unit drop
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
    [ float/f 0.0 [ drop (broken) ] 2keep 2array ] compile-call
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
    [ 0 swap hellish-bug-2 drop ] compile-call
] unit-test

! Regression
: foox
    dup not
    [ drop 3 ] [ dup tuple? [ drop 4 ] [ drop 5 ] if ] if ;

[ 3 ] [ f foox ] unit-test

TUPLE: my-tuple ;

[ 4 ] [ T{ my-tuple } foox ] unit-test

[ 5 ] [ "hi" foox ] unit-test

! Making sure we don't needlessly unbox/rebox
[ t 3.0 ] [ 1.0 dup [ dup 2.0 float+ >r eq? r> ] compile-call ] unit-test

[ t 3.0 ] [ 1.0 dup [ dup 2.0 float+ ] compile-call >r eq? r> ] unit-test

[ t ] [ 1.0 dup [ [ 2.0 float+ ] keep ] compile-call nip eq? ] unit-test

[ 1 B{ 1 2 3 4 } ] [
    B{ 1 2 3 4 } [
        { byte-array } declare
        [ 0 alien-unsigned-1 ] keep
    ] compile-call
] unit-test

[ 1 t ] [
    B{ 1 2 3 4 } [
        { c-ptr } declare
        [ 0 alien-unsigned-1 ] keep type
    ] compile-call byte-array type-number =
] unit-test

[ t ] [
    B{ 1 2 3 4 } [
        { c-ptr } declare
        0 alien-cell type
    ] compile-call alien type-number =
] unit-test

[ 2 1 ] [
    2 1
    [ 2dup fixnum< [ >r die r> ] when ] compile-call
] unit-test

! Regression
: a-dummy drop "hi" print ;

[ ] [
    1 [
        dup 0 2 3dup pick >= [ >= ] [ 2drop f ] if [
            drop - >fixnum {
                [ a-dummy ]
                [ a-dummy ]
                [ a-dummy ]
            } dispatch
        ] [ 2drop no-case ] if
    ] compile-call
] unit-test
