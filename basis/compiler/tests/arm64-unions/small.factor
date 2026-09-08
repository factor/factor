USING: accessors alien.c-types alien.syntax alien.varargs classes.struct
compiler.test kernel locals math math.floats.small.c-types tools.test ;
FROM: alien.c-types => float ;
IN: compiler.tests.arm64-unions
LIBRARY: arm64-unions

UNION-STRUCT: au-small { a half } { b bfloat } ;
UNION-STRUCT: au-bsmall { a bfloat } { b half } ;
STRUCT: au-small-pair { first au-small } { second au-bsmall } ;
FUNCTION: int au_small_controls ( )
FUNCTION: double au_take_small ( au-small v, double tail )
FUNCTION: double au_take_bsmall ( au-bsmall v, double tail )
FUNCTION: au-small au_return_small ( float v )
FUNCTION: au-bsmall au_return_bsmall ( float v )
FUNCTION: double au_take_small_pair ( au-small-pair v, double tail )
CALLBACK: double au-small-pair-cb ( au-small-pair v, double tail )
FUNCTION: double au_call_small_pair ( au-small-pair-cb cb )

: small-pair-value ( pair -- n ) [ first>> a>> ] [ second>> a>> 2 * ] bi + ;

{ 1 } [ au_small_controls ] unit-test
{ 11.25 } [ au-small <struct> 1.25 >>a 10.0 au_take_small ] unit-test
{ 12.5 } [ au-bsmall <struct> 2.5 >>a 10.0 au_take_bsmall ] unit-test
{ 1.25 } [ 1.25 au_return_small a>> ] unit-test
{ 2.5 } [ 2.5 au_return_bsmall a>> ] unit-test
{ 16.25 } [ au-small <struct> 1.25 >>a au-bsmall <struct> 2.5 >>a au-small-pair boa 10.0 au_take_small_pair ] unit-test
{ 16.25 } [ [ [ swap small-pair-value + ] au-small-pair-cb au_call_small_pair ] compile-call ] unit-test

CALLBACK: double au-small-dynamic-cb ( int marker, ... )
CALLBACK: double au-small-typed-cb ( int marker, ... au-small-pair v, double tail )
FUNCTION: double au_call_small_variadic ( au-small-dynamic-cb cb )
FUNCTION-ALIAS: au-call-small-typed double au_call_small_variadic ( au-small-typed-cb cb )

{ 23.25 } [
    [
        [| marker args |
            args au-small-pair va-arg small-pair-value args double va-arg + marker +
        ] au-small-dynamic-cb au_call_small_variadic
    ] compile-call
] unit-test
{ 23.25 } [ [ [ swap small-pair-value + + ] au-small-typed-cb au-call-small-typed ] compile-call ] unit-test
