USING: accessors alien alien.accessors alien.c-types alien.data
alien.parser alien.strings alien.syntax alien.varargs alien.varargs.private
arrays byte-arrays classes.struct compiler.test concurrency.futures continuations
cpu.architecture io.encodings.utf8 kernel libc locals math
math.floats.small.c-types math.vectors.simd namespaces sequences
system tools.test ;
IN: alien.varargs.tests

STRUCT: va-pair { x longlong } { y longlong } ;
STRUCT: va-triple { x longlong } { y longlong } { z longlong } ;
STRUCT: va-hfa { x double } { y double } ;
STRUCT: va-nested-hfa { x va-hfa } { y va-hfa } ;
STRUCT: va-array-hfa { values double[3] } ;
STRUCT: va-small-hfa { x half } { y bfloat } ;
STRUCT: va-hva { x float-4 } { y float-4 } ;

:: with-va-memory ( quot -- )
    512 malloc :> memory
    [ [ memory quot call ] with-va-scope ] [ memory free ] finally ; inline

:: cursor-at ( memory platform -- cursor )
    256 memory <displaced-alien>
    64 memory <displaced-alien>
    192 memory <displaced-alien>
    -64 -128 platform <platform-va-cursor> ;

! A macOS anonymous slot occupies eight bytes even for a promoted char.
{ -7 3.5 42 } [
    [| mem |
        -7 mem 256 set-alien-signed-4
        3.5 mem 264 set-alien-double
        42 mem 272 set-alien-signed-8
        mem macos cursor-at :> cursor
        cursor char va-arg cursor double va-arg cursor longlong va-arg
    ] with-va-memory
] unit-test

! Copies advance independently, including copies of partially read lists.
{ 11 22 22 } [
    [| mem |
        11 mem 256 set-alien-signed-4 22 mem 264 set-alien-signed-4
        mem macos cursor-at :> cursor
        cursor int va-arg
        cursor va-copy :> copy
        cursor int va-arg copy int va-arg
    ] with-va-memory
] unit-test

! Linux has independent general-purpose and floating-point cursors.
{ 123 2.5 456 } [
    [| mem |
        123 mem 0 set-alien-signed-4 456 mem 8 set-alien-signed-4
        2.5 mem 64 set-alien-double
        mem linux cursor-at :> cursor
        cursor int va-arg cursor double va-arg cursor int va-arg
    ] with-va-memory
] unit-test

{ 7 8 } [
    [| mem |
        7 mem 56 set-alien-signed-4 8 mem 256 set-alien-signed-4
        mem linux cursor-at -8 >>gr-offs :> cursor
        cursor int va-arg cursor int va-arg
    ] with-va-memory
] unit-test

! Linux cannot split a composite between x7 and the stack.
{ 17 19 23 } [
    [| mem |
        999 mem 56 set-alien-signed-8
        17 mem 256 set-alien-signed-8 19 mem 264 set-alien-signed-8
        23 mem 272 set-alien-signed-4
        mem linux cursor-at -8 >>gr-offs :> cursor
        cursor va-pair va-arg [ x>> ] [ y>> ] bi
        cursor int va-arg
    ] with-va-memory
] unit-test

! Windows sees a contiguous saved-register/stack span and permits a split.
{ 17 19 23 } [
    [| mem |
        17 mem 56 set-alien-signed-8 19 mem 64 set-alien-signed-8
        23 mem 72 set-alien-signed-4
        mem windows cursor-at 56 mem <displaced-alien> >>stack :> cursor
        cursor va-pair va-arg [ x>> ] [ y>> ] bi
        cursor int va-arg
    ] with-va-memory
] unit-test

! HFA elements occupy separate 16-byte SIMD save slots, but boxed structs
! must own a compact copy, independent of the original callback frame.
{ 1.5 2.5 } [
    [| mem |
        1.5 mem 64 set-alien-double 2.5 mem 80 set-alien-double
        mem linux cursor-at va-hfa va-arg :> value
        100.0 mem 64 set-alien-double
        value [ x>> ] [ y>> ] bi
    ] with-va-memory
] unit-test

{ 1.0 2.0 3.0 4.0 } [
    [| mem |
        1.0 mem 64 set-alien-double 2.0 mem 80 set-alien-double
        3.0 mem 96 set-alien-double 4.0 mem 112 set-alien-double
        mem linux cursor-at va-nested-hfa va-arg
        [ x>> [ x>> ] [ y>> ] bi ] [ y>> [ x>> ] [ y>> ] bi ] bi
    ] with-va-memory
] unit-test

! Exhausted HFA banks advance to a compact stack object, then the next slot.
{ 3.0 4.0 5.0 } [
    [| mem |
        999.0 mem 176 set-alien-double
        3.0 mem 256 set-alien-double 4.0 mem 264 set-alien-double
        5.0 mem 272 set-alien-double
        mem linux cursor-at -16 >>vr-offs :> cursor
        cursor va-hfa va-arg [ x>> ] [ y>> ] bi
        cursor double va-arg
    ] with-va-memory
] unit-test

{ 11 22 33 } [
    [| mem |
        320 mem <displaced-alien> mem 0 set-alien-cell
        11 mem 320 set-alien-signed-8 22 mem 328 set-alien-signed-8
        33 mem 336 set-alien-signed-8
        mem linux cursor-at va-triple va-arg
        [ x>> ] [ y>> ] [ z>> ] tri
    ] with-va-memory
] unit-test

