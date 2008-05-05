USING: kernel namespaces trees.avl trees.interval tools.test ;
IN: trees.interval.test

SYMBOL: test

<avl> test set

[ f ] [ 2 test get interval-at ] unit-test
[ ] [ 2 1 test get add-single ] unit-test
[ 2 ] [ 1 test get interval-at ] unit-test
[ f ] [ 2 test get interval-at ] unit-test
[ f ] [ 0 test get interval-at ] unit-test

[ ] [ 3 4 8 test get add-range ] unit-test
[ 3 ] [ 5 test get interval-at ] unit-test
[ 3 ] [ 8 test get interval-at ] unit-test
[ 3 ] [ 4 test get interval-at ] unit-test
[ f ] [ 9 test get interval-at ] unit-test
[ 2 ] [ 1 test get interval-at ] unit-test
[ f ] [ 2 test get interval-at ] unit-test
[ f ] [ 0 test get interval-at ] unit-test
