IN: temporary
USING: arrays errors generic inference kernel lists math
math-internals namespaces parser sequences test vectors ;

[
    << shuffle f { "a" } { } { "a" } { "a" } >>
] [
    << shuffle f { "a" } { } { "a" "a" } { } >>
    << shuffle f { "b" } { } { } { "b" } >>
    compose-shuffle
] unit-test

[
    << shuffle f { "b" "a" } { } { "b" "b" } { } >>
] [
    << shuffle f { "a" } { } { } { } >>
    << shuffle f { "b" } { } { "b" "b" } { } >>
    compose-shuffle
] unit-test

[ @{ 0 2 }@ ] [ [ 2 "Hello" ] infer ] unit-test
[ @{ 1 2 }@ ] [ [ dup ] infer ] unit-test

[ @{ 1 2 }@ ] [ [ [ dup ] call ] infer ] unit-test
[ [ call ] infer ] unit-test-fails

[ @{ 2 4 }@ ] [ [ 2dup ] infer ] unit-test

[ @{ 1 0 }@ ] [ [ [ ] [ ] if ] infer ] unit-test
[ [ if ] infer ] unit-test-fails
[ [ [ ] if ] infer ] unit-test-fails
[ [ [ 2 ] [ ] if ] infer ] unit-test-fails
[ @{ 4 3 }@ ] [ [ [ rot ] [ -rot ] if ] infer ] unit-test

[ @{ 4 3 }@ ] [
    [
        [
            [ swap 3 ] [ nip 5 5 ] if
        ] [
            -rot
        ] if
    ] infer
] unit-test

[ @{ 1 1 }@ ] [ [ dup [ ] when ] infer ] unit-test
[ @{ 1 1 }@ ] [ [ dup [ dup fixnum* ] when ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ [ dup fixnum* ] when ] infer ] unit-test

[ @{ 1 0 }@ ] [ [ [ drop ] when* ] infer ] unit-test
[ @{ 1 1 }@ ] [ [ [ { { [ ] } } ] unless* ] infer ] unit-test

[ @{ 0 1 }@ ] [
    [ [ 2 2 fixnum+ ] dup [ ] when call ] infer
] unit-test

[
    [ [ 2 2 fixnum+ ] ] [ [ 2 2 fixnum* ] ] if call
] unit-test-fails

! Test inference of termination of control flow
: termination-test-1
    "foo" throw ;

: termination-test-2 [ termination-test-1 ] [ 3 ] if ;

[ @{ 1 1 }@ ] [ [ termination-test-2 ] infer ] unit-test

: infinite-loop infinite-loop ;

: simple-recursion-1
    dup [ simple-recursion-1 ] [ ] if ;

[ @{ 1 1 }@ ] [ [ simple-recursion-1 ] infer ] unit-test

: simple-recursion-2
    dup [ ] [ simple-recursion-2 ] if ;

[ @{ 1 1 }@ ] [ [ simple-recursion-2 ] infer ] unit-test

: bad-recursion-2
    dup [ uncons bad-recursion-2 ] [ ] if ;

[ [ bad-recursion-2 ] infer ] unit-test-fails

! Not sure how to fix this one

: funny-recursion
    dup [ funny-recursion 1 ] [ 2 ] if drop ;

[ @{ 1 1 }@ ] [ [ funny-recursion ] infer ] unit-test

! Simple combinators
[ @{ 1 2 }@ ] [ [ [ car ] keep cdr ] infer ] unit-test

! Mutual recursion
DEFER: foe

: fie ( element obj -- ? )
    dup cons? [ foe ] [ eq? ] if ;

: foe ( element tree -- ? )
    dup [
        2dup car fie [
            nip
        ] [
            cdr dup cons? [
                foe
            ] [
                fie
            ] if
        ] if
    ] [
        2drop f
    ] if ;

[ @{ 2 1 }@ ] [ [ fie ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ foe ] infer ] unit-test

: nested-when ( -- )
    t [
        t [
            5 drop
        ] when
    ] when ;

[ @{ 0 0 }@ ] [ [ nested-when ] infer ] unit-test

