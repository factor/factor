USING: eval tools.test compiler.units vocabs words
kernel ;
IN: compiler.tests.redefine6

! Mixin redefinition did not recompile all necessary words.

{ } [ [ "compiler.tests.redefine6" forget-vocab ] with-compilation-unit ] unit-test

{ } [
    "USING: kernel kernel.private ;
    IN: compiler.tests.redefine6
    GENERIC: my-generic ( a -- b )
    MIXIN: my-mixin
    M: my-mixin my-generic drop 0 ;
    : my-inline ( a -- b ) { my-mixin } declare my-generic ;"
    eval( -- )
] unit-test

{ } [
    "USING: kernel ;
    IN: compiler.tests.redefine6
    TUPLE: my-tuple ;
    M: my-tuple my-generic drop 1 ;
    INSTANCE: my-tuple my-mixin"
    eval( -- )
] unit-test

{ 1 } [
    "my-tuple" "compiler.tests.redefine6" lookup-word boa
    "my-inline" "compiler.tests.redefine6" lookup-word execute
] unit-test
