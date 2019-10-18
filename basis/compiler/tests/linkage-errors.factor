USING: tools.test namespaces assocs alien.syntax kernel
compiler.errors accessors alien alien.c-types alien.strings
debugger literals kernel.private alien.libraries ;
IN: compiler.tests.linkage-errors

! Regression: calling an undefined function would raise a protection fault
FUNCTION: void this_does_not_exist ( )

[ this_does_not_exist ] try

[ this_does_not_exist ] [
    ${ KERNEL-ERROR ERROR-UNDEFINED-SYMBOL "this_does_not_exist" string>symbol f }
    =
] must-fail-with

{ t } [
    \ this_does_not_exist linkage-errors get at error>>
    [ no-such-symbol? ] [ name>> "this_does_not_exist" = ] bi and
    ! We don't care about the error message from dlerror, just
    ! wipe it out
    ! clone f >>message
] unit-test

<< "no_such_library" "no_such_library" cdecl add-library >>

LIBRARY: no_such_library

FUNCTION: void no_such_function ( )

[ no_such_function ] try

[ no_such_function ] [
    ${
        KERNEL-ERROR ERROR-UNDEFINED-SYMBOL
        "no_such_function" string>symbol
        "no_such_library" library-dll
    }
    =
] must-fail-with

{ t } [
    \ no_such_function linkage-errors get at error>>
    [ no-such-library? ] [ name>> "no_such_library" = ] bi and
] unit-test
