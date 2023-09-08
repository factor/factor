! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math project-euler.common ;
IN: project-euler.073

! https://projecteuler.net/problem=73

! DESCRIPTION
! -----------

! Consider the fraction, n/d, where n and d are positive
! integers. If n<d and HCF(n,d) = 1, it is called a reduced
! proper fraction.

! If we list the set of reduced proper fractions for d <= 8 in
! ascending order of size, we get:

!     1/8, 1/7, 1/6, 1/5, 1/4, 2/7, 1/3, 3/8, 2/5, 3/7, 1/2,
!     4/7, 3/5, 5/8, 2/3, 5/7, 3/4, 4/5, 5/6, 6/7, 7/8

! It can be seen that there are 3 fractions between 1/3 and 1/2.

! How many fractions lie between 1/3 and 1/2 in the sorted set
! of reduced proper fractions for d <= 10,000?


! SOLUTION
! --------

! Use the properties of a Farey sequence and mediants to
! recursively generate the next fraction until the denominator
! is as close to 1000000 as possible without going over.

<PRIVATE

:: (euler073) ( counter limit lo hi -- counter' )
    lo hi mediant :> m
    m denominator limit <= [
        counter 1 +
        limit lo m (euler073)
        limit m hi (euler073)
    ] [ counter ] if ;

PRIVATE>

: euler073 ( -- answer )
    0 10000 1/3 1/2 (euler073) ;

! [ euler073 ] 10 ave-time
! 20506 ms ave run time - 937.07 SD (10 trials)

SOLUTION: euler073
