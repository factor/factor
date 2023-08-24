USING: tools.test alien.syntax specialized-arrays sequences
alien accessors kernel arrays combinators compiler
compiler.units classes.struct combinators.smart
compiler.tree.debugger math libc destructors sequences.private
multiline eval words vocabs namespaces assocs prettyprint
alien.data math.vectors definitions compiler.test ;
FROM: specialized-arrays.private => specialized-array-vocab ;
FROM: alien.c-types => int float bool uchar char float ulonglong ushort uint
heap-size ;
FROM: alien.data => little-endian? ;
IN: specialized-arrays.tests

SPECIALIZED-ARRAY: int
SPECIALIZED-ARRAYS: bool uchar ushort char uint float ulonglong ;

{ t } [ { 1 2 3 } int >c-array int-array? ] unit-test

{ t } [ int-array{ 1 2 3 } int-array? ] unit-test

{ 2 } [ int-array{ 1 2 3 } second ] unit-test

{ t } [
    { t f t } bool >c-array underlying>>
    { 1 0 1 } bool heap-size {
        { 1 [ char >c-array ] }
        { 4 [ uint >c-array ] }
    } case underlying>> =
] unit-test

{ ushort-array{ 1234 } } [
    little-endian? B{ 210 4 } B{ 4 210 } ? ushort cast-array
] unit-test

[ B{ 210 4 1 } ushort cast-array ] must-fail

{ { 3 1 3 3 7 } } [
    int-array{ 3 1 3 3 7 } malloc-byte-array [ &free 5 int <c-direct-array> >array ] with-destructors
] unit-test

{ float-array{ 0x1.222,222p0   0x1.111,112p0   } }
[ float-array{ 0x1.222,222,2p0 0x1.111,111,1p0 } ] unit-test

{ f } [ float-array{ 4 3 2 1 } dup clone [ underlying>> ] bi@ eq? ] unit-test

{ f } [ [ float-array{ 4 3 2 1 } dup clone [ underlying>> ] bi@ eq? ] compile-call ] unit-test

{ ushort-array{ 0 0 0 } } [
    3 ALIEN: 123 100 <direct-ushort-array> new-sequence
    [ drop 0 ] map!
] unit-test

STRUCT: test-struct
    { x int }
    { y int } ;

SPECIALIZED-ARRAY: test-struct

{ 1 } [
    1 test-struct-array{ } new-sequence length
] unit-test

{ V{ test-struct } } [
    [ [ test-struct-array <struct> ] test-struct-array{ } output>sequence first ] final-classes
] unit-test

: make-point ( x y -- struct )
    test-struct boa ;

{ 5/4 } [
    2 <test-struct-array>
    1 2 make-point over set-first
    3 4 make-point over set-second
    0 [ [ x>> ] [ y>> ] bi / + ] reduce
] unit-test

{ 5/4 } [
    [
        2 \ test-struct malloc-array
        dup &free drop
        1 2 make-point over set-first
        3 4 make-point over set-second
        0 [ [ x>> ] [ y>> ] bi / + ] reduce
    ] with-destructors
] unit-test

{ } [ ALIEN: 123 10 <direct-test-struct-array> drop ] unit-test

{ } [
    [
        10 \ test-struct malloc-array
        &free drop
    ] with-destructors
] unit-test

{ 15 } [ 15 10 <test-struct-array> resize length ] unit-test

{ S{ test-struct f 12 20 } } [
    test-struct-array{
        S{ test-struct f  4 20 }
        S{ test-struct f 12 20 }
        S{ test-struct f 20 20 }
    } second
] unit-test

{ } [
    [
        test-struct specialized-array-vocab forget-vocab
    ] with-compilation-unit
] unit-test

! Regression
STRUCT: fixed-string { text char[64] } ;

SPECIALIZED-ARRAY: fixed-string

{ { ALIEN: 100 ALIEN: 140 ALIEN: 180 ALIEN: 1c0 } } [
    ALIEN: 100 4 <direct-fixed-string-array> [ (underlying)>> ] { } map-as
] unit-test

! Ensure that byte-length works with direct arrays
{ 400 } [
    ALIEN: 123 100 <direct-int-array> byte-length
] unit-test

{ } [
    [
        fixed-string specialized-array-vocab forget-vocab
    ] with-compilation-unit
] unit-test

! Test prettyprinting
{ "int-array{ 1 2 3 }" } [ int-array{ 1 2 3 } unparse ] unit-test
{ "c-array@ int f 100" } [ f 100 <direct-int-array> unparse ] unit-test

! If the C type doesn't exist, don't generate a vocab
SYMBOL: __does_not_exist__

[
    "
IN: specialized-arrays.tests
USING: specialized-arrays ;

SPECIALIZED-ARRAY: __does_not_exist__ " eval( -- )
] must-fail

{ } [
    "
IN: specialized-arrays.tests
USING: alien.c-types classes.struct specialized-arrays ;

STRUCT: __does_not_exist__ { x int } ;

SPECIALIZED-ARRAY: __does_not_exist__
" eval( -- )
] unit-test

{ f } [
    "__does_not_exist__-array{"
    __does_not_exist__ specialized-array-vocab lookup-word
    deferred?
] unit-test

{ } [
    [
        \ __does_not_exist__ forget
        __does_not_exist__ specialized-array-vocab forget-vocab
    ] with-compilation-unit
] unit-test

STRUCT: struct-resize-test { x int } ;

SPECIALIZED-ARRAY: struct-resize-test

{ 40 } [ 10 <struct-resize-test-array> byte-length ] unit-test

: struct-resize-test-usage ( seq -- seq )
    [ struct-resize-test <struct> swap >>x ] map
    \ struct-resize-test >c-array
    [ x>> ] { } map-as ;

{ { 10 20 30 } } [ { 10 20 30 } struct-resize-test-usage ] unit-test

{ } [ "IN: specialized-arrays.tests USE: classes.struct USE: alien.c-types STRUCT: struct-resize-test { x int } { y int } ;" eval( -- ) ] unit-test

{ 80 } [ 10 <struct-resize-test-array> byte-length ] unit-test

{ { 10 20 30 } } [ { 10 20 30 } struct-resize-test-usage ] unit-test

{ } [
    [
        struct-resize-test specialized-array-vocab forget-vocab
        \ struct-resize-test-usage forget
    ] with-compilation-unit
] unit-test

{ int-array{ 4 5 6 } } [ 3 6 int-array{ 1 2 3 4 5 6 7 8 } direct-slice ] unit-test
{ int-array{ 1 2 3 } } [ int-array{ 1 2 3 4 5 6 7 8 } 3 direct-head ] unit-test
{ int-array{ 1 2 3 4 5 } } [ int-array{ 1 2 3 4 5 6 7 8 } 3 direct-head* ] unit-test
{ int-array{ 4 5 6 7 8 } } [ int-array{ 1 2 3 4 5 6 7 8 } 3 direct-tail ] unit-test
{ int-array{ 6 7 8 } } [ int-array{ 1 2 3 4 5 6 7 8 } 3 direct-tail* ] unit-test

{ uchar-array{ 0 1 255 } } [ 3 6 B{ 1 1 1 0 1 255 2 2 2 } direct-slice ] unit-test

{ int-array{ 1 2 3 4 55555 6 7 8 } } [
    int-array{ 1 2 3 4 5 6 7 8 }
    3 6 pick direct-slice [ 55555 1 ] dip set-nth
] unit-test
