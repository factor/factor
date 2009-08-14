USING: biassocs assocs namespaces tools.test ;
IN: biassocs.tests

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

H{ { "a" "A" } { "b" "B" } } "a" set

[ ] [ "a" get >biassoc "b" set ] unit-test

[ t ] [ "b" get biassoc? ] unit-test

[ "A" ] [ "a" "b" get at ] unit-test

[ "a" ] [ "A" "b" get value-at ] unit-test
