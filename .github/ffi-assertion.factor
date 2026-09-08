USING: alien alien.c-types alien.libraries alien.syntax assocs compiler.errors
io.pathnames kernel namespaces sequences system tools.test ;
IN: ffi-assertion
f restartable-tests? set-global
<< "ffi-negative" "resource:libfactor-ffi-test.so" absolute-path cdecl add-library >>
LIBRARY: ffi-negative
FUNCTION: int ffi_test_1 ( )
{ 3 } [ ffi_test_1 ] unit-test
:test-failures
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
