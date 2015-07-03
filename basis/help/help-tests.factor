USING: tools.test help kernel ;
IN: help.tests

[ 3 throw ] must-fail
{ } [ :help ] unit-test
{ } [ f print-topic ] unit-test
