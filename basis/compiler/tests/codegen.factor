USING: generalizations accessors arrays compiler kernel
kernel.private math hashtables.private math.private namespaces
sequences sequences.private tools.test namespaces.private
slots.private sequences.private byte-arrays alien
alien.accessors layouts words definitions compiler.units io
combinators vectors grouping make ;
IN: compiler.tests.codegen

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

: blech ( x -- ) drop ;

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

[ -1 2 ] [ 1 2 [ [ 0 swap fixnum- ] dip ] compile-call ] unit-test

[ 12 13 ] [
    -12 -13 [ [ 0 swap fixnum- ] bi@ ] compile-call
] unit-test

[ 1 ] [
    SBUF" " [ 1 slot 1 [ slot ] keep ] compile-call nip
] unit-test

! Test slow shuffles
[ 3 1 2 3 4 5 6 7 8 9 ] [
    1 2 3 4 5 6 7 8 9
    [ [ [ [ [ [ [ [ [ [ 3 ] dip ] dip ] dip ] dip ] dip ] dip ] dip ] dip ] dip ]
    compile-call
] unit-test

[ 2 2 2 2 2 2 2 2 2 2 1 ] [
    1 2
    [ swap [ dup dup dup dup dup dup dup dup dup ] dip ] compile-call
] unit-test

[ ] [ [ 9 [ ] times ] compile-call ] unit-test

[ ] [
    [
        [ 200 dup [ 200 3array ] curry map drop ] times
    ] [ (( n -- )) define-temp ] with-compilation-unit drop
] unit-test

! Test how dispatch handles the end of a basic block
: try-breaking-dispatch ( n a b -- x str )
    float+ swap { [ "hey" ] [ "bye" ] } dispatch ;

: try-breaking-dispatch-2 ( -- ? )
    1 1.0 2.5 try-breaking-dispatch "bye" = [ 3.5 = ] dip and ;

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
                [ array-nth ] 2keep [ 1 fixnum+fast ] dip array-nth
                pick 2dup hellish-bug-1 3drop
            ] 2keep
        ] unless [ 2 fixnum+fast ] dip hellish-bug-2
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
[ t 3.0 ] [ 1.0 dup [ dup 2.0 float+ [ eq? ] dip ] compile-call ] unit-test

[ t 3.0 ] [ 1.0 dup [ dup 2.0 float+ ] compile-call [ eq? ] dip ] unit-test

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
    [ 2dup fixnum< [ [ die ] dip ] when ] compile-call
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

! Regression
: dispatch-alignment-regression ( -- c )
    { tuple vector } 3 slot { word } declare
    dup 1 slot 0 fixnum-bitand { [ ] } dispatch ;

[ t ] [ \ dispatch-alignment-regression optimized>> ] unit-test

[ vector ] [ dispatch-alignment-regression ] unit-test

! Regression
: bad-value-bug ( a -- b ) [ 3 ] [ 3 ] if f <array> ;

[ { f f f } ] [ t bad-value-bug ] unit-test

! PowerPC regression
TUPLE: id obj ;

: (gc-check-bug) ( a b -- c )
    { [ id boa ] [ id boa ] } dispatch ;

: gc-check-bug ( -- )
    10000000 [ "hi" 0 (gc-check-bug) drop ] times ;

[ ] [ gc-check-bug ] unit-test

! New optimization
: test-1 ( a -- b ) 8 fixnum-fast { [ "a" ] [ "b" ] } dispatch ;

[ "a" ] [ 8 test-1 ] unit-test
[ "b" ] [ 9 test-1 ] unit-test

: test-2 ( a -- b ) 1 fixnum-fast { [ "a" ] [ "b" ] } dispatch ;

[ "a" ] [ 1 test-2 ] unit-test
[ "b" ] [ 2 test-2 ] unit-test

! I accidentally fixnum/i-fast on PowerPC
[ { { 1 2 } { 3 4 } } ] [
    { 1 2 3 4 }
    [
        [ { array } declare 2 <groups> [ , ] each ] compile-call
    ] { } make
] unit-test

[ 2 ] [
    { 1 2 3 4 }
    [ { array } declare 2 <groups> length ] compile-call
] unit-test

! Oops with new intrinsics
: fixnum-overflow-control-flow-test ( a b -- c )
    [ 1 fixnum- ] [ 2 fixnum- ] if 3 fixnum+fast ;

[ 3 ] [ 1 t fixnum-overflow-control-flow-test ] unit-test
[ 2 ] [ 1 f fixnum-overflow-control-flow-test ] unit-test

! LOL
: blah ( a -- b )
    { float } declare dup 0 =
    [ drop 1 ] [
        dup 0 >=
        [ 2 "double" "libm" "pow" { "double" "double" } alien-invoke ]
        [ -0.5 "double" "libm" "pow" { "double" "double" } alien-invoke ]
        if
    ] if ;

[ 4.0 ] [ 2.0 blah ] unit-test

[ 4 ] [ 2 [ dup fixnum* ] compile-call ] unit-test
[ 7 ] [ 2 [ dup fixnum* 3 fixnum+fast ] compile-call ] unit-test

TUPLE: cucumber ;

M: cucumber equal? "The cucumber has no equal" throw ;

[ t ] [ [ cucumber ] compile-call cucumber eq? ] unit-test
