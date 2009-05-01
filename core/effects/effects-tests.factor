IN: effects.tests
USING: effects tools.test prettyprint accessors sequences ;

[ t ] [ 1 1 <effect> 2 2 <effect> effect<= ] unit-test
[ f ] [ 1 0 <effect> 2 2 <effect> effect<= ] unit-test
[ t ] [ 2 2 <effect> 2 2 <effect> effect<= ] unit-test
[ f ] [ 3 3 <effect> 2 2 <effect> effect<= ] unit-test
[ f ] [ 2 3 <effect> 2 2 <effect> effect<= ] unit-test
[ 2 ] [ (( a b -- c )) in>> length ] unit-test
[ 1 ] [ (( a b -- c )) out>> length ] unit-test

[ "(( object -- object ))" ] [ { f } { f } <effect> unparse ] unit-test
[ "(( a b -- c d ))" ] [ { "a" "b" } { "c" "d" } <effect> unparse ] unit-test
[ "(( -- c d ))" ] [ { } { "c" "d" } <effect> unparse ] unit-test
[ "(( a b -- ))" ] [ { "a" "b" } { } <effect> unparse ] unit-test
[ "(( -- ))" ] [ { } { } <effect> unparse ] unit-test
[ "(( a b -- c ))" ] [ (( a b -- c )) unparse ] unit-test

[ { "x" "y" } ] [ { "y" "x" } (( a b -- b a )) shuffle ] unit-test
[ { "y" "x" "y" } ] [ { "y" "x" } (( a b -- a b a )) shuffle ] unit-test
[ { } ] [ { "y" "x" } (( a b -- )) shuffle ] unit-test

[ t ] [ (( -- )) (( -- )) compose-effects (( -- )) effect= ] unit-test
[ t ] [ (( -- * )) (( -- )) compose-effects (( -- * )) effect= ] unit-test
[ t ] [ (( -- )) (( -- * )) compose-effects (( -- * )) effect= ] unit-test