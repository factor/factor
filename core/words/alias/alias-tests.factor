USING: math eval tools.test effects ;
IN: words.alias.tests

ALIAS: foo +
[ ] [ "IN: words.alias.tests CONSTANT: foo 5" eval( -- ) ] unit-test
[ (( -- value )) ] [ \ foo stack-effect ] unit-test
