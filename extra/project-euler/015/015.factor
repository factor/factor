! Copyright (c) 2007 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.combinatorics project-euler.common ;
IN: project-euler.015

! https://projecteuler.net/problem=15

! DESCRIPTION
! -----------

! Starting in the top left corner of a 2x2 grid, there are 6
! routes (without backtracking) to the bottom right corner.

! How many routes are there through a 20x20 grid?


! SOLUTION
! --------

<PRIVATE

: grid-paths ( n -- n )
    dup 2 * swap nCk ;

PRIVATE>

: euler015 ( -- answer )
    20 grid-paths ;

! [ euler015 ] 100 ave-time
! 0 ms ave run time - 0.2 SD (100 trials)

SOLUTION: euler015
