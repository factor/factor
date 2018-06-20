USING: shuffle tools.test ;

{ 1 2 3 4 } [ 3 4 1 2 2swap ] unit-test

{ 4 2 3 } [ 1 2 3 4 shuffle( a b c d -- d b c ) ] unit-test
