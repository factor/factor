IN: temporary
USING: compiler inference math ;

USE: test

: foo 1 2 ;
: bar foo foo ; compiled
: foo 1 2 3 ;

[ 1 2 3 1 2 3 ] [ bar ] unit-test
[ [ 0 3 ] ] [ [ foo ] infer ] unit-test
