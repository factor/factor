USING: accessors effects eval kernel math sequences
syntax.inferred tools.test words ;
IN: syntax.inferred.tests

?: add1 1 + ;
?: times2 2 * ;
?: combined [ add1 ] [ times2 ] bi * ;
?: mapped [ 1 + ] map ;
?: captured [| n | '[ n + ] ] call ;
?: checked call( x -- y ) ;
?: terminating "inferred termination" throw ;

{ 24 } [ 3 combined ] unit-test
{ { 2 3 } } [ { 1 2 } mapped ] unit-test
{ 7 } [ 3 4 captured call( x -- y ) ] unit-test
{ 5 } [ 4 [ 1 + ] checked ] unit-test
{ t } [ \ add1 stack-effect ( x -- y ) effect= ] unit-test
{ t } [ \ checked stack-effect ( x quot -- y ) effect= ] unit-test
{ t } [ \ terminating stack-effect terminated?>> ] unit-test

[ "USING: kernel syntax.inferred ; IN: syntax.inferred.tests ?: unknown-call call ;" eval( -- ) ] must-fail
[ "USING: kernel syntax.inferred ; IN: syntax.inferred.tests ?: unbalanced [ 1 ] [ ] if ;" eval( -- ) ] must-fail
[ "USING: kernel syntax.inferred ; IN: syntax.inferred.tests ?: add1 call ;" eval( -- ) ] must-fail
{ 5 } [ 4 add1 ] unit-test