: nested-when* ( -- )
    [
        [
            drop
        ] when*
    ] when* ;

[ @{ 1 0 }@ ] [ [ nested-when* ] infer ] unit-test

SYMBOL: sym-test

[ @{ 0 1 }@ ] [ [ sym-test ] infer ] unit-test

: terminator-branch
    dup [
        car
    ] [
        not-a-number
    ] if ;

[ @{ 1 1 }@ ] [ [ terminator-branch ] infer ] unit-test

! : recursive-terminator
!     dup [
!         recursive-terminator
!     ] [
!         not-a-number
!     ] if ;
! 
! [ @{ 1 0 }@ ] [ [ recursive-terminator ] infer ] unit-test

GENERIC: potential-hang
M: fixnum potential-hang dup [ potential-hang ] when ;

[ ] [ [ 5 potential-hang ] infer drop ] unit-test

TUPLE: funny-cons car cdr ;
GENERIC: iterate
M: funny-cons iterate funny-cons-cdr iterate ;
M: f iterate drop ;
M: real iterate drop ;

[ @{ 1 0 }@ ] [ [ iterate ] infer ] unit-test

DEFER: agent
: smith 1+ agent ; inline
: agent dup 0 = [ [ swap call ] 2keep smith ] when ; inline
[ @{ 0 2 }@ ]
[ [ [ drop ] 0 agent ] infer ] unit-test

! : no-base-case-1 dup [ no-base-case-1 ] [ no-base-case-1 ] if ;
! [ [ no-base-case-1 ] infer ] unit-test-fails

: no-base-case-2 no-base-case-2 ;
[ [ no-base-case-2 ] infer ] unit-test-fails

[ @{ 2 1 }@ ] [ [ swons ] infer ] unit-test
[ @{ 1 2 }@ ] [ [ uncons ] infer ] unit-test
[ @{ 1 1 }@ ] [ [ unit ] infer ] unit-test
[ @{ 1 2 }@ ] [ [ unswons ] infer ] unit-test
[ @{ 1 1 }@ ] [ [ last ] infer ] unit-test
[ @{ 1 1 }@ ] [ [ list? ] infer ] unit-test

[ @{ 1 0 }@ ] [ [ >n ] infer ] unit-test
[ @{ 0 1 }@ ] [ [ n> ] infer ] unit-test

[ @{ 2 1 }@ ] [ [ bitor ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ bitand ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ bitxor ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ mod ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ /i ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ /f ] infer ] unit-test
[ @{ 2 2 }@ ] [ [ /mod ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ + ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ - ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ * ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ / ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ < ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ <= ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ > ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ >= ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ number= ] infer ] unit-test

[ @{ 1 1 }@ ] [ [ string>number ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ = ] infer ] unit-test
[ @{ 1 1 }@ ] [ [ get ] infer ] unit-test

[ @{ 2 0 }@ ] [ [ push ] infer ] unit-test
[ @{ 2 0 }@ ] [ [ set-length ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ append ] infer ] unit-test
[ @{ 1 1 }@ ] [ [ peek ] infer ] unit-test

[ @{ 1 1 }@ ] [ [ length ] infer ] unit-test
[ @{ 1 1 }@ ] [ [ reverse ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ member? ] infer ] unit-test
[ @{ 2 1 }@ ] [ [ remove ] infer ] unit-test

: bad-code "1234" car ;

[ @{ 0 1 }@ ] [ [ bad-code ] infer ] unit-test

[ 1234 infer ] unit-test-fails

! This form should not have a stack effect
! : bad-bin 5 [ 5 bad-bin bad-bin 5 ] [ 2drop ] if ;
! [ [ bad-bin ] infer ] unit-test-fails

! [ [ infinite-loop ] infer ] unit-test-fails

! : bad-recursion-1
!     dup [ drop bad-recursion-1 5 ] [ ] if ;
! 
! [ [ bad-recursion-1 ] infer ] unit-test-fails

! This hangs

! [ ] [ [ [ dup call ] dup call ] infer ] unit-test-fails
