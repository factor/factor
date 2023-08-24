USING: eval tools.test compiler.units vocabs words
kernel ;
IN: compiler.tests.redefine7

! Mixin redefinition did not recompile all necessary words.

{ } [ [ "compiler.tests.redefine7" forget-vocab ] with-compilation-unit ] unit-test

{ } [
    "USING: kernel math ;
    IN: compiler.tests.redefine7
    MIXIN: my-mixin
    INSTANCE: fixnum my-mixin
    : my-inline ( a -- b ) dup my-mixin? [ 1 + ] when ;"
    eval( -- )
] unit-test

{ } [
    "USE: math
    IN: compiler.tests.redefine7
    INSTANCE: float my-mixin"
    eval( -- )
] unit-test

{ 2.0 } [
    1.0 "my-inline" "compiler.tests.redefine7" lookup-word execute
] unit-test
