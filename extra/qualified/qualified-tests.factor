USING: tools.test qualified ;
IN: foo
: x 1 ;
IN: bar
: x 2 ;
QUALIFIED: foo
QUALIFIED: bar
[ 1 2 2 ] [ foo:x bar:x x ] unit-test
