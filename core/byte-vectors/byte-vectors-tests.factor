IN: byte-vectors.tests
USING: tools.test byte-vectors vectors sequences kernel
prettyprint ;

[ 0 ] [ 123 <byte-vector> length ] unit-test

: do-it ( seq -- seq )
    123 [ over push ] each ;

[ t ] [
    3 <byte-vector> do-it
    3 <vector> do-it sequence=
] unit-test

[ t ] [ BV{ } byte-vector? ] unit-test

[ "BV{ }" ] [ BV{ } unparse ] unit-test
