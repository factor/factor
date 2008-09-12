USING: tools.test qualified ;
IN: foo
: x 1 ;
IN: bar
: x 2 ;
IN: baz
: x 3 ;

QUALIFIED: foo
QUALIFIED: bar
[ 1 2 3 ] [ foo:x bar:x x ] unit-test

QUALIFIED-WITH: bar p
[ 2 ] [ p:x ] unit-test

RENAME: x baz => y
[ 3 ] [ y ] unit-test

FROM: baz => x ;
[ 3 ] [ x ] unit-test

EXCLUDE: bar => x ;
[ 3 ] [ x ] unit-test

