USING: tools.test bit-vectors vectors sequences kernel math ;
IN: bit-vectors.tests

{ 0 } [ 123 <bit-vector> length ] unit-test

: do-it ( seq -- )
    1234 swap [ [ even? ] dip push ] curry each-integer ;

{ t } [
    3 <bit-vector> dup do-it
    3 <vector> dup do-it sequence=
] unit-test

{ t } [ ?V{ } bit-vector? ] unit-test
