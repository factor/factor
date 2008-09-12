USING: tools.test float-vectors vectors sequences kernel math ;
IN: float-vectors.tests

[ 0 ] [ 123 <float-vector> length ] unit-test

: do-it
    12345 [ >float over push ] each ;

[ t ] [
    3 <float-vector> do-it
    3 <vector> do-it sequence=
] unit-test

[ t ] [ FV{ } float-vector? ] unit-test
