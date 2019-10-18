USING: tools.test values math ;
IN: values.tests

VALUE: foo
[ f ] [ foo ] unit-test
[ ] [ 3 to: foo ] unit-test
[ 3 ] [ foo ] unit-test
[ ] [ \ foo [ 1 + ] change-value ] unit-test
[ 4 ] [ foo ] unit-test
