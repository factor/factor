! Copyright (c) 2008 Eric Mertens.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math project-euler.common sequences ;
IN: project-euler.117

! https://projecteuler.net/index.php?section=problems&id=117

! DESCRIPTION
! -----------

! Using a combination of black square tiles and oblong tiles chosen
! from: red tiles measuring two units, green tiles measuring three
! units, and blue tiles measuring four units, it is possible to tile a
! row measuring five units in length in exactly fifteen different ways.

! How many ways can a row measuring fifty units in length be tiled?


! SOLUTION
! --------

! This solution uses a simple dynamic programming approach using the
! following recurence relation

! ways(i) = 1 | i <= 0
! ways(i) = ways(i-4) + ways(i-3) + ways(i-2) + ways(i-1)

<PRIVATE

: next ( seq -- )
    [ 4 index-or-length tail* sum ] keep push ;

: (euler117) ( n -- m )
    [ V{ 1 } clone ] dip over [ next ] curry times last ;

PRIVATE>

: euler117 ( -- answer )
    50 (euler117) ;

! [ euler117 ] 100 ave-time
! 0 ms ave run time - 0.29 SD (100 trials)

SOLUTION: euler117
