USING: io.binary tools.test ;
IN: io.binary.tests

[ "\0\0\u000004\u0000d2" ] [ 1234 4 >be ] unit-test
[ "\u0000d2\u000004\0\0" ] [ 1234 4 >le ] unit-test

[ 1234 ] [ 1234 4 >be be> ] unit-test
[ 1234 ] [ 1234 4 >le le> ] unit-test
