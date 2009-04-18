USING: eval tools.test compiler.units vocabs multiline words
kernel classes.mixin arrays ;
IN: compiler.tests

! Calls to generic words were not folded away.

[ ] [ [ "compiler.tests.redefine11" forget-vocab ] with-compilation-unit ] unit-test

[ ] [
    <"
    USING: math arrays ;
    IN: compiler.tests.folding
    GENERIC: foldable-generic ( a -- b ) foldable
    M: integer foldable-generic f <array> ;
    "> eval( -- )
] unit-test

[ ] [
    <"
    USING: math arrays ;
    IN: compiler.tests.folding
    : fold-test ( -- x ) 10 foldable-generic ;
    "> eval( -- )
] unit-test

[ t ] [
    "fold-test" "compiler.tests.folding" lookup execute
    "fold-test" "compiler.tests.folding" lookup execute
    eq?
] unit-test
