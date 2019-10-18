USING: rpn lists tools.test ;

{ { 2 } } [ "4 2 -" rpn-parse rpn-eval list>array ] unit-test
