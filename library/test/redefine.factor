IN: temporary
USING: compiler inference math generic parser ;

USE: test

: foo 1 2 ;
: bar foo foo ; compiled
: foo 1 2 3 ;

[ 1 2 3 1 2 3 ] [ bar ] unit-test
[ [ [ ] [ object object object ] ] ] [ [ foo ] infer ] unit-test

[ ] [
    "IN: temporary : foo ; : bar foo ; : baz foo ; : foo ;" eval
] unit-test
