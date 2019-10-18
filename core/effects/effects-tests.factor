USING: effects kernel tools.test prettyprint accessors
quotations sequences ;
IN: effects.tests

[ t ] [ { "a" } { "a" } <effect> { "a" "b" } { "a" "b" } <effect> effect<= ] unit-test
[ f ] [ { "a" } { } <effect> { "a" "b" } { "a" "b" } <effect> effect<= ] unit-test
[ t ] [ { "a" "b" } { "a" "b" } <effect> { "a" "b" } { "a" "b" } <effect> effect<= ] unit-test
[ f ] [ { "a" "b" "c" } { "a" "b" "c" } <effect> { "a" "b" } { "a" "b" } <effect> effect<= ] unit-test
[ f ] [ { "a" "b" } { "a" "b" "c" } <effect> { "a" "b" } { "a" "b" } <effect> effect<= ] unit-test
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

[ { object object } ] [ (( a b -- )) effect-in-types ] unit-test
[ { object sequence } ] [ (( a b: sequence -- )) effect-in-types ] unit-test
