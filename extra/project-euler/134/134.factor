! Copyright (c) 2007 Samuel Tardieu.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel lists lists.lazy math math.algebra
math.functions math.primes.lists project-euler.common ;
IN: project-euler.134

! https://projecteuler.net/index.php?section=problems&id=134

! DESCRIPTION
! -----------

! Consider the consecutive primes p1 = 19 and p2 = 23. It can be verified that
! 1219 is the smallest number such that the last digits are formed by p1 whilst
! also being divisible by p2.

! In fact, with the exception of p1 = 3 and p2 = 5, for every pair of
! consecutive primes, p2 p1, there exist values of n for which the last digits
! are formed by p1 and n is divisible by p2. Let S be the smallest of these
! values of n.

! Find S for every pair of consecutive primes with 5 p1 1000000.


! SOLUTION
! --------

! Compute the smallest power of 10 greater than or equal to m
: next-power-of-10 ( m -- n )
    10 swap log10 ceiling >integer ^ ; foldable

<PRIVATE

! Compute S for a given pair (p1, p2) -- that is the smallest positive
! number such that X = p1 [npt] and X = 0 [p2] (npt being the smallest
! power of 10 above p1)
: s ( p1 p2 -- s )
    over 0 2array rot next-power-of-10 rot 2array chinese-remainder ;

PRIVATE>

: euler134 ( -- answer )
    0 5 lprimes-from uncons [ 1000000 > ] luntil
    [ [ s + ] keep ] leach drop ;

! [ euler134 ] 10 ave-time
! 933 ms ave run timen - 19.58 SD (10 trials)

SOLUTION: euler134
