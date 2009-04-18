USING: eval tools.test compiler.units vocabs multiline words
kernel classes.mixin arrays ;
IN: compiler.tests

! Mixin redefinition did not recompile all necessary words.

[ ] [ [ "compiler.tests.redefine11" forget-vocab ] with-compilation-unit ] unit-test

[ ] [
    <"
    USING: kernel math classes arrays ;
    IN: compiler.tests.redefine11
    MIXIN: my-mixin
    INSTANCE: array my-mixin
    INSTANCE: fixnum my-mixin
    GENERIC: my-generic ( a -- b )
    M: my-mixin my-generic drop 0 ;
    M: object my-generic drop 1 ;
    : my-inline ( -- b ) { } my-generic ;
    "> eval( -- )
] unit-test

[ ] [
    [
        array "my-mixin" "compiler.tests.redefine11" lookup
        remove-mixin-instance
    ] with-compilation-unit
] unit-test

[ 1 ] [
    "my-inline" "compiler.tests.redefine11" lookup execute
] unit-test
