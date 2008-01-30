IN: temporary
USING: tools.test byte-vectors vectors sequences kernel ;

[ 0 ] [ 123 <byte-vector> length ] unit-test

: do-it
    123 [ over push ] each ;

[ t ] [
    3 <byte-vector> do-it
    3 <vector> do-it sequence=
] unit-test

[ t ] [ BV{ } byte-vector? ] unit-test
