IN: temporary
USING: generic inference kernel lists math math-internals
namespaces parser sequences test vectors ;

[ [ 0 2 ] ] [ [ 2 "Hello" ] infer ] unit-test
[ [ 1 2 ] ] [ [ dup ] infer ] unit-test

[ [ 1 2 ] ] [ [ [ dup ] call ] infer ] unit-test
[ [ call ] infer ] unit-test-fails

[ [ 2 4 ] ] [ [ 2dup ] infer ] unit-test

[ [ 1 0 ] ] [ [ [ ] [ ] ifte ] infer ] unit-test
[ [ ifte ] infer ] unit-test-fails
[ [ [ ] ifte ] infer ] unit-test-fails
[ [ [ 2 ] [ ] ifte ] infer ] unit-test-fails
[ [ 4 3 ] ] [ [ [ rot ] [ -rot ] ifte ] infer ] unit-test

[ [ 4 3 ] ] [
    [
        [
            [ swap 3 ] [ nip 5 5 ] ifte
        ] [
            -rot
        ] ifte
    ] infer 
] unit-test

[ [ 1 1 ] ] [ [ dup [ ] when ] infer ] unit-test
[ [ 1 1 ] ] [ [ dup [ dup fixnum* ] when ] infer ] unit-test
[ [ 2 1 ] ] [ [ [ dup fixnum* ] when ] infer ] unit-test

[ [ 1 0 ] ] [ [ [ drop ] when* ] infer ] unit-test
[ [ 1 1 ] ] [ [ [ { { [ ] } } ] unless* ] infer ] unit-test

[ [ 0 1 ] ] [
    [ [ 2 2 fixnum+ ] dup [ ] when call ] infer 
] unit-test

[
    [ [ 2 2 fixnum+ ] ] [ [ 2 2 fixnum* ] ] ifte call
] unit-test-fails

: infinite-loop infinite-loop ;

: simple-recursion-1
    dup [ simple-recursion-1 ] [ ] ifte ;

[ [ 1 1 ] ] [ [ simple-recursion-1 ] infer ] unit-test

: simple-recursion-2
    dup [ ] [ simple-recursion-2 ] ifte ;

[ [ 1 1 ] ] [ [ simple-recursion-2 ] infer ] unit-test

: bad-recursion-2
    dup [ uncons bad-recursion-2 ] [ ] ifte ;

[ [ bad-recursion-2 ] infer ] unit-test-fails

! Not sure how to fix this one

: funny-recursion
    dup [ funny-recursion 1 ] [ 2 ] ifte drop ;

[ [ 1 1 ] ] [ [ funny-recursion ] infer ] unit-test

! Simple combinators
[ [ 1 2 ] ] [ [ [ car ] keep cdr ] infer ] unit-test

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

[ [ 2 1 ] ] [ [ fie ] infer ] unit-test
[ [ 2 1 ] ] [ [ foe ] infer ] unit-test

: nested-when ( -- )
    t [
        t [
            5 drop
        ] when
    ] when ;

[ [ 0 0 ] ] [ [ nested-when ] infer ] unit-test

: nested-when* ( -- )
    [
        [
            drop
        ] when*
    ] when* ;

[ [ 1 0 ] ] [ [ nested-when* ] infer ] unit-test

SYMBOL: sym-test

[ [ 0 1 ] ] [ [ sym-test ] infer ] unit-test

: terminator-branch
    dup [
        car
    ] [
        not-a-number
    ] ifte ;

[ [ 1 1 ] ] [ [ terminator-branch ] infer ] unit-test

: recursive-terminator
    dup [
        recursive-terminator
    ] [
        not-a-number
    ] ifte ;

[ [ 1 1 ] ] [ [ recursive-terminator ] infer ] unit-test

GENERIC: potential-hang
M: fixnum potential-hang dup [ potential-hang ] when ;

[ ] [ [ 5 potential-hang ] infer drop ] unit-test

TUPLE: funny-cons car cdr ;
GENERIC: iterate
M: funny-cons iterate funny-cons-cdr iterate ;
M: f iterate drop ;
M: real iterate drop ;

[ [ 1 0 ] ] [ [ iterate ] infer ] unit-test

[ [ callstack ] infer ] unit-test-fails

! : no-base-case dup [ no-base-case ] [ no-base-case ] ifte ;
! 
! [ [ no-base-case ] infer ] unit-test-fails

