IN: compiler.tests.call-effect
USING: tools.test combinators generic.single sequences kernel ;

: execute-ic-test ( a b -- c ) execute( a -- c ) ;

! VM type check error
[ 1 f execute-ic-test ] [ second 3 = ] must-fail-with