USING: shuffle tools.test ;
IN: shuffle.tests

{ 1 2 3 4 } [ 3 4 1 2 2swap ] unit-test

{ 4 2 3 } [ 1 2 3 4 shuffle( a b c d -- d b c ) ] unit-test

{ 2 3 4 1 } [ 1 2 3 4 roll ] unit-test
{ 1 2 3 4 } [ 2 3 4 1 -roll ] unit-test
