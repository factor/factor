
USING: kernel math tools.test ;
IN: compiler.tests.dead-code

: test-outputs0 ( a b -- ) /mod 2drop ;
: test-outputs1 ( a b -- ) /i drop ;
: test-outputs2 ( a b -- ) mod drop ;

{ } [ 10 3 test-outputs0 ] unit-test
{ } [ 10 3 test-outputs1 ] unit-test
{ } [ 10 3 test-outputs2 ] unit-test
