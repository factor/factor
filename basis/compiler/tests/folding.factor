USING: eval tools.test compiler.units vocabs words
kernel classes.mixin arrays ;
IN: compiler.tests.folding

! Calls to generic words were not folded away.

{ } [ [ "compiler.tests.redefine11" forget-vocab ] with-compilation-unit ] unit-test

{ } [
    "USING: math arrays ;
    IN: compiler.tests.folding
    GENERIC: foldable-generic ( a -- b ) foldable
    M: integer foldable-generic f <array> ;"
    eval( -- )
] unit-test

{ } [
    "USING: math arrays ;
    IN: compiler.tests.folding
    : fold-test ( -- x ) 10 foldable-generic ;"
    eval( -- )
] unit-test

{ t } [
    "fold-test" "compiler.tests.folding" lookup-word execute
    "fold-test" "compiler.tests.folding" lookup-word execute
    eq?
] unit-test
