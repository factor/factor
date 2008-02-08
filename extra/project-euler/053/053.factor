! Copyright (c) 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.lib kernel math math.combinatorics math.ranges sequences ;
IN: project-euler.053

! http://projecteuler.net/index.php?section=problems&id=53

! DESCRIPTION
! -----------

! There are exactly ten ways of selecting three from five, 12345:

!     123, 124, 125, 134, 135, 145, 234, 235, 245, and 345

! In combinatorics, we use the notation, 5C3 = 10.

! In general,
!     nCr = n! / r! * (n - r)!
! where r ≤ n, n! = n * (n − 1) * ... * 3 * 2 * 1, and 0! = 1.

! It is not until n = 23, that a value exceeds one-million: 23C10 = 1144066.

! How many values of nCr, for 1 ≤ n ≤ 100, are greater than one-million?


! SOLUTION
! --------

: euler053 ( -- answer )
    23 100 [a,b] [ dup [ nCk ] with map [ 1000000 > ] count ] sigma ;

! [ euler053 ] 100 ave-time
! 64 ms run / 2 ms GC ave time - 100 trials

MAIN: euler053
