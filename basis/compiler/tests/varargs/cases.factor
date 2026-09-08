! These expected values come from independent C controls in ffi_test_varargs.c.
USING: accessors alien alien.c-types alien.libraries alien.strings
alien.syntax alien.varargs arrays byte-arrays classes.struct combinators compiler.test
io.encodings.utf8 io.pathnames kernel libc locals math memory namespaces
sequences specialized-arrays system tools.test ;
FROM: alien.c-types => float short ;
IN: compiler.tests.alien-varargs

<<
"varargs-fixture" "resource:" absolute-path os {
    { windows [ "libfactor-ffi-test.dll" ] }
    { macos [ "libfactor-ffi-test.dylib" ] }
    [ drop "libfactor-ffi-test.so" ]
} case append-path cdecl add-library
>>
LIBRARY: varargs-fixture
FUNCTION: uint va_c_controls ( )
FUNCTION: longlong va_call_ints ( void* cb, int count )
FUNCTION: double va_call_mixed ( void* cb )
FUNCTION: double va_call_named_spill ( void* cb )
FUNCTION: double va_call_aggregates ( void* cb )
FUNCTION: longlong va_call_big_return ( void* cb )
FUNCTION: double va_call_pair_return ( void* cb )
FUNCTION: longlong va_call_list ( void* cb, int count )
FUNCTION: int va_call_format_list ( void* cb )
FUNCTION: longlong va_sum_list ( int count, va_list args )

{ 255 } [ [ va_c_controls ] compile-call ] unit-test

CALLBACK: longlong int-reader ( int count, ... )
:: read-ints ( count args -- sum )
    count <iota> [ 1 + args int va-arg * ] map sum ;
{ 0 } [ [ [ read-ints ] int-reader [ 0 va_call_ints ] with-callback ] compile-call ] unit-test
{ -1 } [ [ [ read-ints ] int-reader [ 1 va_call_ints ] with-callback ] compile-call ] unit-test
{ -28 } [ [ [ read-ints ] int-reader [ 7 va_call_ints ] with-callback ] compile-call ] unit-test
{ 78 } [ [ [ read-ints ] int-reader [ 12 va_call_ints ] with-callback ] compile-call ] unit-test
{ 78 } [ [ [ gc read-ints ] int-reader [ 12 va_call_ints ] with-callback ] compile-call ] unit-test

! Use the primitive interface as well as the parser-generated constructor.
:: read-mixed ( tag named args -- result )
    10 <iota> [| i | i 1 + args int va-arg * i 11 + args double va-arg * + ] map sum
    tag + named + ;
{ 1259.75 } [ [
    double { int double } cdecl [ read-mixed ] alien-callback-varargs
    [ va_call_mixed ] with-callback
] compile-call ] unit-test

CALLBACK: double named-spill-reader (
    int a, int b, int c, int d, int e, int f, int g, int h, int i, int j,
    ... char k, float l, longlong m, short n )
{ 86.0 } [ [
    [| a b c d e f g h i j k l m n |
        a b + c + d + e + f + g + h + i + j + k + l 2 * + m 3 * + n 4 * +
    ] named-spill-reader [ va_call_named_spill ] with-callback
] compile-call ] unit-test

STRUCT: va-pair { x float } { y float } ;
STRUCT: va-ints { x int } { y int } ;
STRUCT: va-big { x longlong } { y longlong } { z longlong } ;
SPECIALIZED-ARRAY: float
STRUCT: va-array { values float[3] } ;
CALLBACK: double aggregate-reader ( int tag, ... )
:: read-aggregates ( tag args -- result )
    args va-pair va-arg :> p
    args va-ints va-arg :> i
    args va-big va-arg :> b
    args va-array va-arg :> a
    args longlong va-arg :> sentinel
    ! Collected aggregate values must own their storage.
    gc
    tag p x>> + p y>> 2 * + i x>> 3 * + i y>> 4 * +
    b x>> 5 * + b y>> 6 * + b z>> 7 * +
    a values>> first 8 * + a values>> second 9 * + a values>> third 10 * +
    sentinel 11 * + ;
{ 5.0 } [ [ [ read-aggregates ] aggregate-reader [ va_call_aggregates ] with-callback ] compile-call ] unit-test

FUNCTION: double va_call_hfa_spill ( void* cb )
FUNCTION: int va_hfa_spill_control ( )
{ 1 } [ [ va_hfa_spill_control ] compile-call ] unit-test
CALLBACK: double hfa-spill-reader (
    double a, double b, double c, double d, double e, double f, double g, int tag,
    ... va-pair p, double value, va-array array, int integer )
{ 364.0 } [ [
    [| a b c d e f g tag p value array integer |
        a b + c + d + e + f + g + tag + p x>> + p y>> 2 * + value 3 * +
        array values>> first 4 * + array values>> second 5 * +
        array values>> third 6 * + integer 7 * +
    ] hfa-spill-reader [ va_call_hfa_spill ] with-callback
] compile-call ] unit-test

