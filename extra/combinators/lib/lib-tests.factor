USING: combinators.lib kernel math random sequences tools.test continuations
    arrays vectors ;
IN: combinators.lib.tests

[ 5 ] [ [ 10 random ] [ 5 = ] generate ] unit-test
[ t ] [ [ 10 random ] [ even? ] generate even? ] unit-test

[ { "foo" "xbarx" } ]
[
    { "oof" "bar" } { [ reverse ] [ "x" swap "x" 3append ] } parallel-call
] unit-test

{ 1 1 } [
    [ even? ] [ drop 1 ] [ drop 2 ] ifte
] must-infer-as
