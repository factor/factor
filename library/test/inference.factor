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

! [ [ [ object object ] f ] ]
! [ [ [ object ] [ object object ] ] [ [ object ] f ] decompose ]
! unit-test
! 
! [ [ [ cons vector cons integer object cons ] [ cons vector cons ] ] ]
! [
!     [ [ vector ] [ cons vector cons integer object cons ] ]
!     [ [ vector ] [ cons vector cons ] ]
!     decompose
! ] unit-test
! 
! [ [ [ object ] [ object ] ] ]
! [
!     [ [ object number ] [ object ] ]
!     [ [ object number ] [ object ] ]
!     decompose
! ] unit-test

: old-effect ( [ in-types out-types ] -- [[ in out ]] )
    uncons car length >r length r> cons ;

[ [[ 0 2 ]] ] [ [ 2 "Hello" ] infer old-effect ] unit-test
[ [[ 1 2 ]] ] [ [ dup ] infer old-effect ] unit-test

[ [[ 1 2 ]] ] [ [ [ dup ] call ] infer old-effect ] unit-test
[ [ call ] infer old-effect ] unit-test-fails

[ [[ 2 4 ]] ] [ [ 2dup ] infer old-effect ] unit-test
[ [[ 2 0 ]] ] [ [ vector-push ] infer old-effect ] unit-test

[ [[ 1 0 ]] ] [ [ [ ] [ ] ifte ] infer old-effect ] unit-test
[ [ ifte ] infer old-effect ] unit-test-fails
[ [ [ ] ifte ] infer old-effect ] unit-test-fails
[ [ [ 2 ] [ ] ifte ] infer old-effect ] unit-test-fails
[ [[ 4 3 ]] ] [ [ [ rot ] [ -rot ] ifte ] infer old-effect ] unit-test

[ [[ 4 3 ]] ] [
    [
        [
            [ swap 3 ] [ nip 5 5 ] ifte
        ] [
            -rot
        ] ifte
    ] infer old-effect
] unit-test

[ [[ 1 1 ]] ] [ [ dup [ ] when ] infer old-effect ] unit-test
[ [[ 1 1 ]] ] [ [ dup [ dup fixnum* ] when ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ [ dup fixnum* ] when ] infer old-effect ] unit-test

[ [[ 1 0 ]] ] [ [ [ drop ] when* ] infer old-effect ] unit-test
[ [[ 1 1 ]] ] [ [ [ { { [ ] } } ] unless* ] infer old-effect ] unit-test

[ [[ 0 1 ]] ] [
    [ [ 2 2 fixnum+ ] dup [ ] when call ] infer old-effect
] unit-test

[
    [ [ 2 2 fixnum+ ] ] [ [ 2 2 fixnum* ] ] ifte call
] unit-test-fails

: infinite-loop infinite-loop ;

[ [ infinite-loop ] infer old-effect ] unit-test-fails

: simple-recursion-1
    dup [ simple-recursion-1 ] [ ] ifte ;

[ [[ 1 1 ]] ] [ [ simple-recursion-1 ] infer old-effect ] unit-test

: simple-recursion-2
    dup [ ] [ simple-recursion-2 ] ifte ;

[ [[ 1 1 ]] ] [ [ simple-recursion-2 ] infer old-effect ] unit-test

! : bad-recursion-1
!     dup [ drop bad-recursion-1 5 ] [ ] ifte ;
! 
! [ [ bad-recursion-1 ] infer old-effect ] unit-test-fails

: bad-recursion-2
    dup [ uncons bad-recursion-2 ] [ ] ifte ;

[ [ bad-recursion-2 ] infer old-effect ] unit-test-fails

! Not sure how to fix this one

: funny-recursion
    dup [ funny-recursion 1 ] [ 2 ] ifte drop ;

[ [[ 1 1 ]] ] [ [ funny-recursion ] infer old-effect ] unit-test

! Simple combinators
[ [[ 1 2 ]] ] [ [ [ car ] keep cdr ] infer old-effect ] unit-test

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

[ [[ 2 1 ]] ] [ [ fie ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ foe ] infer old-effect ] unit-test

! This form should not have a stack effect
! : bad-bin 5 [ 5 bad-bin bad-bin 5 ] [ 2drop ] ifte ;
! [ [ bad-bin ] infer old-effect ] unit-test-fails

: nested-when ( -- )
    t [
        t [
            5 drop
        ] when
    ] when ;

