IN: temporary
USING: generic inference kernel lists math math-internals
namespaces parser sequences test vectors ;

: simple-effect 2unseq >r length r> length 2vector ;

[ { 0 2 } ] [ [ 2 "Hello" ] infer simple-effect ] unit-test
[ { 1 2 } ] [ [ dup ] infer simple-effect ] unit-test

[ { 1 2 } ] [ [ [ dup ] call ] infer simple-effect ] unit-test
[ [ call ] infer simple-effect ] unit-test-fails

[ { 2 4 } ] [ [ 2dup ] infer simple-effect ] unit-test

[ { 1 0 } ] [ [ [ ] [ ] ifte ] infer simple-effect ] unit-test
[ [ ifte ] infer simple-effect ] unit-test-fails
[ [ [ ] ifte ] infer simple-effect ] unit-test-fails
[ [ [ 2 ] [ ] ifte ] infer simple-effect ] unit-test-fails
[ { 4 3 } ] [ [ [ rot ] [ -rot ] ifte ] infer simple-effect ] unit-test

[ { 4 3 } ] [
    [
        [
            [ swap 3 ] [ nip 5 5 ] ifte
        ] [
            -rot
        ] ifte
    ] infer simple-effect
] unit-test

[ { 1 1 } ] [ [ dup [ ] when ] infer simple-effect ] unit-test
[ { 1 1 } ] [ [ dup [ dup fixnum* ] when ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ [ dup fixnum* ] when ] infer simple-effect ] unit-test

[ { 1 0 } ] [ [ [ drop ] when* ] infer simple-effect ] unit-test
[ { 1 1 } ] [ [ [ { { [ ] } } ] unless* ] infer simple-effect ] unit-test

[ { 0 1 } ] [
    [ [ 2 2 fixnum+ ] dup [ ] when call ] infer simple-effect
] unit-test

[
    [ [ 2 2 fixnum+ ] ] [ [ 2 2 fixnum* ] ] ifte call
] unit-test-fails

: infinite-loop infinite-loop ;

: simple-recursion-1
    dup [ simple-recursion-1 ] [ ] ifte ;

[ { 1 1 } ] [ [ simple-recursion-1 ] infer simple-effect ] unit-test

: simple-recursion-2
    dup [ ] [ simple-recursion-2 ] ifte ;

[ { 1 1 } ] [ [ simple-recursion-2 ] infer simple-effect ] unit-test

: bad-recursion-2
    dup [ uncons bad-recursion-2 ] [ ] ifte ;

[ [ bad-recursion-2 ] infer simple-effect ] unit-test-fails

! Not sure how to fix this one

: funny-recursion
    dup [ funny-recursion 1 ] [ 2 ] ifte drop ;

[ { 1 1 } ] [ [ funny-recursion ] infer simple-effect ] unit-test

! Simple combinators
[ { 1 2 } ] [ [ [ car ] keep cdr ] infer simple-effect ] unit-test

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

[ { 2 1 } ] [ [ fie ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ foe ] infer simple-effect ] unit-test

: nested-when ( -- )
    t [
        t [
            5 drop
        ] when
    ] when ;

[ { 0 0 } ] [ [ nested-when ] infer simple-effect ] unit-test

: nested-when* ( -- )
    [
        [
            drop
        ] when*
    ] when* ;

[ { 1 0 } ] [ [ nested-when* ] infer simple-effect ] unit-test

SYMBOL: sym-test

[ { 0 1 } ] [ [ sym-test ] infer simple-effect ] unit-test

: terminator-branch
    dup [
        car
    ] [
        not-a-number
    ] ifte ;

[ { 1 1 } ] [ [ terminator-branch ] infer simple-effect ] unit-test

: recursive-terminator
    dup [
        recursive-terminator
    ] [
        not-a-number
    ] ifte ;

[ { 1 1 } ] [ [ recursive-terminator ] infer simple-effect ] unit-test

GENERIC: potential-hang
M: fixnum potential-hang dup [ potential-hang ] when ;

[ ] [ [ 5 potential-hang ] infer drop ] unit-test

TUPLE: funny-cons car cdr ;
GENERIC: iterate
M: funny-cons iterate funny-cons-cdr iterate ;
M: f iterate drop ;
M: real iterate drop ;

[ { 1 0 } ] [ [ iterate ] infer simple-effect ] unit-test

