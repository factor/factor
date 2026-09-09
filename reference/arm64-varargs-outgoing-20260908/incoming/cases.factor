USING: accessors alien alien.c-types alien.libraries alien.syntax alien.varargs
classes.struct combinators compiler.test io.pathnames kernel locals math math.vectors.simd
memory sequences tools.test ;
FROM: alien.c-types => float ;
IN: windows-varargs.incoming
: compiled-unit-test ( expected quot -- ) [ compile-call ] curry unit-test ;
<< "windows-incoming" "/Users/erg/factor.worktrees/arm64-varargs-outgoing/reference/arm64-varargs-outgoing-20260908/incoming/callers.dylib" cdecl add-library >>
LIBRARY: windows-incoming
FUNCTION: double incoming_mixed ( void* cb )
FUNCTION: double incoming_named_hfa ( void* cb, int n )
FUNCTION: double incoming_split ( void* cb, int n )
FUNCTION: longlong incoming_big ( void* cb )
FUNCTION: double incoming_vector ( void* cb, int n )
FUNCTION: double incoming_consume ( int count, va_list args )
CALLBACK: double incoming-mixed-reader ( float a, double b, int c, ... )
:: read-mixed ( a b c args -- result )
    a b 2 * + c 3 * +
    args int va-arg 4 * + args double va-arg 5 * +
    args longlong va-arg 6 * + args double va-arg 7 * +
    args int va-arg 8 * + args double va-arg 9 * + ;
{ 285.0 } [ [ gc read-mixed ] incoming-mixed-reader [ incoming_mixed ] with-callback ] compiled-unit-test
CALLBACK: double incoming-mixed-tail ( float a, double b, int c, ... int d, double e, longlong f, double g, int h, double i )
{ 285.0 } [ [| a b c d e f g h i | a b 2 * + c 3 * + d 4 * + e 5 * + f 6 * + g 7 * + h 8 * + i 9 * + ] incoming-mixed-tail [ incoming_mixed ] with-callback ] compiled-unit-test
STRUCT: inc-pair { x double } { y double } ;
STRUCT: inc-hfa { x double } { y double } { z double } ;
STRUCT: inc-big { x longlong } { y longlong } { z longlong } ;
CALLBACK: double incoming-hfa-reader ( inc-pair p, int n, ... )
{ 134.0 } [ [| p n args |
    args inc-hfa va-arg :> h
    p x>> p y>> 2 * + n 3 * + h x>> 4 * + h y>> 5 * + h z>> 6 * + args double va-arg 7 * +
] incoming-hfa-reader [ 1 incoming_named_hfa ] with-callback ] compiled-unit-test
FUNCTION: double incoming_spill ( void* cb, int n )
CALLBACK: double incoming-spill-reader ( int a, int b, int c, int d, int e, int f, ... )
{ 285.0 } [ [| a b c d e f args |
    args inc-pair va-arg :> p
    a b 2 * + c 3 * + d 4 * + e 5 * + f 6 * + p x>> 7 * + p y>> 8 * + args double va-arg 9 * +
] incoming-spill-reader [ 1 incoming_spill ] with-callback ] compiled-unit-test
CALLBACK: inc-big incoming-big-reader ( int count, ... )
{ -606 } [ [| count args |
    count drop args longlong va-arg args longlong va-arg args longlong va-arg inc-big boa gc
] incoming-big-reader [ incoming_big ] with-callback ] compiled-unit-test

FUNCTION: double incoming_list ( void* cb )
CALLBACK: double incoming-list-reader ( int count, ... )
{ 771.0 } [ [| count args |
    count args incoming_consume count args incoming_consume + args double va-arg +
] incoming-list-reader [ incoming_list ] with-callback ] compiled-unit-test
FUNCTION: double incoming_named_spill ( void* cb )
CALLBACK: double incoming-named-spill ( float a, double b, int c, int d, int e, int f, int g, int h, int i, ... double j, int k )
{ 506.0 } [ [| a b c d e f g h i j k |
    a b 2 * + c 3 * + d 4 * + e 5 * + f 6 * + g 7 * + h 8 * + i 9 * + j 10 * + k 11 * +
] incoming-named-spill [ incoming_named_spill ] with-callback ] compiled-unit-test
