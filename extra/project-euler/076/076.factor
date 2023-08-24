! Copyright (c) 2008 Eric Mertens.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs kernel math math.order ranges sequences project-euler.common ;
IN: project-euler.076

! https://projecteuler.net/index.php?section=problems&id=76

! DESCRIPTION
! -----------

! How many different ways can one hundred be written as a
! sum of at least two positive integers?


! SOLUTION
! --------

! This solution uses dynamic programming and the following
! recurence relation:

! ways(0,_) = 1
! ways(_,0) = 0
! ways(n,i) = ways(n-i,i) + ways(n,i-1)

<PRIVATE

: init ( n -- table )
    [1..b] [ 0 2array 0 ] H{ } map>assoc
    1 { 0 0 } pick set-at ;

: use ( n i -- n i )
    [ - dup ] keep min ; inline

: ways ( n i table -- )
    over zero? [
        3drop
    ] [
        [ [ 1 -  2array ] dip at     ]
        [ [ use 2array ] dip at +   ]
        [ [     2array ] dip set-at ] 3tri
    ] if ;

:: each-subproblem ( n quot -- )
    n [1..b] [ dup [1..b] quot with each ] each ; inline

: (euler076) ( n -- m )
    dup init
    [ [ ways ] curry each-subproblem ]
    [ [ dup 2array ] dip at 1 - ] 2bi ;

PRIVATE>

: euler076 ( -- answer )
    100 (euler076) ;

! [ euler076 ] 100 ave-time
! 560 ms ave run time - 17.74 SD (100 trials)

SOLUTION: euler076
