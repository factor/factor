USING: kernel tools.test tuples.lib ;
IN: temporary

TUPLE: foo a b* c d* e f* ;

[ 1 2 3 4 5 6 ] [ 1 2 3 4 5 6 \ foo construct-boa \ foo >tuple< ] unit-test
[ 2 4 6 ] [ 1 2 3 4 5 6 \ foo construct-boa \ foo >tuple*< ] unit-test

