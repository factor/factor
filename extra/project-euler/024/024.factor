! Copyright (c) 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.parser math.ranges namespaces sequences ;
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

<PRIVATE

: (>permutation) ( seq n -- seq )
    [ [ dupd >= [ 1+ ] when ] curry map ] keep add* ;

PRIVATE>

: >permutation ( factoradic -- permutation )
    reverse 1 cut [ (>permutation) ] each ;

: factoradic ( k order -- factoradic )
    [ [1,b] [ 2dup mod , /i ] each ] { } make reverse nip ;

: permutation ( k seq -- seq )
    dup length swapd factoradic >permutation
    [ [ dupd swap nth , ] each drop ] { } make ;

: euler024 ( -- answer )
    999999 10 permutation 10 swap digits>integer ;

! [ euler024 ] 100 ave-time
! 0 ms run / 0 ms GC ave time - 100 trials

MAIN: euler024
