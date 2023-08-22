USING: shuffle tools.test ;

{ 1 2 3 4 } [ 3 4 1 2 2swap ] unit-test

{ 4 2 3 } [ 1 2 3 4 shuffle( a b c d -- d b c ) ] unit-test

{ 2 3 4 5 1 } [ 1 2 3 4 5 5roll ] unit-test
{ 2 3 4 5 6 1 } [ 1 2 3 4 5 6 6roll ] unit-test
{ 2 3 4 5 6 7 1 } [ 1 2 3 4 5 6 7 7roll ] unit-test
{ 2 3 4 5 6 7 8 1 } [ 1 2 3 4 5 6 7 8 8roll ] unit-test
