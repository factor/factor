USING: byte-vectors math prettyprint sequences tools.test
vectors ;
IN: byte-vectors.tests

{ 0 } [ 123 <byte-vector> length ] unit-test

: do-it ( seq -- seq )
    123 [ suffix! ] each-integer ;

{ t } [
    3 <byte-vector> do-it
    3 <vector> do-it sequence=
] unit-test

{ t } [ BV{ } byte-vector? ] unit-test

{ "BV{ }" } [ BV{ } unparse ] unit-test
