IN: scratchpad
USE: test
USE: inference
USE: math
USE: stack
USE: combinators
USE: vectors

[ 6 ] [ 6 gensym-vector vector-length ] unit-test

[ [ 0 | 2 ] ] [ [ 2 "Hello" ] infer ] unit-test
[ [ 1 | 2 ] ] [ [ dup ] infer ] unit-test

[ [ 1 | 2 ] ] [ [ [ dup ] call ] infer ] unit-test
[ [ call ] infer ] unit-test-fails

[ [ 2 | 4 ] ] [ [ 2dup ] infer ] unit-test
[ [ 2 | 0 ] ] [ [ set-vector-length ] infer ] unit-test
[ [ 1 | 0 ] ] [ [ vector-clear ] infer ] unit-test
[ [ 2 | 0 ] ] [ [ vector-push ] infer ] unit-test

[ [ 1 | 0 ] ] [ [ [ ] [ ] ifte ] infer ] unit-test
[ [ ifte ] infer ] unit-test-fails
[ [ [ ] ifte ] infer ] unit-test-fails
[ [ [ 2 ] [ ] ifte ] infer ] unit-test-fails
[ [ 4 | 3 ] ] [ [ [ rot ] [ -rot ] ifte ] infer ] unit-test

[ [ 4 | 3 ] ] [
    [
        [
            [ swap 3 ] [ nip 5 5 ] ifte
        ] [
            -rot
        ] ifte
    ] infer
] unit-test

[ [ 1 | 1 ] ] [ [ dup [ ] when ] infer ] unit-test
[ [ 1 | 1 ] ] [ [ dup [ dup fixnum* ] when ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ [ dup fixnum* ] when ] infer ] unit-test

[ [ 1 | 0 ] ] [ [ [ drop ] when* ] infer ] unit-test
[ [ 1 | 1 ] ] [ [ [ { { [ ] } } ] unless* ] infer ] unit-test
