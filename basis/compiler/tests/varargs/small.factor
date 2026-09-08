USING: alien alien.c-types alien.syntax alien.varargs compiler.test kernel locals math
math.floats.small.c-types memory tools.test ;
IN: compiler.tests.alien-varargs.small
LIBRARY: varargs-fixture
FUNCTION: double va_call_small ( void* cb )
FUNCTION: double va_call_small_return ( void* cb )
FUNCTION: int va_small_controls ( )
{ 1 } [ [ va_small_controls ] compile-call ] unit-test
CALLBACK: double small-reader ( half namedHalf, bfloat namedBfloat, int tag, ... )
{ 384.5 } [ [
    [| h b tag args |
        gc h b 2 * + tag +
        args half va-arg + args bfloat va-arg 2 * +
        args half va-arg 3 * + args bfloat va-arg 4 * +
        args half va-arg 5 * + args bfloat va-arg 6 * +
        args half va-arg 7 * + args bfloat va-arg 8 * +
        args half va-arg 9 * + args bfloat va-arg 10 * +
    ] small-reader [ va_call_small ] with-callback
] compile-call ] unit-test
CALLBACK: half small-return-reader ( int count, ... half a, bfloat b )
{ 3.75 } [ [
    [| count a b | count drop gc a b + ] small-return-reader
    [ va_call_small_return ] with-callback
] compile-call ] unit-test
