IN: ascii.tests
USING: ascii tools.test sequences kernel math ;

[ t ] [ CHAR: a letter? ] unit-test
[ f ] [ CHAR: A letter? ] unit-test
[ f ] [ CHAR: a LETTER? ] unit-test
[ t ] [ CHAR: A LETTER? ] unit-test
[ t ] [ CHAR: 0 digit? ] unit-test
[ f ] [ CHAR: x digit? ] unit-test


[ 4 ] [
    0 "There are Four Upper Case characters"
    [ LETTER? [ 1+ ] when ] each
] unit-test
