USING: tools.test namespaces assocs alien.syntax kernel
compiler.errors accessors alien alien.c-types alien.strings
debugger literals kernel.private ;
FROM: alien.libraries => add-library load-library ;
IN: compiler.tests.linkage-errors

! Regression: calling an undefined function would raise a protection fault
FUNCTION: void this_does_not_exist ( )

[ this_does_not_exist ] try

[ this_does_not_exist ] [
    ${ "kernel-error" ERROR-UNDEFINED-SYMBOL "this_does_not_exist" string>symbol f }
    =
] must-fail-with

[ T{ no-such-symbol { name "this_does_not_exist" } } ]
[
    \ this_does_not_exist linkage-errors get at error>>
    ! We don't care about the error message from dlerror, just
    ! wipe it out
    clone f >>message
] unit-test

<< "no_such_library" "no_such_library" cdecl add-library >>

LIBRARY: no_such_library

FUNCTION: void no_such_function ( )

[ no_such_function ] try

[ no_such_function ] [
    ${
        "kernel-error" ERROR-UNDEFINED-SYMBOL
        "no_such_function" string>symbol
        "no_such_library" load-library
    }
    =
] must-fail-with

[ T{ no-such-library { name "no_such_library" } } ]
[
    \ no_such_function linkage-errors get at error>>
    ! We don't care about the error message from dlerror, just
    ! wipe it out
    clone f >>message
] unit-test
