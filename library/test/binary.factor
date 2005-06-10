IN: temporary
USING: stdio test ;

[ "\0\0\u0004\u00d2" ] [ 1234 4 >be ] unit-test
[ "\u00d2\u0004\0\0" ] [ 1234 4 >le ] unit-test

[ 1234 ] [ 1234 4 >be be> ] unit-test
[ 1234 ] [ 1234 4 >le le> ] unit-test
