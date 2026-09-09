USING: alien alien.c-types alien.libraries alien.syntax alien.varargs
assocs compiler.errors compiler.test debugger io io.pathnames kernel kernel.private
locals math memory namespaces sequences system tools.test ;
IN: tests.lazy-arm64-callback-template
f restartable-tests? set-global
<< "lazy-callback-fixture" "resource:libfactor-ffi-test.dylib" absolute-path cdecl add-library >>
LIBRARY: lazy-callback-fixture
FUNCTION: uint va_c_controls ( )
FUNCTION: longlong va_call_ints ( void* cb, int count )
CALLBACK: int ordinary-reader ( int value )
CALLBACK: longlong variadic-reader ( int count, ... )
:: read-ints ( count args -- sum )
    count <iota> [ 1 + args int va-arg * ] map sum ;
SYMBOL: original-template
CALLBACK-STUB special-object original-template set-global
{ 2 } [ original-template get length ] unit-test
{ 255 } [ [ va_c_controls ] compile-call ] unit-test
! Keep an ordinary callback alive while allocation upgrades the template,
! then collect and call the same ordinary callback again.
{ 42 78 42 t t 3 } [ [
    [ 1 + ] ordinary-reader [| ordinary |
        41 ordinary int { int } cdecl alien-indirect
        [ read-ints ] variadic-reader [ 12 va_call_ints ] with-callback
        gc
        41 ordinary int { int } cdecl alien-indirect
        CALLBACK-STUB special-object first original-template get first eq?
        CALLBACK-STUB special-object second original-template get second eq?
        CALLBACK-STUB special-object length
    ] with-callback
] compile-call ] unit-test
! Subsequent allocation uses the installed template without regenerating it.
{ 78 t } [ [
    CALLBACK-STUB special-object
    [ read-ints ] variadic-reader [ 12 va_call_ints ] with-callback
    swap CALLBACK-STUB special-object eq?
] compile-call ] unit-test
test-failures get empty? compiler-errors get assoc-empty? and
[ "Lazy callback template native tests passed" print 0 ]
[ :test-failures compiler-errors get values [ print-error ] each 1 ] if flush exit