{ { 1.0 2.0 3.0 } } [
    [| mem |
        1.0 mem 64 set-alien-double 2.0 mem 80 set-alien-double
        3.0 mem 96 set-alien-double
        mem linux cursor-at va-array-hfa va-arg values>> >array
    ] with-va-memory
] unit-test

cpu arm.64? [
    { 1.0 2.0 } [
        [| mem |
            0x3c00 mem 64 set-alien-unsigned-2
            0x4000 mem 80 set-alien-unsigned-2
            mem linux cursor-at va-small-hfa va-arg [ x>> ] [ y>> ] bi
        ] with-va-memory
    ] unit-test
] [
    ! The synthetic register layout must not bypass the scalar FFI's
    ! architecture restriction just because the payload is only 16 bits.
    [ half c-type-rep ] [ small-float-scalar-abi-unsupported? ] must-fail-with
    [ bfloat c-type-rep ] [ small-float-scalar-abi-unsupported? ] must-fail-with
] if

{ { 1.0 2.0 3.0 4.0 } { 5.0 6.0 7.0 8.0 } } [
    [| mem |
        1.0 mem 64 set-alien-float 2.0 mem 68 set-alien-float
        3.0 mem 72 set-alien-float 4.0 mem 76 set-alien-float
        5.0 mem 80 set-alien-float 6.0 mem 84 set-alien-float
        7.0 mem 88 set-alien-float 8.0 mem 92 set-alien-float
        mem linux cursor-at va-hva va-arg
        [ x>> >array ] [ y>> >array ] bi
    ] with-va-memory
] unit-test

! A spilled short vector rounds the stack cursor up to a 16-byte boundary.
{ { 1.0 2.0 3.0 4.0 } 23 } [
    [| mem |
        1.0 mem 272 set-alien-float 2.0 mem 276 set-alien-float
        3.0 mem 280 set-alien-float 4.0 mem 284 set-alien-float
        23 mem 288 set-alien-signed-4
        mem linux cursor-at 0 >>vr-offs 0 >>gr-offs
            264 mem <displaced-alien> >>stack :> cursor
        cursor float-4 va-arg >array cursor int va-arg
    ] with-va-memory
] unit-test

! Expanding a SIMD type's boxer while its inline type constant is active
! must not recursively execute that type word. Check optimizing compilation,
! not only the interpreter's va-arg macro fallback.
{ { 1.0 2.0 3.0 4.0 } } [
    [
        [| mem |
            1.0 mem 64 set-alien-float 2.0 mem 68 set-alien-float
            3.0 mem 72 set-alien-float 4.0 mem 76 set-alien-float
            mem linux cursor-at float-4 va-arg >array
        ] with-va-memory
    ] compile-call
] unit-test

! Windows variadic short vectors use only eight-byte alignment, including
! a value starting in x1 and a value split between x7 and incoming stack.
{ { 1.0 2.0 3.0 4.0 } 23 } [
    [| mem |
        1.0 mem 56 set-alien-float 2.0 mem 60 set-alien-float
        3.0 mem 64 set-alien-float 4.0 mem 68 set-alien-float
        23 mem 72 set-alien-signed-4
        mem windows cursor-at 56 mem <displaced-alien> >>stack :> cursor
        cursor float-4 va-arg >array cursor int va-arg
    ] with-va-memory
] unit-test

! Windows homogeneous structs obey the ordinary integer/indirect rules.
{ 1.0 2.0 3.0 4.0 } [
    [| mem |
        320 mem <displaced-alien> mem 256 set-alien-cell
        1.0 mem 320 set-alien-double 2.0 mem 328 set-alien-double
        3.0 mem 336 set-alien-double 4.0 mem 344 set-alien-double
        mem windows cursor-at va-nested-hfa va-arg
        [ x>> [ x>> ] [ y>> ] bi ] [ y>> [ x>> ] [ y>> ] bi ] bi
    ] with-va-memory
] unit-test

SYMBOL: escaped-cursor
SYMBOL: escaped-copy

{ } [
    [| mem |
        mem macos cursor-at dup escaped-cursor set-global
        va-copy escaped-copy set-global
    ] with-va-memory
] unit-test

[ escaped-cursor get int va-arg ] [ expired-va-list? ] must-fail-with
[ escaped-copy get va-copy ] [ expired-va-list? ] must-fail-with

! Exceptional scope cleanup expires every copy too.
{ } [
    [
        [| mem |
            mem macos cursor-at dup escaped-cursor set-global
            va-copy escaped-copy set-global
            "scope cleanup test" throw
        ] with-va-memory
    ] [ drop ] recover
] unit-test
[ escaped-cursor get int va-arg ] [ expired-va-list? ] must-fail-with
[ escaped-copy get int va-arg ] [ expired-va-list? ] must-fail-with

! A different Factor thread cannot read a live callback's borrowed memory.
{ t } [
    [| mem |
        mem macos cursor-at :> cursor
        [ [ cursor va-copy drop f ] [ expired-va-list? ] recover ] future ?future
    ] with-va-memory
] unit-test

[ f f f 0 0 macos <platform-va-cursor> ]
[ va-list-outside-callback-scope? ] must-fail-with

{ t t f } [
    va_list native-va-list-type? cpu arm.64? =
    va_list lookup-c-type native-va-list-type? cpu arm.64? =
    int native-va-list-type?
] unit-test

cpu arm.64? [
    ! Keep declarations in a separately loaded file: parser words inside a
    ! false quotation still execute while the surrounding source is parsed.
    "resource:basis/alien/varargs/native/forwarding.factor" run-test-file
] when
