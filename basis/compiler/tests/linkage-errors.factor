USING: tools.test namespaces assocs alien.syntax kernel
compiler.errors accessors alien alien.c-types ;
FROM: alien.libraries => add-library ;
IN: compiler.tests.linkage-errors

! Regression: calling an undefined function would raise a protection fault
FUNCTION: void this_does_not_exist ( ) ;

[ this_does_not_exist ] [ { "kernel-error" 9 f f } = ] must-fail-with

[ T{ no-such-symbol { name "this_does_not_exist" } } ]
[ \ this_does_not_exist linkage-errors get at error>> ] unit-test

<< "no_such_library" "no_such_library" cdecl add-library >>

LIBRARY: no_such_library

FUNCTION: void no_such_function ( ) ;

[ T{ no-such-library { name "no_such_library" } } ]
[ \ no_such_function linkage-errors get at error>> ] unit-test