[ [ 2 1 ] ] [ [ 2vector ] infer ] unit-test
[ [ 3 1 ] ] [ [ 3vector ] infer ] unit-test
[ [ 2 1 ] ] [ [ swons ] infer ] unit-test
[ [ 1 2 ] ] [ [ uncons ] infer ] unit-test
[ [ 1 1 ] ] [ [ unit ] infer ] unit-test
[ [ 1 2 ] ] [ [ unswons ] infer ] unit-test
[ [ 1 1 ] ] [ [ last ] infer ] unit-test
[ [ 1 1 ] ] [ [ list? ] infer ] unit-test

[ [ 1 0 ] ] [ [ >n ] infer ] unit-test
[ [ 0 1 ] ] [ [ n> ] infer ] unit-test

[ [ 2 1 ] ] [ [ bitor ] infer ] unit-test
[ [ 2 1 ] ] [ [ bitand ] infer ] unit-test
[ [ 2 1 ] ] [ [ bitxor ] infer ] unit-test
[ [ 2 1 ] ] [ [ mod ] infer ] unit-test
[ [ 2 1 ] ] [ [ /i ] infer ] unit-test
[ [ 2 1 ] ] [ [ /f ] infer ] unit-test
[ [ 2 2 ] ] [ [ /mod ] infer ] unit-test
[ [ 2 1 ] ] [ [ + ] infer ] unit-test
[ [ 2 1 ] ] [ [ - ] infer ] unit-test
[ [ 2 1 ] ] [ [ * ] infer ] unit-test
[ [ 2 1 ] ] [ [ / ] infer ] unit-test
[ [ 2 1 ] ] [ [ < ] infer ] unit-test
[ [ 2 1 ] ] [ [ <= ] infer ] unit-test
[ [ 2 1 ] ] [ [ > ] infer ] unit-test
[ [ 2 1 ] ] [ [ >= ] infer ] unit-test
[ [ 2 1 ] ] [ [ number= ] infer ] unit-test

[ [ 1 1 ] ] [ [ str>number ] infer ] unit-test
[ [ 2 1 ] ] [ [ = ] infer ] unit-test
[ [ 1 1 ] ] [ [ get ] infer ] unit-test

[ [ 2 0 ] ] [ [ push ] infer ] unit-test
[ [ 2 0 ] ] [ [ set-length ] infer ] unit-test
[ [ 2 1 ] ] [ [ append ] infer ] unit-test
[ [ 1 1 ] ] [ [ peek ] infer ] unit-test

[ [ 1 1 ] ] [ [ length ] infer ] unit-test
[ [ 1 1 ] ] [ [ reverse ] infer ] unit-test
[ [ 2 1 ] ] [ [ member? ] infer ] unit-test
[ [ 2 1 ] ] [ [ remove ] infer ] unit-test
[ [ 1 1 ] ] [ [ prune ] infer ] unit-test

: bad-code "1234" car ;

[ [ 0 1 ] ] [ [ bad-code ] infer ] unit-test

! Type inference

! [ [ [ object ] [ ] ] ] [ [ drop ] infer ] unit-test
! [ [ [ object ] [ object object ] ] ] [ [ dup ] infer ] unit-test
! [ [ [ object object ] [ cons ] ] ] [ [ cons ] infer ] unit-test
! [ [ [ object ] [ boolean ] ] ] [ [ dup [ drop t ] unless ] infer ] unit-test
! [ [ [ general-list ] [ cons ] ] ] [ [ uncons cons ] infer ] unit-test

! [ [ 5 car ] infer ] unit-test-fails

! [ [ [ number ] [ number ] ] ] [ [ dup + ] infer ] unit-test
! [ [ [ number number number ] [ number ] ] ] [ [ digit+ ] infer ] unit-test
! [ [ [ number ] [ real real ] ] ] [ [ >rect ] infer ] unit-test

! [ [ [ ] [ POSTPONE: t ] ] ] [ [ f not ] infer ] unit-test
! [ [ [ ] [ POSTPONE: f ] ] ] [ [ t not ] infer ] unit-test
! [ [ [ ] [ POSTPONE: f ] ] ] [ [ 5 not ] infer ] unit-test
! [ [ [ object ] [ general-t ] ] ] [ [ dup [ not ] unless ] infer ] unit-test

! [ [ [ object ] [ cons ] ] ] [ [ dup cons? [ drop [[ 1 2 ]] ] unless ] infer ] unit-test

! This form should not have a stack effect
! : bad-bin 5 [ 5 bad-bin bad-bin 5 ] [ 2drop ] ifte ;
! [ [ bad-bin ] infer ] unit-test-fails

! [ [ infinite-loop ] infer ] unit-test-fails

! : bad-recursion-1
!     dup [ drop bad-recursion-1 5 ] [ ] ifte ;
! 
! [ [ bad-recursion-1 ] infer ] unit-test-fails