[ [[ 0 0 ]] ] [ [ nested-when ] infer old-effect ] unit-test

: nested-when* ( -- )
    [
        [
            drop
        ] when*
    ] when* ;

[ [[ 1 0 ]] ] [ [ nested-when* ] infer old-effect ] unit-test

SYMBOL: sym-test

[ [[ 0 1 ]] ] [ [ sym-test ] infer old-effect ] unit-test


[ [[ 2 0 ]] ] [ [ set-vector-length ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ 2list ] infer old-effect ] unit-test
[ [[ 3 1 ]] ] [ [ 3list ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ append ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ swons ] infer old-effect ] unit-test
[ [[ 1 2 ]] ] [ [ uncons ] infer old-effect ] unit-test
[ [[ 1 1 ]] ] [ [ unit ] infer old-effect ] unit-test
[ [[ 1 2 ]] ] [ [ unswons ] infer old-effect ] unit-test
[ [[ 1 1 ]] ] [ [ last* ] infer old-effect ] unit-test
[ [[ 1 1 ]] ] [ [ last ] infer old-effect ] unit-test
[ [[ 1 1 ]] ] [ [ list? ] infer old-effect ] unit-test

[ [[ 1 1 ]] ] [ [ length ] infer old-effect ] unit-test
[ [[ 1 1 ]] ] [ [ reverse ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ contains? ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ tree-contains? ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ remove ] infer old-effect ] unit-test
[ [[ 1 1 ]] ] [ [ prune ] infer old-effect ] unit-test

[ [[ 2 1 ]] ] [ [ bitor ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ bitand ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ bitxor ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ mod ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ /i ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ /f ] infer old-effect ] unit-test
[ [[ 2 2 ]] ] [ [ /mod ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ + ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ - ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ * ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ / ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ < ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ <= ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ > ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ >= ] infer old-effect ] unit-test
[ [[ 2 1 ]] ] [ [ number= ] infer old-effect ] unit-test

[ [[ 2 1 ]] ] [ [ = ] infer old-effect ] unit-test

[ [[ 1 0 ]] ] [ [ >n ] infer old-effect ] unit-test
[ [[ 0 1 ]] ] [ [ n> ] infer old-effect ] unit-test

[ [[ 1 1 ]] ] [ [ get ] infer old-effect ] unit-test

: terminator-branch
    dup [
        car
    ] [
        not-a-number
    ] ifte ;

[ [[ 1 1 ]] ] [ [ terminator-branch ] infer old-effect ] unit-test

[ [[ 1 1 ]] ] [ [ str>number ] infer old-effect ] unit-test

! Type inference

[ [ [ object ] [ ] ] ] [ [ drop ] infer ] unit-test
[ [ [ object ] [ object object ] ] ] [ [ dup ] infer ] unit-test
[ [ [ object object ] [ cons ] ] ] [ [ cons ] infer ] unit-test
[ [ [ object ] [ general-t ] ] ] [ [ dup [ drop t ] unless ] infer ] unit-test
[ [ [ cons ] [ cons ] ] ] [ [ uncons cons ] infer ] unit-test
[ [ [ general-list ] [ object ] ] ] [ [ dup [ car ] when ] infer ] unit-test

! [ [ 5 car ] infer ] unit-test-fails

GENERIC: potential-hang
M: fixnum potential-hang dup [ potential-hang ] when ;

[ ] [ [ 5 potential-hang ] infer drop ] unit-test

! [ [ [ number ] [ number ] ] ] [ [ dup + ] infer ] unit-test
! [ [ [ number number number ] [ number ] ] ] [ [ digit+ ] infer ] unit-test
! [ [ [ number ] [ real real ] ] ] [ [ >rect ] infer ] unit-test

! [ [ [ ] [ POSTPONE: t ] ] ] [ [ f not ] infer ] unit-test
! [ [ [ ] [ POSTPONE: f ] ] ] [ [ t not ] infer ] unit-test
! [ [ [ ] [ POSTPONE: f ] ] ] [ [ 5 not ] infer ] unit-test
! 
! [ [ [ object ] [ general-t ] ] ] [ [ dup [ not ] unless ] infer ] unit-test

TUPLE: funny-cons car cdr ;
GENERIC: iterate
M: funny-cons iterate funny-cons-cdr iterate ;
M: f iterate drop ;
M: real iterate drop ;

[ [[ 1 0 ]] ] [ [ iterate ] infer old-effect ] unit-test