[ [ callstack ] infer simple-effect ] unit-test-fails

! : no-base-case dup [ no-base-case ] [ no-base-case ] ifte ;
! 
! [ [ no-base-case ] infer simple-effect ] unit-test-fails

[ { 2 1 } ] [ [ 2vector ] infer simple-effect ] unit-test
[ { 3 1 } ] [ [ 3vector ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ swons ] infer simple-effect ] unit-test
[ { 1 2 } ] [ [ uncons ] infer simple-effect ] unit-test
[ { 1 1 } ] [ [ unit ] infer simple-effect ] unit-test
[ { 1 2 } ] [ [ unswons ] infer simple-effect ] unit-test
[ { 1 1 } ] [ [ last ] infer simple-effect ] unit-test
[ { 1 1 } ] [ [ list? ] infer simple-effect ] unit-test

[ { 1 0 } ] [ [ >n ] infer simple-effect ] unit-test
[ { 0 1 } ] [ [ n> ] infer simple-effect ] unit-test

[ { 2 1 } ] [ [ bitor ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ bitand ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ bitxor ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ mod ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ /i ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ /f ] infer simple-effect ] unit-test
[ { 2 2 } ] [ [ /mod ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ + ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ - ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ * ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ / ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ < ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ <= ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ > ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ >= ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ number= ] infer simple-effect ] unit-test

[ { 1 1 } ] [ [ string>number ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ = ] infer simple-effect ] unit-test
[ { 1 1 } ] [ [ get ] infer simple-effect ] unit-test

[ { 2 0 } ] [ [ push ] infer simple-effect ] unit-test
[ { 2 0 } ] [ [ set-length ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ append ] infer simple-effect ] unit-test
[ { 1 1 } ] [ [ peek ] infer simple-effect ] unit-test

[ { 1 1 } ] [ [ length ] infer simple-effect ] unit-test
[ { 1 1 } ] [ [ reverse ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ member? ] infer simple-effect ] unit-test
[ { 2 1 } ] [ [ remove ] infer simple-effect ] unit-test
[ { 1 1 } ] [ [ prune ] infer simple-effect ] unit-test

: bad-code "1234" car ;

[ { 0 1 } ] [ [ bad-code ] infer simple-effect ] unit-test

! Type inference

! [ [ [ object ] [ ] ] ] [ [ drop ] infer simple-effect ] unit-test
! [ [ [ object ] [ object object ] ] ] [ [ dup ] infer simple-effect ] unit-test
! [ [ [ object object ] [ cons ] ] ] [ [ cons ] infer simple-effect ] unit-test
! [ [ [ object ] [ boolean ] ] ] [ [ dup [ drop t ] unless ] infer simple-effect ] unit-test
! [ [ [ general-list ] [ cons ] ] ] [ [ uncons cons ] infer simple-effect ] unit-test

! [ [ 5 car ] infer simple-effect ] unit-test-fails

! [ [ [ number ] [ number ] ] ] [ [ dup + ] infer simple-effect ] unit-test
! [ [ [ number number number ] [ number ] ] ] [ [ digit+ ] infer simple-effect ] unit-test
! [ [ [ number ] [ real real ] ] ] [ [ >rect ] infer simple-effect ] unit-test

! [ [ [ ] [ POSTPONE: t ] ] ] [ [ f not ] infer simple-effect ] unit-test
! [ [ [ ] [ POSTPONE: f ] ] ] [ [ t not ] infer simple-effect ] unit-test
! [ [ [ ] [ POSTPONE: f ] ] ] [ [ 5 not ] infer simple-effect ] unit-test
! [ [ [ object ] [ general-t ] ] ] [ [ dup [ not ] unless ] infer simple-effect ] unit-test

! [ [ [ object ] [ cons ] ] ] [ [ dup cons? [ drop [{ 1 2 }] ] unless ] infer simple-effect ] unit-test

! This form should not have a stack effect
! : bad-bin 5 [ 5 bad-bin bad-bin 5 ] [ 2drop ] ifte ;
! [ [ bad-bin ] infer simple-effect ] unit-test-fails

! [ [ infinite-loop ] infer simple-effect ] unit-test-fails

! : bad-recursion-1
!     dup [ drop bad-recursion-1 5 ] [ ] ifte ;
! 
! [ [ bad-recursion-1 ] infer simple-effect ] unit-test-fails
