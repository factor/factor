USING: compiler.units definitions tools.test sequences ;
IN: compiler.tests.redefine14

TUPLE: bad ;

M: bad length 1 2 3 ;

[ ] [ [ { bad length } forget ] with-compilation-unit ] unit-test
