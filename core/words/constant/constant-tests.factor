IN: words.constant.tests
USING: tools.test math ;

CONSTANT: a +

[ + ] [ a ] unit-test

CONSTANT: b \ +

[ \ + ] [ b ] unit-test

CONSTANT: c { 1 2 3 }

[ { 1 2 3 } ] [ c ] unit-test
