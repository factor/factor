USING: kernel namespaces interval-maps tools.test ;
IN: interval-maps.test

SYMBOL: test

[ ] [ { { { 4 8 } 3 } { 1 2 } } <interval-map> test set ] unit-test
[ 3 ] [ 5 test get interval-at ] unit-test
[ 3 ] [ 8 test get interval-at ] unit-test
[ 3 ] [ 4 test get interval-at ] unit-test
[ f ] [ 9 test get interval-at ] unit-test
[ 2 ] [ 1 test get interval-at ] unit-test
[ f ] [ 2 test get interval-at ] unit-test
[ f ] [ 0 test get interval-at ] unit-test
