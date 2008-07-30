IN: help.tests
USING: tools.test help kernel ;

[ 3 throw ] must-fail
[ ] [ :help ] unit-test
