IN: compiler.tests.generic
USING: tools.test math kernel compiler.units definitions ;

GENERIC: bad ( -- )
M: integer bad ;
M: object bad ;

[ 0 bad ] must-fail
[ "" bad ] must-fail

[ ] [ [ \ bad forget ] with-compilation-unit ] unit-test