! Copyright (c) 2008 Eric Mertens.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math ranges sequences project-euler.common ;
IN: project-euler.116

! https://projecteuler.net/index.php?section=problems&id=116

! DESCRIPTION
! -----------

! A row of five black square tiles is to have a number of its tiles replaced
! with colored oblong tiles chosen from red (length two), green (length
! three), or blue (length four).

! If red tiles are chosen there are exactly seven ways this can be done.
! If green tiles are chosen there are three ways.
! And if blue tiles are chosen there are two ways.

! Assuming that colors cannot be mixed there are 7 + 3 + 2 = 12 ways of
! replacing the black tiles in a row measuring five units in length.

! How many different ways can the black tiles in a row measuring fifty units in
! length be replaced if colors cannot be mixed and at least one colored tile
! must be used?


! SOLUTION
! --------

! This solution uses a simple dynamic programming approach using the
! following recurence relation

! ways(n,_) = 0   | n < 0
! ways(0,_) = 1
! ways(n,i) = ways(n-i,i) + ways(n-1,i)
! solution(n) = ways(n,1) - 1 + ways(n,2) - 1 + ways(n,3) - 1

<PRIVATE

: nth* ( n seq -- elt/0 )
    [ length swap - 1 - ] keep ?nth 0 or ;

: next ( colortile seq -- )
    [ nth* ] [ last + ] [ push ] tri ;

: ways ( length colortile -- permutations )
    V{ 1 } clone [ [ next ] 2curry times ] keep last 1 - ;

: (euler116) ( length -- permutations )
    3 [1..b] [ ways ] with map-sum ;

PRIVATE>

: euler116 ( -- answer )
    50 (euler116) ;

! [ euler116 ] 100 ave-time
! 0 ms ave run time - 0.34 SD (100 trials)

SOLUTION: euler116
