IN: scratchpad
USE: test
USE: inference
USE: math
USE: vectors
USE: kernel
USE: lists
USE: namespaces
USE: parser
USE: kernel
USE: math-internals
USE: generic

[
    [ 1 | 2 ]
    [ 2 | 1 ]
    [ 0 | 3 ]
    [ 4 | 2 ]
    [ 3 | 3 ]
    [ 0 | 0 ]
    [ 1 | 5 ]
    [ 3 | 4 ]
] "effects" set

[ 3 ] [ [ { 1 2 } { 1 2 3 } ] longest-vector ] unit-test

[ t ] [
    [ { 1 2 } { 1 2 3 } ] unify-lengths [ vector-length ] map all=?
] unit-test

[ [ sq ] ] [
    [ sq ] f <literal> [ sq ] f <literal> unify-results literal-value
] unit-test

[ fixnum ] [
    5 f <literal> 6 f <literal> unify-results value-class
] unit-test

[ [ 0 | 2 ] ] [ [ 2 "Hello" ] infer old-effect ] unit-test
[ [ 1 | 2 ] ] [ [ dup ] infer old-effect ] unit-test

[ [ 1 | 2 ] ] [ [ [ dup ] call ] infer old-effect ] unit-test
[ [ call ] infer old-effect ] unit-test-fails

[ [ 2 | 4 ] ] [ [ 2dup ] infer old-effect ] unit-test
[ [ 2 | 0 ] ] [ [ set-vector-length ] infer old-effect ] unit-test
[ [ 2 | 0 ] ] [ [ vector-push ] infer old-effect ] unit-test

[ [ 1 | 0 ] ] [ [ [ ] [ ] ifte ] infer old-effect ] unit-test
[ [ ifte ] infer old-effect ] unit-test-fails
[ [ [ ] ifte ] infer old-effect ] unit-test-fails
[ [ [ 2 ] [ ] ifte ] infer old-effect ] unit-test-fails
[ [ 4 | 3 ] ] [ [ [ rot ] [ -rot ] ifte ] infer old-effect ] unit-test

[ [ 4 | 3 ] ] [
    [
        [
            [ swap 3 ] [ nip 5 5 ] ifte
        ] [
            -rot
        ] ifte
    ] infer old-effect
] unit-test

[ [ 1 | 1 ] ] [ [ dup [ ] when ] infer old-effect ] unit-test
[ [ 1 | 1 ] ] [ [ dup [ dup fixnum* ] when ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ [ dup fixnum* ] when ] infer old-effect ] unit-test

[ [ 1 | 0 ] ] [ [ [ drop ] when* ] infer old-effect ] unit-test
[ [ 1 | 1 ] ] [ [ [ { { [ ] } } ] unless* ] infer old-effect ] unit-test

[ [ 0 | 1 ] ] [
    [ [ 2 2 fixnum+ ] dup [ ] when call ] infer old-effect
] unit-test

[
    [ [ 2 2 fixnum+ ] ] [ [ 2 2 fixnum* ] ] ifte call
] unit-test-fails

: infinite-loop infinite-loop ;

[ [ infinite-loop ] infer old-effect ] unit-test-fails

: simple-recursion-1
    dup [ simple-recursion-1 ] [ ] ifte ;

[ [ 1 | 1 ] ] [ [ simple-recursion-1 ] infer old-effect ] unit-test

: simple-recursion-2
    dup [ ] [ simple-recursion-2 ] ifte ;

[ [ 1 | 1 ] ] [ [ simple-recursion-2 ] infer old-effect ] unit-test

: bad-recursion-1
    dup [ drop bad-recursion-1 5 ] [ ] ifte ;

[ [ bad-recursion-1 ] infer old-effect ] unit-test-fails

: bad-recursion-2
    dup [ uncons bad-recursion-2 ] [ ] ifte ;

[ [ bad-recursion-2 ] infer old-effect ] unit-test-fails

