IN: scratchpad
USE: test
USE: inference
USE: math
USE: stack
USE: combinators
USE: vectors
USE: kernel
USE: lists
USE: namespaces

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

! [ t ] [
!     "effects" get [
!         dup [ 7 | 7 ] decompose compose [ 7 | 7 ] =
!     ] all?
! ] unit-test
[ 6 ] [ 6 gensym-vector vector-length ] unit-test

[ 3 ] [ [ { 1 2 } { 1 2 3 } ] max-vector-length ] unit-test

[ t ] [
    [ { 1 2 } { 1 2 3 } ] unify-lengths [ vector-length ] map all=?
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

: bad-recursion-1
    dup [ drop bad-recursion-1 5 ] [ ] ifte ;

[ [ bad-recursion-1 ] infer ] unit-test-fails

: bad-recursion-2
    dup [ uncons bad-recursion-2 ] [ ] ifte ;

[ [ bad-recursion-2 ] infer ] unit-test-fails

! Simple combinators
[ [ 1 | 2 ] ] [ [ [ car ] keep cdr ] infer ] unit-test

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
[ [ bad-bin ] infer ] unit-test-fails

: nested-when ( -- )
    t [
        t [
            5 drop
        ] when
    ] when ;

[ [ 0 | 0 ] ] [ [ nested-when ] infer ] unit-test

: nested-when* ( -- )
    [
        [
            drop
        ] when*
    ] when* ;

[ [ 1 | 0 ] ] [ [ nested-when* ] infer ] unit-test

SYMBOL: sym-test

[ [ 0 | 1 ] ] [ [ sym-test ] infer ] unit-test

[ [ 2 | 1 ] ] [ [ fie ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ foe ] infer ] unit-test

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

[ [ 1 | 1 ] ] [ [ length ] infer ] unit-test
[ [ 1 | 1 ] ] [ [ reverse ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ contains? ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ tree-contains? ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ remove ] infer ] unit-test
! [ [ 1 | 1 ] ] [ [ prune ] infer ] unit-test

[ [ 2 | 1 ] ] [ [ bitor ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ bitand ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ bitxor ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ mod ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ /i ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ /f ] infer ] unit-test
[ [ 2 | 2 ] ] [ [ /mod ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ + ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ - ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ * ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ / ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ < ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ <= ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ > ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ >= ] infer ] unit-test
[ [ 2 | 1 ] ] [ [ number= ] infer ] unit-test

[ [ 2 | 1 ] ] [ [ = ] infer ] unit-test

[ [ 1 | 0 ] ] [ [ >n ] infer ] unit-test
[ [ 0 | 1 ] ] [ [ n> ] infer ] unit-test

[ [ 1 | 1 ] ] [ [ get ] infer ] unit-test
