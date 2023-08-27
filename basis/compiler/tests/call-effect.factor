USING: tools.test combinators generic.single sequences kernel ;
IN: compiler.tests.call-effect

: execute-ic-test ( a b -- c ) execute( a -- c ) ;

! VM type check error
[ 1 f execute-ic-test ] [ second 3 = ] must-fail-with

: call-test ( q -- ) call( -- ) ;

{ } [ [ ] call-test ] unit-test
{ } [ f [ drop ] curry call-test ] unit-test
{ } [ [ ] [ ] compose call-test ] unit-test
[ [ 1 2 3 ] call-test ] [ wrong-values? ] must-fail-with