! Simple combinators
[ [ 1 | 2 ] ] [ [ [ car ] keep cdr ] infer old-effect ] unit-test

! Mutual recursion
DEFER: foe

: fie ( element obj -- ? )
    dup cons? [ foe ] [ eq? ] ifte ;

: foe ( element tree -- ? )
    dup [
        2dup car fie [
            nip
        ] [
            cdr dup cons? [
                foe
            ] [
                fie
            ] ifte
        ] ifte
    ] [
        2drop f
    ] ifte ;

! This form should not have a stack effect
: bad-bin 5 [ 5 bad-bin bad-bin 5 ] [ 2drop ] ifte ;
[ [ bad-bin ] infer old-effect ] unit-test-fails

: nested-when ( -- )
    t [
        t [
            5 drop
        ] when
    ] when ;

[ [ 0 | 0 ] ] [ [ nested-when ] infer old-effect ] unit-test

: nested-when* ( -- )
    [
        [
            drop
        ] when*
    ] when* ;

[ [ 1 | 0 ] ] [ [ nested-when* ] infer old-effect ] unit-test

SYMBOL: sym-test

[ [ 0 | 1 ] ] [ [ sym-test ] infer old-effect ] unit-test

[ [ 2 | 1 ] ] [ [ fie ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ foe ] infer old-effect ] unit-test

[ [ 2 | 1 ] ] [ [ 2list ] infer old-effect ] unit-test
[ [ 3 | 1 ] ] [ [ 3list ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ append ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ swons ] infer old-effect ] unit-test
[ [ 1 | 2 ] ] [ [ uncons ] infer old-effect ] unit-test
[ [ 1 | 1 ] ] [ [ unit ] infer old-effect ] unit-test
[ [ 1 | 2 ] ] [ [ unswons ] infer old-effect ] unit-test
[ [ 1 | 1 ] ] [ [ last* ] infer old-effect ] unit-test
[ [ 1 | 1 ] ] [ [ last ] infer old-effect ] unit-test
[ [ 1 | 1 ] ] [ [ list? ] infer old-effect ] unit-test

[ [ 1 | 1 ] ] [ [ length ] infer old-effect ] unit-test
[ [ 1 | 1 ] ] [ [ reverse ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ contains? ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ tree-contains? ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ remove ] infer old-effect ] unit-test
[ [ 1 | 1 ] ] [ [ prune ] infer old-effect ] unit-test

[ [ 2 | 1 ] ] [ [ bitor ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ bitand ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ bitxor ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ mod ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ /i ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ /f ] infer old-effect ] unit-test
[ [ 2 | 2 ] ] [ [ /mod ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ + ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ - ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ * ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ / ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ < ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ <= ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ > ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ >= ] infer old-effect ] unit-test
[ [ 2 | 1 ] ] [ [ number= ] infer old-effect ] unit-test

[ [ 2 | 1 ] ] [ [ = ] infer old-effect ] unit-test

[ [ 1 | 0 ] ] [ [ >n ] infer old-effect ] unit-test
[ [ 0 | 1 ] ] [ [ n> ] infer old-effect ] unit-test

[ [ 1 | 1 ] ] [ [ get ] infer old-effect ] unit-test

! Type inference

[ [ [ object ] [ ] ] ] [ [ drop ] infer ] unit-test
[ [ [ object ] [ object object ] ] ] [ [ dup ] infer ] unit-test
[ [ [ object object ] [ cons ] ] ] [ [ cons ] infer ] unit-test
[ [ [ cons ] [ cons ] ] ] [ [ uncons cons ] infer ] unit-test
[ [ [ object ] [ object ] ] ] [ [ dup [ car ] when ] infer ] unit-test
[ [ [ vector ] [ vector ] ] ] [ [ vector-clone ] infer ] unit-test
[ [ [ number ] [ number ] ] ] [ [ dup + ] infer ] unit-test
[ [ [ number number number ] [ number ] ] ] [ [ digit+ ] infer ] unit-test
