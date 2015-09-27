IN: compiler.tests.x87-regression
USING: math.floats.env alien.syntax alien.c-types compiler.test
tools.test kernel math ;

LIBRARY: libm
FUNCTION: double sqrt ( double x )

[ { } ] [
    4.0 [ [ 100 [ dup sqrt drop ] times ] collect-fp-exceptions nip ] compile-call
] unit-test
