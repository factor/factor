IN: scratchpad
USE: test
USE: inference
USE: math
USE: stack
USE: combinators
USE: vectors
USE: kernel
USE: lists

[ 6 ] [ 6 gensym-vector vector-length ] unit-test

[ t ] [
    { 1 2 } { 1 2 3 } 
    unify-lengths swap vector-length swap vector-length =
] unit-test

[ [ sq ] ] [ [ sq ] [ sq ] unify-result ] unit-test

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

[ [ 0 | 1 ] ] [
    [ [ 2 2 fixnum+ ] dup [ ] when call ] infer
] unit-test

[
    [ [ 2 2 fixnum+ ] ] [ [ 2 2 fixnum* ] ] ifte call
] unit-test-fails

: infinite-loop infinite-loop ;

[ [ infinite-loop ] infer ] unit-test-fails

: simple-recursion-1
    dup [ simple-recursion-1 ] [ ] ifte ;

[ [ 1 | 1 ] ] [ [ simple-recursion-1 ] infer ] unit-test

: simple-recursion-2
    dup [ ] [ simple-recursion-2 ] ifte ;

[ [ 1 | 1 ] ] [ [ simple-recursion-2 ] infer ] unit-test

[ [ 2 | 1 ] ] [ [ 2list ] infer ] unit-test
[ [ 3 | 1 ] ] [ [ 3list ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ append ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ swons ] infer ] unit-test
[ [ 1 | 2 ] ] [ [ uncons ] infer ] unit-test
[ [ 1 | 1 ] ] [ [ unit ] infer ] unit-test
[ [ 1 | 2 ] ] [ [ unswons ] infer ] unit-test
! [ [ 1 | 1 ] ] [ [ last* ] infer ] unit-test
! [ [ 1 | 1 ] ] [ [ last ] infer ] unit-test
! [ [ 1 | 1 ] ] [ [ list? ] infer ] unit-test
