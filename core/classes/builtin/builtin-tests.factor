USING: accessors classes classes.builtin kernel kernel.private
layouts memory sequences tools.test words ;
IN: classes.builtin.tests

{ false } [ f class-of ] unit-test
{ t } [ false builtin-class? ] unit-test
{ 1 } [ false class>type ] unit-test
{ false } [ 1 type>class ] unit-test
{ 1 } [ f tag ] unit-test
{ 1 } [ false type-number ] unit-test

{ t } [ f false? ] unit-test
{ f } [ t false? ] unit-test
{ f } [ 0 false? ] unit-test
{ f } [ false false? ] unit-test

{ f } [ \ f class? ] unit-test
{ t } [ \ f parsing-word? ] unit-test
{ f } [ false parsing-word? ] unit-test
{ f } [ f false eq? ] unit-test

{ word } [ t class-of ] unit-test
{ f } [ t class? ] unit-test
{ f } [ true builtin-class? ] unit-test
{ t } [ t true? ] unit-test
{ f } [ f true? ] unit-test
{ f } [ 1 true? ] unit-test
{ f } [ true true? ] unit-test
{ t } [ t true instance? ] unit-test
{ f } [ \ f true instance? ] unit-test
{ t } [ t boolean? ] unit-test
{ t } [ f boolean? ] unit-test
{ f } [ 1 boolean? ] unit-test
{ f } [ true boolean? ] unit-test
{ f } [ false boolean? ] unit-test

{ f } [
    [ word? ] instances
    [
        [ name>> "f?" = ]
        [ vocabulary>> "syntax" = ] bi and
    ] any?
] unit-test
