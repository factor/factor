USING: eval tools.test ;

{ 4 } [ "USE: math 2 2 +" eval( -- result ) ] unit-test
[ "USE: math 2 2 +" eval( -- ) ] must-fail
{ "4\n" } [ "USING: math prettyprint ; 2 2 + ." eval>string ] unit-test

{ "1\n\n--- Data stack:\n4\n" } [ "USE: prettyprint 1 . 4" eval-with-stack>string ] unit-test
{ "1: asdf\n       ^\nNo word named “asdf” found in current vocabulary search path\n" }
[ "asdf" eval-with-stack>string ] unit-test
