USING: accessors alien.c-types alien.syntax alien.varargs combinators
compiler.test kernel locals math sequences tools.test ;
FROM: alien.c-types => float ;
IN: compiler.tests.arm64-unions
LIBRARY: arm64-unions

CALLBACK: double au-dynamic-cb ( int marker, ... )
CALLBACK: double au-typed-cb ( int marker, ... au-two v, double tail )
FUNCTION: double au_call_variadic ( au-dynamic-cb cb )
FUNCTION-ALIAS: au-call-typed double au_call_variadic ( au-typed-cb cb )

{ 23.25 } [
    [
        [| marker args |
            args au-two va-arg pair>> [ a>> ] [ b>> 2 * ] bi +
            args double va-arg + marker +
        ] au-dynamic-cb au_call_variadic
    ] compile-call
] unit-test

{ 23.25 } [
    [ [ swap pair>> [ a>> ] [ b>> 2 * ] bi + + + ] au-typed-cb au-call-typed ] compile-call
] unit-test

au_vector_available 1 = [
    "resource:basis/compiler/tests/arm64-unions/vector-callbacks.factor" run-test-file
] when
