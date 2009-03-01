! Copyright (c) 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math project-euler.common sequences ;
IN: project-euler.071

! http://projecteuler.net/index.php?section=problems&id=71

! DESCRIPTION
! -----------

! Consider the fraction, n/d, where n and d are positive integers. If n<d and
! HCF(n,d) = 1, it is called a reduced proper fraction.

! If we list the set of reduced proper fractions for d <= 8 in ascending order of
! size, we get:

!     1/8, 1/7, 1/6, 1/5, 1/4, 2/7, 1/3, 3/8, 2/5, 3/7, 1/2, 4/7, 3/5, 5/8,
!     2/3, 5/7, 3/4, 4/5, 5/6, 6/7, 7/8

! It can be seen that 2/5 is the fraction immediately to the left of 3/7.

! By listing the set of reduced proper fractions for d <= 1,000,000 in
! ascending order of size, find the numerator of the fraction immediately to the
! left of 3/7.


! SOLUTION
! --------

! Use the properties of a Farey sequence by setting an upper bound of 3/7 and
! then taking the mediant of that fraction and the one to its immediate left
! repeatedly until the denominator is as close to 1000000 as possible without
! going over.

<PRIVATE

: penultimate ( seq -- elt )
    dup length 2 - swap nth ;

PRIVATE>

: euler071 ( -- answer )
    2/5 [ dup denominator 1000000 <= ] [ 3/7 mediant dup ] produce
    nip penultimate numerator ;

! [ euler071 ] 100 ave-time
! 155 ms ave run time - 6.95 SD (100 trials)

MAIN: euler071
