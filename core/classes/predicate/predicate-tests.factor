USING: math tools.test ;
IN: classes.predicate

PREDICATE: negative < integer 0 < ;
PREDICATE: positive < integer 0 > ;

GENERIC: abs ( n -- n )
M: integer abs ;
M: negative abs -1 * ;
M: positive abs ;

[ 10 ] [ -10 abs ] unit-test
[ 10 ] [ 10 abs ] unit-test
[ 0 ] [ 0 abs ] unit-test
