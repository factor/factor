IN: words.constant.tests
USING: tools.test math words.constant ;

CONSTANT: a +

[ + ] [ a ] unit-test

[ t ] [ \ a constant? ] unit-test

CONSTANT: b \ +

[ \ + ] [ b ] unit-test

CONSTANT: c { 1 2 3 }

[ { 1 2 3 } ] [ c ] unit-test

SYMBOL: foo

[ f ] [ \ foo constant? ] unit-test
