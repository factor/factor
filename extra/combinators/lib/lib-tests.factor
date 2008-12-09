USING: combinators.lib kernel math random sequences tools.test continuations
    arrays vectors ;
IN: combinators.lib.tests

[ 6 -1 ] [ 5 0 1 [ + ] [ - ] bi, bi* ] unit-test
[ 6 -1 1 ] [ 5 0 1 1 [ + ] [ - ] [ * ] tri, tri* ] unit-test

[ 5 4 ] [ 5 0 1 [ + ] [ - ] bi*, bi ] unit-test
[ 5 4 5 ] [ 5 0 1 1 [ + ] [ - ] [ * ] tri*, tri ] unit-test

[ 5 6 ] [ 5 0 1 [ + ] bi@, bi ] unit-test
[ 5 6 7 ] [ 5 0 1 2 [ + ] tri@, tri ] unit-test

[ 5 ] [ [ 10 random ] [ 5 = ] generate ] unit-test
[ t ] [ [ 10 random ] [ even? ] generate even? ] unit-test

[ { "foo" "xbarx" } ]
[
    { "oof" "bar" } { [ reverse ] [ "x" dup surround ] } parallel-call
] unit-test

{ 1 1 } [
    [ even? ] [ drop 1 ] [ drop 2 ] ifte
] must-infer-as
