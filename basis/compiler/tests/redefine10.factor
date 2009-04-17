USING: eval tools.test compiler.units vocabs multiline words
kernel ;
IN: compiler.tests

! Mixin redefinition did not recompile all necessary words.

[ ] [ [ "compiler.tests.redefine10" forget-vocab ] with-compilation-unit ] unit-test

[ ] [
    <"
    USING: kernel math classes ;
    IN: compiler.tests.redefine10
    MIXIN: my-mixin
    INSTANCE: fixnum my-mixin
    : my-inline ( a -- b ) dup my-mixin instance? [ 1 + ] when ;
    "> eval( -- )
] unit-test

[ ] [
    <"
    USE: math
    IN: compiler.tests.redefine10
    INSTANCE: float my-mixin
    "> eval( -- )
] unit-test

[ 2.0 ] [
    1.0 "my-inline" "compiler.tests.redefine10" lookup execute
] unit-test
