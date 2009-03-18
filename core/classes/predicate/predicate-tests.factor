USING: math tools.test classes.algebra words kernel sequences assocs ;
IN: classes.predicate

PREDICATE: negative < integer 0 < ;
PREDICATE: positive < integer 0 > ;

[ t ] [ negative integer class< ] unit-test
[ t ] [ positive integer class< ] unit-test
[ f ] [ integer negative class< ] unit-test
[ f ] [ integer positive class< ] unit-test
[ f ] [ negative negative class< ] unit-test
[ f ] [ positive negative class< ] unit-test

GENERIC: abs ( n -- n )
M: integer abs ;
M: negative abs -1 * ;
M: positive abs ;

[ 10 ] [ -10 abs ] unit-test
[ 10 ] [ 10 abs ] unit-test
[ 0 ] [ 0 abs ] unit-test