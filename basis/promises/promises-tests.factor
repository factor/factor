IN: promises.tests
USING: promises math tools.test ;

LAZY: lazy-test ( a -- b ) 1 + ;

{ 1 1 } [ lazy-test ] must-infer-as
[ 3 ] [ 2 lazy-test force ] unit-test