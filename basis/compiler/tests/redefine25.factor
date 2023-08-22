USING: tools.test compiler.units classes.mixin definitions
kernel kernel.private ;
IN: compiler.tests.redefine25

MIXIN: empty-mixin

: empty-mixin-test-1 ( a -- ? ) empty-mixin? ;

TUPLE: a-superclass ;

: empty-mixin-test-2 ( a -- ? ) { a-superclass } declare empty-mixin? ;

TUPLE: empty-mixin-member < a-superclass ;

{ f } [ empty-mixin-member new empty-mixin? ] unit-test
{ f } [ empty-mixin-member new empty-mixin-test-1 ] unit-test
{ f } [ empty-mixin-member new empty-mixin-test-2 ] unit-test

{ } [
    [
        \ empty-mixin-member \ empty-mixin add-mixin-instance
    ] with-compilation-unit
] unit-test

{ t } [ empty-mixin-member new empty-mixin? ] unit-test
{ t } [ empty-mixin-member new empty-mixin-test-1 ] unit-test
{ t } [ empty-mixin-member new empty-mixin-test-2 ] unit-test

{ } [
    [
        \ empty-mixin forget
        \ empty-mixin-member forget
        \ empty-mixin-test-1 forget
        \ empty-mixin-test-2 forget
    ] with-compilation-unit
] unit-test
