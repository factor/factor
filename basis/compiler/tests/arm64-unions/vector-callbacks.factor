USING: accessors alien.c-types alien.syntax alien.varargs compiler.test
kernel locals math sequences tools.test ;
IN: compiler.tests.arm64-unions
LIBRARY: arm64-unions
FUNCTION: double au_call_vector_variadic ( au-dynamic-cb cb )
CALLBACK: double au-vector-typed-cb ( int marker, ... au-vector-two v, double tail )
FUNCTION-ALIAS: au-call-vector-typed double au_call_vector_variadic ( au-vector-typed-cb cb )

{ 53.0 } [
    [
        [| marker args |
            args au-vector-two va-arg a>> [ a>> sum ] [ b>> sum ] bi +
            args double va-arg + marker +
        ] au-dynamic-cb au_call_vector_variadic
    ] compile-call
] unit-test

{ 53.0 } [
    [
        [ swap a>> [ a>> sum ] [ b>> sum ] bi + + + ]
        au-vector-typed-cb au-call-vector-typed
    ] compile-call
] unit-test
