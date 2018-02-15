USING: math.transforms.haar tools.test ;

{ { 3 2 -1 -2 3 0 4 1 } } [ { 7 1 6 6 3 -5 4 2 } haar ] unit-test
{ { 7 1 6 6 3 -5 4 2 } } [ { 3 2 -1 -2 3 0 4 1 } rev-haar ] unit-test
