USING: eval tools.test compiler.units vocabs multiline words
kernel ;
IN: compiler.tests

! Regression: if dispatch was eliminated but method was not inlined,
! compiled usage information was not recorded.

[ "compiler.tests.redefine5" forget-vocab ] with-compilation-unit

[ ] [
    <"
    USING: sorting kernel math.order ;
    IN: compiler.tests.redefine5
    GENERIC: my-generic ( a -- b )
    M: object my-generic [ <=> ] sort ;
    : my-inline ( a -- b ) my-generic ;
    "> eval( -- )
] unit-test

[ ] [
    <"
    USE: kernel
    IN: compiler.tests.redefine5
    TUPLE: my-tuple ;
    M: my-tuple my-generic drop 0 ;
    "> eval( -- )
] unit-test

[ 0 ] [
    "my-tuple" "compiler.tests.redefine5" lookup boa
    "my-inline" "compiler.tests.redefine5" lookup execute
] unit-test
