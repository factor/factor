! Copyright (c) 2007 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit kernel project-euler.common
ranges sequences ;
IN: project-euler.021

! https://projecteuler.net/index.php?section=problems&id=21

! DESCRIPTION
! -----------

! Let d(n) be defined as the sum of proper divisors of n (numbers less than n
! which divide evenly into n).

! If d(a) = b and d(b) = a, where a != b, then a and b are an amicable pair and
! each of a and b are called amicable numbers.

! For example, the proper divisors of 220 are 1, 2, 4, 5, 10, 11, 20, 22, 44,
! 55 and 110; therefore d(220) = 284. The proper divisors of 284 are 1, 2, 4,
! 71 and 142; so d(284) = 220.

! Evaluate the sum of all the amicable numbers under 10000.


! SOLUTION
! --------

: amicable? ( n -- ? )
    dup sum-proper-divisors
    { [ = not ] [ sum-proper-divisors = ] } 2&& ;

: euler021 ( -- answer )
    10,000 [1..b] [ dup amicable? [ drop 0 ] unless ] map-sum ;

! [ euler021 ] 100 ave-time
! 335 ms ave run time - 18.63 SD (100 trials)

SOLUTION: euler021
