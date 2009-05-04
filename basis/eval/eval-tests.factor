IN: eval.tests
USING: eval tools.test ;

[ 4 ] [ "USE: math 2 2 +" eval( -- result ) ] unit-test
[ "USE: math 2 2 +" eval( -- ) ] must-fail
[ "4\n" ] [ "USING: math prettyprint ; 2 2 + ." eval>string ] unit-test
