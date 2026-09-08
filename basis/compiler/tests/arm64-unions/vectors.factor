USING: accessors alien.c-types alien.syntax classes.struct combinators compiler.test
kernel math math.vectors.simd sequences tools.test ;
FROM: alien.c-types => float ;
IN: compiler.tests.arm64-unions
LIBRARY: arm64-unions
UNION-STRUCT: au-vector { a float-4 } { b int-4 } ;
FUNCTION: double au_take_vector ( au-vector v, double tail )
FUNCTION: au-vector au_return_vector ( float a, float b, float c, float d )
CALLBACK: double au-vector-cb ( au-vector v, double tail )
FUNCTION: double au_call_vector ( au-vector-cb cb )
{ 40.0 } [ au-vector <struct> float-4{ 1.0 2.0 3.0 4.0 } >>a 10.0 au_take_vector ] unit-test
{ float-4{ 1.0 2.0 3.0 4.0 } } [ 1.0 2.0 3.0 4.0 au_return_vector a>> ] unit-test
{ 40.0 } [ [ [ swap a>> { [ first ] [ second 2 * ] [ third 3 * ] [ fourth 4 * ] } cleave + + + + ] au-vector-cb au_call_vector ] compile-call ] unit-test

STRUCT: au-fvec-pair { a float-4 } { b float-4 } ;
STRUCT: au-ivec-pair { a int-4 } { b int-4 } ;
UNION-STRUCT: au-vector-two { a au-fvec-pair } { b au-ivec-pair } ;
FUNCTION: double au_take_vector_two ( au-vector-two v, double tail )
FUNCTION: au-vector-two au_return_vector_two ( )
{ 46.0 } [
    au-vector-two <struct>
        float-4{ 1.0 2.0 3.0 4.0 } float-4{ 5.0 6.0 7.0 8.0 } au-fvec-pair boa >>a
    10.0 au_take_vector_two
] unit-test
{ float-4{ 1.0 2.0 3.0 4.0 } float-4{ 5.0 6.0 7.0 8.0 } } [
    au_return_vector_two a>> [ a>> ] [ b>> ] bi
] unit-test
