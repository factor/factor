USING: math.transforms.haar tools.test ;
IN: math.transforms.haar.tests

{ { 3 2 -1 -2 3 0 4 1 } } [ { 7 1 6 6 3 -5 4 2 } haar ] unit-test
{ { 7 1 6 6 3 -5 4 2 } } [ { 3 2 -1 -2 3 0 4 1 } rev-haar ] unit-test
