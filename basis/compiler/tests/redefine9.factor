USING: eval tools.test compiler.units vocabs multiline words
kernel generic.math ;
IN: compiler.tests

! Mixin redefinition did not recompile all necessary words.

[ ] [ [ "compiler.tests.redefine9" forget-vocab ] with-compilation-unit ] unit-test

[ ] [
    <"
    USING: kernel math math.order sorting ;
    IN: compiler.tests.redefine9
    MIXIN: my-mixin
    INSTANCE: fixnum my-mixin
    GENERIC: my-generic ( a -- b )
    ! We add the bogus quotation here to hinder inlining
    ! since otherwise we cannot trigger this bug.
    M: my-mixin my-generic 1 + [ [ <=> ] sort ] drop ;
    "> eval( -- )
] unit-test

[ ] [
    <"
    USE: math
    IN: compiler.tests.redefine9
    TUPLE: my-tuple ;
    INSTANCE: my-tuple my-mixin
    "> eval( -- )
] unit-test

[
    "my-tuple" "compiler.tests.redefine9" lookup boa
    "my-generic" "compiler.tests.redefine9" lookup
    execute
] [ no-math-method? ] must-fail-with