CALLBACK: va-big big-reader ( int count, ... )
{ -15769158013578 } [ [
    [| count args |
        count drop va-big <struct>
        args longlong va-arg >>x args longlong va-arg >>y args longlong va-arg >>z
        ! Nested C entry must preserve the hidden result pointer.
        [ gc read-ints ] int-reader [ 12 va_call_ints ] with-callback drop gc
    ] big-reader [ va_call_big_return ] with-callback
] compile-call ] unit-test
CALLBACK: va-pair pair-reader ( int count, ... double x, double y )
{ -3.75 } [ [
    [| count x y | count drop va-pair <struct> x >>x y >>y ]
    pair-reader [ va_call_pair_return ] with-callback
] compile-call ] unit-test

! Cursor copies advance independently, including copies made after a read.
{ 3 } [ [
    [| count args |
        count drop args int va-arg
        args va-copy int va-arg + args int va-arg +
    ] int-reader [ 12 va_call_ints ] with-callback
] compile-call ] unit-test

! A named constructor avoids recursively expanding the same inline callback
! constructor while compiling its outer callback body.
: nested-int-callback ( -- alien ) [ read-ints ] int-reader ;

! A callback nested inside another callback gets separate native state.
{ 79 } [ [
    [| count args |
        count drop args int va-arg
        nested-int-callback [ 12 va_call_ints ] with-callback +
        args int va-arg +
    ] int-reader [ 12 va_call_ints ] with-callback
] compile-call ] unit-test

! An outer cursor cannot be read while a different callback is active.
SYMBOL: outer-args
: nested-context-callback ( -- alien )
    [
        2drop
        [ outer-args get int va-arg ] [ expired-va-list? ] must-fail-with
        0
    ] int-reader ;
{ -1 } [ [
    [| count outer |
        count drop outer outer-args set-global
        nested-context-callback [ 0 va_call_ints ] with-callback drop
        outer int va-arg
    ] int-reader [ 12 va_call_ints ] with-callback
] compile-call ] unit-test

SYMBOL: escaped-args
{ 0 } [ [
    [| count args | count drop args va-copy escaped-args set-global 0 ]
    int-reader [ 12 va_call_ints ] with-callback
] compile-call ] unit-test
[ [ escaped-args get int va-arg ] compile-call ] [ expired-va-list? ] must-fail-with

CALLBACK: longlong list-reader ( int count, va_list args )
{ 0 } [ [ [ read-ints ] list-reader [ 0 va_call_list ] with-callback ] compile-call ] unit-test
{ 78 } [ [ [ read-ints ] list-reader [ 12 va_call_list ] with-callback ] compile-call ] unit-test
! Each forwarding operation passes C an independent native va_list copy.
{ 155 } [ [
    [| count args |
        count args va_sum_list count args va_sum_list + args int va-arg +
    ] list-reader [ 12 va_call_list ] with-callback
] compile-call ] unit-test
! The cursor made from an ellipsis callback can also be passed to C.
{ 155 } [ [
    [| count args |
        count args va_sum_list count args va_sum_list + args int va-arg +
    ] int-reader [ 12 va_call_ints ] with-callback
] compile-call ] unit-test

LIBRARY: varargs-fixture
FUNCTION: void* va_snprintf_pointer ( )
FUNCTION: void* va_vsnprintf_pointer ( )
: va-snprintf ( output size format text number precision value wide -- count )
    va_snprintf_pointer
    int { void* size_t c-string c-string int int double longlong }
    cdecl 3 alien-indirect-varargs ;
: va-vsnprintf ( output size format args -- count )
    va_vsnprintf_pointer int { void* size_t c-string va_list } cdecl alien-indirect ;
:: formatted ( size -- count text )
    128 <byte-array> :> output
    output size "%s:%d:%.*f:%lld" "value" -42 3 1.25 -1234567890123 va-snprintf
    output utf8 alien>string ;
{ 30 "value:-42:1.250:-1234567890123" } [ [ 128 formatted ] compile-call ] unit-test
{ 30 "value:-" } [ [ 8 formatted ] compile-call ] unit-test
{ 30 "" } [ [ 0 formatted ] compile-call ] unit-test

SYMBOL: formatted-text
CALLBACK: int format-list-reader ( c-string format, va_list args )
{ 30 "value:-42:1.250:-1234567890123" } [ [
    [| format args |
        128 <byte-array> :> output
        output 128 format args va-vsnprintf
        output utf8 alien>string formatted-text set-global
    ] format-list-reader [ va_call_format_list ] with-callback
    formatted-text get
] compile-call ] unit-test
! Forward after consuming the first item; verify copies retain that position.
{ 25 ":-42:1.250:-1234567890123" } [ [
    [| format args |
        format drop args c-string va-arg drop
        128 <byte-array> :> output
        output 128 ":%d:%.*f:%lld" args va-vsnprintf
        output utf8 alien>string formatted-text set-global
    ] format-list-reader [ va_call_format_list ] with-callback
    formatted-text get
] compile-call ] unit-test

LIBRARY: varargs-fixture
FUNCTION: int va_small_available ( )
va_small_available 0 > [
    "resource:basis/compiler/tests/varargs/small.factor" run-test-file
] when

! Unix also exposes the standard formatting symbols directly.
os windows? [
    "resource:basis/compiler/tests/varargs/format-direct.factor" run-test-file
] unless
