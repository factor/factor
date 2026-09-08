USING: accessors alien alien.c-types alien.libraries alien.syntax
classes.struct combinators compiler.test io io.pathnames kernel namespaces parser words math math.vectors.simd sequences system tools.test ;
FROM: alien.c-types => float ;
IN: compiler.tests.arm64-unions

<<
"arm64-unions" "resource:" absolute-path os {
    { windows [ "libfactor-ffi-test.dll" ] }
    { macos [ "libfactor-ffi-test.dylib" ] }
    [ drop "libfactor-ffi-test.so" ]
} case append-path cdecl add-library
>>
LIBRARY: arm64-unions

UNION-STRUCT: au-one { a float } { b float } ;
STRUCT: au-pair { a float } { b float } ;
UNION-STRUCT: au-two { a float } { pair au-pair } ;
STRUCT: au-quad { a float } { b float } { c float } { d float } ;
UNION-STRUCT: au-four { quad au-quad } { a float } ;
STRUCT: au-nested { first au-one } { second float } ;
UNION-STRUCT: au-mixed { a float } { b double } ;
SYMBOL: au-aligned-float
<< float lookup-c-type clone 8 >>align 8 >>align-first \ au-aligned-float typedef >>
STRUCT: au-padded { a float } { b au-aligned-float } ;
UNION-STRUCT: au-padded-union { padded au-padded } { other float[4] } ;

FUNCTION: double au_take_one ( au-one v, double tail )
FUNCTION: double au_take_two ( au-two v, double tail )
FUNCTION: double au_take_four ( au-four v, double tail )
FUNCTION: double au_take_nested ( au-nested v, double tail )
FUNCTION: double au_take_mixed ( au-mixed v, double tail )
FUNCTION: au-one au_return_one ( float a )
FUNCTION: au-two au_return_two ( float a, float b )
FUNCTION: au-four au_return_four ( float a, float b, float c, float d )
FUNCTION: double au_variadic ( int marker, ... au-two v, double tail )


CALLBACK: double au-one-cb ( au-one v, double tail )
CALLBACK: double au-two-cb ( au-two v, double tail )
CALLBACK: double au-four-cb ( au-four v, double tail )
FUNCTION: double au_call_one ( au-one-cb cb )
FUNCTION: double au_call_two ( au-two-cb cb )
FUNCTION: double au_call_four ( au-four-cb cb )

{ 11.25 } [ au-one <struct> 1.25 >>a 10.0 au_take_one ] unit-test
{ 16.25 } [ au-two <struct> 1.25 2.5 au-pair boa >>pair 10.0 au_take_two ] unit-test
{ 40.0 } [ au-four <struct> 1.0 2.0 3.0 4.0 au-quad boa >>quad 10.0 au_take_four ] unit-test
{ 16.25 } [ au-one <struct> 1.25 >>a 2.5 au-nested boa 10.0 au_take_nested ] unit-test
{ 13.75 } [ au-mixed <struct> 3.75 >>b 10.0 au_take_mixed ] unit-test
{ 1.25 } [ 1.25 au_return_one a>> ] unit-test
{ 1.25 2.5 } [ 1.25 2.5 au_return_two pair>> [ a>> ] [ b>> ] bi ] unit-test
{ 1.0 2.0 3.0 4.0 } [ 1.0 2.0 3.0 4.0 au_return_four quad>> { [ a>> ] [ b>> ] [ c>> ] [ d>> ] } cleave ] unit-test
{ 23.25 } [ 7 au-two <struct> 1.25 2.5 au-pair boa >>pair 10.0 au_variadic ] unit-test
{ 11.25 } [ [ [ swap a>> + ] au-one-cb au_call_one ] compile-call ] unit-test
{ 16.25 } [ [ [ swap pair>> [ a>> ] [ b>> 2 * ] bi + + ] au-two-cb au_call_two ] compile-call ] unit-test
{ 40.0 } [ [ [ swap quad>> { [ a>> ] [ b>> 2 * ] [ c>> 3 * ] [ d>> 4 * ] } cleave + + + + ] au-four-cb au_call_four ] compile-call ] unit-test

FUNCTION: int au_c_controls ( )
FUNCTION: int au_vector_available ( )
FUNCTION: int au_small_available ( )
FUNCTION: double au_take_padded ( au-padded v, double tail )
FUNCTION: double au_take_padded_union ( au-padded-union v, double tail )
FUNCTION: au-padded au_return_padded ( float a, float b )
CALLBACK: double au-padded-cb ( au-padded v, double tail )
FUNCTION: double au_call_padded ( au-padded-cb cb )
FUNCTION: double au_take_spill ( double a, double b, double c, double d, double e, double f, au-two v, double tail )
CALLBACK: double au-spill-cb ( double a, double b, double c, double d, double e, double f, au-two v, double tail )
FUNCTION: double au_call_spill ( au-spill-cb cb )

{ 1 } [ au_c_controls ] unit-test
{ 16 } [ au-padded heap-size ] unit-test
{ 16.25 } [ 1.25 2.5 au-padded boa 10.0 au_take_padded ] unit-test
{ 16.25 } [ au-padded-union <struct> 1.25 2.5 au-padded boa >>padded 10.0 au_take_padded_union ] unit-test
{ 1.25 2.5 } [ 1.25 2.5 au_return_padded [ a>> ] [ b>> ] bi ] unit-test
{ 16.25 } [ [ [ swap [ a>> ] [ b>> 2 * ] bi + + ] au-padded-cb au_call_padded ] compile-call ] unit-test
{ 37.25 } [ 1.0 2.0 3.0 4.0 5.0 6.0 au-two <struct> 1.25 2.5 au-pair boa >>pair 10.0 au_take_spill ] unit-test
{ 37.25 } [ [ [ swap pair>> [ a>> ] [ b>> 2 * ] bi + + + + + + + + ] au-spill-cb au_call_spill ] compile-call ] unit-test

"require-varargs-small" get [ au_vector_available 1 assert= ] when
au_vector_available 1 = [
    "resource:basis/compiler/tests/arm64-unions/vectors.factor" run-test-file
] [ "HVA union C fixtures unavailable on this compiler." print ] if
