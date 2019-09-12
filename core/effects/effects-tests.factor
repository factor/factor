USING: accessors effects effects.parser eval kernel prettyprint
sequences tools.test math ;

{ t } [ { "a" } { "a" } <effect> { "a" "b" } { "a" "b" } <effect> effect<= ] unit-test
{ f } [ { "a" } { } <effect> { "a" "b" } { "a" "b" } <effect> effect<= ] unit-test
{ t } [ { "a" "b" } { "a" "b" } <effect> { "a" "b" } { "a" "b" } <effect> effect<= ] unit-test
{ f } [ { "a" "b" "c" } { "a" "b" "c" } <effect> { "a" "b" } { "a" "b" } <effect> effect<= ] unit-test
{ f } [ { "a" "b" } { "a" "b" "c" } <effect> { "a" "b" } { "a" "b" } <effect> effect<= ] unit-test
{ 2 } [ ( a b -- c ) in>> length ] unit-test
{ 1 } [ ( a b -- c ) out>> length ] unit-test

{ t } [ ( a b -- c ) ( ... a b -- ... c ) effect<= ] unit-test
{ t } [ ( b -- ) ( ... a b -- ... c ) effect<= ] unit-test
{ f } [ ( ... a b -- ... c ) ( a b -- c ) effect<= ] unit-test
{ f } [ ( ... b -- ... ) ( a b -- c ) effect<= ] unit-test
{ f } [ ( a b -- c ) ( ... a b -- c ) effect<= ] unit-test
{ f } [ ( a b -- c ) ( ..x a b -- ..y c ) effect<= ] unit-test

{ "( object -- object )" } [ { f } { f } <effect> unparse ] unit-test
{ "( a b -- c d )" } [ { "a" "b" } { "c" "d" } <effect> unparse ] unit-test
{ "( -- c d )" } [ { } { "c" "d" } <effect> unparse ] unit-test
{ "( a b -- )" } [ { "a" "b" } { } <effect> unparse ] unit-test
{ "( -- )" } [ { } { } <effect> unparse ] unit-test
{ "( a b -- c )" } [ ( a b -- c ) unparse ] unit-test

{ { "x" "y" } } [ { "y" "x" } ( a b -- b a ) shuffle ] unit-test
{ { "y" "x" "y" } } [ { "y" "x" } ( a b -- a b a ) shuffle ] unit-test
{ { } } [ { "y" "x" } ( a b -- ) shuffle ] unit-test

{ t } [ ( -- ) ( -- ) compose-effects ( -- ) effect= ] unit-test
{ t } [ ( -- * ) ( -- ) compose-effects ( -- * ) effect= ] unit-test
{ t } [ ( -- ) ( -- * ) compose-effects ( -- * ) effect= ] unit-test

{ { object object } } [ ( a b -- ) effect-in-types ] unit-test
{ { object sequence } } [ ( a b: sequence -- ) effect-in-types ] unit-test

{ f   } [ ( a b c -- d ) in-var>> ] unit-test
{ f   } [ ( -- d ) in-var>> ] unit-test
{ "a" } [ ( ..a b c -- d ) in-var>> ] unit-test
{ { "b" "c" } } [ ( ..a b c -- d ) in>> ] unit-test

{ f   } [ ( ..a b c -- e ) out-var>> ] unit-test
{ "d" } [ ( ..a b c -- ..d e ) out-var>> ] unit-test
{ { "e" } } [ ( ..a b c -- ..d e ) out>> ] unit-test

[ "( a ..b c -- d )" eval( -- effect ) ]
[ error>> invalid-row-variable? ] must-fail-with

[ "( ..a: integer b c -- d )" eval( -- effect ) ]
[ error>> row-variable-can't-have-type? ] must-fail-with

! test curry-effect
{ ( -- x ) } [ ( c -- d ) curry-effect ] unit-test
{ ( -- x x ) } [ ( -- d ) curry-effect ] unit-test
{ ( x -- ) } [ ( a b -- ) curry-effect ] unit-test

! test unnamed types
{ ( :fixnum -- :float ) } [ ( :fixnum -- :float ) ] unit-test
{ ( :union{ fixnum bignum } -- ) } [ ( :union{ fixnum bignum } -- ) ] unit-test

{ "( :( :integer -- :integer ) :float -- :bignum )" }
[ ( :( :integer -- :integer ) :float -- :bignum ) unparse ] unit-test

{ t } [ ( ..a x quot: ( ..a -- ..b ) -- ..b ) dup clone = ] unit-test
