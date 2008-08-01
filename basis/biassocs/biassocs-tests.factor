IN: biassocs.tests
USING: biassocs assocs namespaces tools.test ;

<bihash> "h" set

[ 0 ] [ "h" get assoc-size ] unit-test

[ ] [ 1 2 "h" get set-at ] unit-test

[ 1 ] [ 2 "h" get at ] unit-test

[ 2 ] [ 1 "h" get value-at ] unit-test

[ 1 ] [ "h" get assoc-size ] unit-test

[ ] [ 1 3 "h" get set-at ] unit-test

[ 1 ] [ 3 "h" get at ] unit-test

[ 2 ] [ 1 "h" get value-at ] unit-test

[ 2 ] [ "h" get assoc-size ] unit-test
