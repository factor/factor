! Copyright (c) 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math.combinatorics math.parser project-euler.common ;
IN: project-euler.024

! http://projecteuler.net/index.php?section=problems&id=24

! DESCRIPTION
! -----------

! A permutation is an ordered arrangement of objects. For example, 3124 is one
! possible permutation of the digits 1, 2, 3 and 4. If all of the permutations
! are listed numerically or alphabetically, we call it lexicographic order. The
! lexicographic permutations of 0, 1 and 2 are:

!     012   021   102   120   201   210

! What is the millionth lexicographic permutation of the digits 0, 1, 2, 3, 4,
! 5, 6, 7, 8 and 9?


! SOLUTION
! --------

: euler024 ( -- answer )
    999999 10 permutation 10 digits>integer ;

! [ euler024 ] 100 ave-time
! 0 ms ave run time - 0.27 SD (100 trials)

SOLUTION: euler024
