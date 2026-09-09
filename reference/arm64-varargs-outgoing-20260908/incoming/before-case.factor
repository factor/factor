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
