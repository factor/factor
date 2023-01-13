USING: kernel tools.test definitions compiler.units ;
IN: compiler.tests.redefine21

{ } [ : a ( -- ) ; << : b ( quot -- ) call a ; inline >> [ ] b ] unit-test

{ } [ [ { a b } forget-all ] with-compilation-unit ] unit-test

{ } [ : A ( -- ) ; << : B ( -- ) A ; inline >> B ] unit-test

{ } [ [ { A B } forget-all ] with-compilation-unit ] unit-test
