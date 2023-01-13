IN: compiler.tests.redefine20
USING: kernel sequences compiler.units definitions classes.mixin
tools.test ;

GENERIC: cnm-recompile-test ( a -- b )

M: object cnm-recompile-test drop object ;

M: sequence cnm-recompile-test drop sequence ;

TUPLE: funny ;

M: funny cnm-recompile-test call-next-method ;

{ object } [ funny new cnm-recompile-test ] unit-test

{ } [ [ funny sequence add-mixin-instance ] with-compilation-unit ] unit-test

{ sequence } [ funny new cnm-recompile-test ] unit-test

{ } [ [ funny sequence remove-mixin-instance ] with-compilation-unit ] unit-test

{ object } [ funny new cnm-recompile-test ] unit-test
