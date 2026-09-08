! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax combinators
continuations destructors io.pathnames kernel locals math math.floats.small
math.floats.small.c-types math.order sequences tools.test tools.test.ffi system classes.struct accessors ;
IN: compiler.tests.alien-small-floats

<< "small-floats-test" "resource:" absolute-path
os {
    { windows [ "libfactor-ffi-test.dll" ] }
    { macos [ "libfactor-ffi-test.dylib" ] }
    [ drop "libfactor-ffi-test.so" ]
} case append-path cdecl add-library >>
LIBRARY: small-floats-test

FUNCTION: half half_identity ( half x )
FUNCTION: ushort half_bits ( half x )
FUNCTION: half half_from_bits ( ushort x )
FUNCTION: half half_convert ( double x )
FUNCTION: half half_callback ( void* f, half x )
FUNCTION: double half_mixed ( int a, half b, double c, half d, int e )
FUNCTION: half half_overflow ( half a, half b, half c, half d, half e, half f, half g, half h, half i, half j )
FUNCTION: half half_overflow_callback ( void* f )

: half-indirect ( x ptr -- y ) half { half } cdecl alien-indirect ;
: half-cb ( -- callback ) half { half } cdecl [ 0.5 + ] alien-callback ;
: half-overflow-cb ( -- callback )
    half { half half half half half half half half half half } cdecl
    [| a b c d e f g h i j | a b + c + d + e + f + g + h + i + j + ] alien-callback ;

{ 1.5 } [ 1.5 half_identity small-abi-case ] unit-test
{ -2.5 } [ -2.5 "half_identity" "small-floats-test" library-dll dlsym half-indirect small-abi-case ] unit-test
{ 16.0 } [ 1 2.5 3.0 4.5 5 half_mixed small-abi-case ] unit-test
{ 2.0 } [ half-cb [ 1.5 half_callback ] with-callback small-abi-case ] unit-test
{ 55.0 } [ 1 2 3 4 5 6 7 8 9 10 half_overflow small-abi-case ] unit-test
{ 55.0 } [ half-overflow-cb [ half_overflow_callback ] with-callback small-abi-case ] unit-test

! Compare Factor's rounded parameter bits against an independent C conversion.
{ t } [ { 0.0 -0.0 1.0 -1.0 1.00048828125 1.00146484375 1.00390625 1.01171875
    0.000000059604644775390625 0.00006103515625 65504.0 65520.0 1/0. -1/0. }
    [ [ half_bits ] [ half_convert float>half-bits ] bi = ] all? small-abi-case ] unit-test
! Raw finite C results must retain sign, subnormals, and exact mantissa bits.
{ t } [ { 0 1 2 127 128 255 256 1023 1024 16383 16384 30000 32768 32769 49152 }
    [ [ half_from_bits float>half-bits ] keep = ] all? small-abi-case ] unit-test

FUNCTION: bfloat bfloat_identity ( bfloat x )
FUNCTION: ushort bfloat_bits ( bfloat x )
FUNCTION: bfloat bfloat_from_bits ( ushort x )
FUNCTION: bfloat bfloat_convert ( double x )
FUNCTION: bfloat bfloat_callback ( void* f, bfloat x )
FUNCTION: double bfloat_mixed ( int a, bfloat b, double c, bfloat d, int e )
FUNCTION: bfloat bfloat_overflow ( bfloat a, bfloat b, bfloat c, bfloat d, bfloat e, bfloat f, bfloat g, bfloat h, bfloat i, bfloat j )
FUNCTION: bfloat bfloat_overflow_callback ( void* f )

: bfloat-indirect ( x ptr -- y ) bfloat { bfloat } cdecl alien-indirect ;
: bfloat-cb ( -- callback ) bfloat { bfloat } cdecl [ 0.5 + ] alien-callback ;
: bfloat-overflow-cb ( -- callback )
    bfloat { bfloat bfloat bfloat bfloat bfloat bfloat bfloat bfloat bfloat bfloat } cdecl
    [| a b c d e f g h i j | a b + c + d + e + f + g + h + i + j + ] alien-callback ;

