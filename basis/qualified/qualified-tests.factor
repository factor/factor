USING: tools.test qualified eval accessors parser ;
IN: qualified.tests.foo
: x 1 ;
: y 5 ;
IN: qualified.tests.bar
: x 2 ;
: y 4 ;
IN: qualified.tests.baz
: x 3 ;

QUALIFIED: qualified.tests.foo
QUALIFIED: qualified.tests.bar
[ 1 2 3 ] [ qualified.tests.foo:x qualified.tests.bar:x x ] unit-test

QUALIFIED-WITH: qualified.tests.bar p
[ 2 ] [ p:x ] unit-test

RENAME: x qualified.tests.baz => y
[ 3 ] [ y ] unit-test

FROM: qualified.tests.baz => x ;
[ 3 ] [ x ] unit-test
[ 3 ] [ y ] unit-test

EXCLUDE: qualified.tests.bar => x ;
[ 3 ] [ x ] unit-test
[ 4 ] [ y ] unit-test

[ "USE: qualified IN: qualified.tests FROM: qualified.tests => doesnotexist ;" eval ]
[ error>> no-word-error? ] must-fail-with

[ "USE: qualified IN: qualified.tests RENAME: doesnotexist qualified.tests => blah" eval ]
[ error>> no-word-error? ] must-fail-with
