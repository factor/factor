USING: generalizations accessors arrays compiler kernel
kernel.private math hashtables.private math.private namespaces
sequences sequences.private tools.test namespaces.private
slots.private sequences.private byte-arrays alien
alien.accessors layouts words definitions compiler.units io
combinators vectors ;
IN: compiler.tests

! Originally, this file did black box testing of templating
! optimization. We now have a different codegen, but the tests
! in here are still useful.

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

! Test literals in either side of a shuffle
[ 4 1 ] [ 1 [ [ 3 fixnum+ ] keep ] compile-call ] unit-test

[ 2 ] [ 1 2 [ swap fixnum/i ] compile-call ] unit-test

: foo ( -- ) ;

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
    -12 -13 [ [ 0 swap fixnum-fast ] bi@ ] compile-call
] unit-test

[ -1 2 ] [ 1 2 [ >r 0 swap fixnum- r> ] compile-call ] unit-test

[ 12 13 ] [
    -12 -13 [ [ 0 swap fixnum- ] bi@ ] compile-call
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
: try-breaking-dispatch ( n a b -- x str )
    float+ swap { [ "hey" ] [ "bye" ] } dispatch ;

: try-breaking-dispatch-2 ( -- ? )
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
: hellish-bug-1 ( a b -- ) 2drop ;

: hellish-bug-2 ( i array x -- x ) 
    2dup 1 slot eq? [ 2drop ] [ 
        2dup array-nth tombstone? [ 
            [
                [ array-nth ] 2keep >r 1 fixnum+fast r> array-nth
                pick 2dup hellish-bug-1 3drop
            ] 2keep
        ] unless >r 2 fixnum+fast r> hellish-bug-2
    ] if ; inline recursive

: hellish-bug-3 ( hash array -- ) 
    0 swap hellish-bug-2 drop ;

[ ] [
    H{ { 1 2 } { 3 4 } } dup array>>
    [ 0 swap hellish-bug-2 drop ] compile-call
] unit-test

! Regression
: foox ( obj -- obj )
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
        [ 0 alien-unsigned-1 ] keep hi-tag
    ] compile-call byte-array type-number =
] unit-test

[ t ] [
    B{ 1 2 3 4 } [
        { c-ptr } declare
        0 alien-cell hi-tag
    ] compile-call alien type-number =
] unit-test

[ 2 1 ] [
    2 1
    [ 2dup fixnum< [ >r die r> ] when ] compile-call
] unit-test

! Regression
: a-dummy ( a -- ) drop "hi" print ;

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

: float-spill-bug ( a -- b b b b b b b b b b b b b b b b b b b b b b b b b b b b b b b b b b b b b b )
    {
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
        [ dup float+ ]
    } cleave ;

[ 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 2.0 ]
[ 1.0 float-spill-bug ] unit-test

[ t ] [ \ float-spill-bug compiled>> ] unit-test

: float-fixnum-spill-bug ( object -- object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object object )
    {
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
        [ dup float+ ]
        [ float>fixnum dup fixnum+fast ]
    } cleave ;

[ 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 2.0 2 ]
[ 1.0 float-fixnum-spill-bug ] unit-test

[ t ] [ \ float-fixnum-spill-bug compiled>> ] unit-test

: resolve-spill-bug ( a b -- c )
    [ 1 fixnum+fast ] bi@ dup 10 fixnum< [
        nip 2 fixnum+fast
    ] [
        drop {
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
            [ dup fixnum+fast ]
        } cleave
        16 narray
    ] if ;

[ t ] [ \ resolve-spill-bug compiled>> ] unit-test

[ 4 ] [ 1 1 resolve-spill-bug ] unit-test

! Regression
: dispatch-alignment-regression ( -- c )
    { tuple vector } 3 slot { word } declare
    dup 1 slot 0 fixnum-bitand { [ ] } dispatch ;

[ t ] [ \ dispatch-alignment-regression compiled>> ] unit-test

[ vector ] [ dispatch-alignment-regression ] unit-test
