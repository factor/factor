IN: compiler.tests
USING: words kernel stack-checker alien.strings tools.test
compiler.units ;

[ ] [ [ \ if redefined ] with-compilation-unit [ string>alien ] infer. ] unit-test