{ 1.5 } [ 1.5 bfloat_identity small-abi-case ] unit-test
{ -2.5 } [ -2.5 "bfloat_identity" "small-floats-test" library-dll dlsym bfloat-indirect small-abi-case ] unit-test
{ 16.0 } [ 1 2.5 3.0 4.5 5 bfloat_mixed small-abi-case ] unit-test
{ 2.0 } [ bfloat-cb [ 1.5 bfloat_callback ] with-callback small-abi-case ] unit-test
{ 55.0 } [ 1 2 3 4 5 6 7 8 9 10 bfloat_overflow small-abi-case ] unit-test
{ 55.0 } [ bfloat-overflow-cb [ bfloat_overflow_callback ] with-callback small-abi-case ] unit-test

! Compare Factor's rounded parameter bits against an independent C conversion.
{ t } [ { 0.0 -0.0 1.0 -1.0 1.00048828125 1.00146484375 1.00390625 1.01171875
    0.000000059604644775390625 0.00006103515625 65504.0 65520.0 1/0. -1/0. }
    [ [ bfloat_bits ] [ bfloat_convert float>bfloat-bits ] bi = ] all? small-abi-case ] unit-test
! Raw finite C results must retain sign, subnormals, and exact mantissa bits.
{ t } [ { 0 1 2 127 128 255 256 1023 1024 16383 16384 30000 32768 32769 49152 }
    [ [ bfloat_from_bits float>bfloat-bits ] keep = ] all? small-abi-case ] unit-test

! Half formats share one fundamental type for AAPCS64 homogeneity.
STRUCT: mixed-small { a half } { b bfloat } ;
FUNCTION: double mixed_small_sum ( mixed-small x )
{ 4.0 } [ mixed-small <struct> 1.5 >>a 2.5 >>b mixed_small_sum small-abi-case ] unit-test

! The C result path covers every 16-bit payload. Numeric FFI canonicalizes
! NaNs in the same way as the public memory conversion words.
{ t } [
    65536 <iota> [
        [ half_from_bits float>half-bits ]
        [ half-bits>float float>half-bits ] bi =
    ] all?
small-abi-case ] unit-test
{ t } [
    65536 <iota> [
        [ bfloat_from_bits float>bfloat-bits ]
        [ bfloat-bits>float float>bfloat-bits ] bi =
    ] all?
small-abi-case ] unit-test

FUNCTION: double half_varargs ( int ignored, ... half a, half b, int c, double d )
{ 11.5 } [ 0 1.5 2.5 3 4.5 half_varargs small-abi-case ] unit-test

FUNCTION: double bfloat_varargs ( int ignored, ... bfloat a, bfloat b, int c, double d )
{ 11.5 } [ 0 1.5 2.5 3 4.5 bfloat_varargs small-abi-case ] unit-test

FUNCTION: half half_dirty_result ( )
FUNCTION: bfloat bfloat_dirty_result ( )
{ 1.0 1.0 } [ half_dirty_result bfloat_dirty_result small-abi-case ] unit-test

! Promotion must retain the declared small type's initial rounding.
{ 2.0 } [ 0 1.00048828125 1.00048828125 0 0.0 half_varargs small-abi-case ] unit-test
{ 2.0 } [ 0 1.00390625 1.00390625 0 0.0 bfloat_varargs small-abi-case ] unit-test

! Linux preserves the declared reduced type in unnamed arguments.
os linux? [
    "resource:basis/compiler/tests/small-floats/linux.factor" run-test-file
] when

! Named and anonymous small payloads share Windows's GP argument stream.
FUNCTION: ulonglong varout_half_bits ( half named, int count, ... half a, half b, half c, half d, half e, half f, half g, half h )
FUNCTION: ulonglong varout_bfloat_bits ( bfloat named, int count, ... bfloat a, bfloat b, bfloat c, bfloat d, bfloat e, bfloat f, bfloat g, bfloat h )
{ 806016 } [ 1 8 2 3 4 5 6 7 8 9 varout_half_bits ] unit-test
{ 745872 } [ 1 8 2 3 4 5 6 7 8 9 varout_bfloat_bits ] unit-test

USING: classes.struct math.vectors.simd ;
STRUCT: varout-vector-hva { a float-4 } { b float-4 } ;
FUNCTION: double varout_vector_args ( int tag, ... float-4 a, varout-vector-hva h, double tail )
{ 212.0 } [
    1 float-4{ 1 2 3 4 }
    float-4{ 5 6 7 8 } float-4{ 9 10 11 12 } varout-vector-hva boa 1
    varout_vector_args
] unit-test
