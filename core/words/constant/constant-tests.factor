USING: math tools.test words.constant ;
IN: words.constant.tests

CONSTANT: a +

{ + } [ a ] unit-test

{ t } [ \ a constant? ] unit-test

CONSTANT: b \ +

{ \ + } [ b ] unit-test

CONSTANT: c { 1 2 3 }

{ { 1 2 3 } } [ c ] unit-test

SYMBOL: foo

{ f } [ \ foo constant? ] unit-test
