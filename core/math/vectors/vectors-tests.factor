IN: temporary
USING: math.vectors tools.test ;

[ { 1 2 3 } ] [ 1/2 { 2 4 6 } n*v ] unit-test
[ { 1 2 3 } ] [ { 2 4 6 } 1/2 v*n ] unit-test
[ { 1 2 3 } ] [ { 2 4 6 } 2 v/n ] unit-test
[ { 1/1 1/2 1/3 } ] [ 1 { 1 2 3 } n/v ] unit-test
