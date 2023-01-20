! Copyright (c) 2009 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions ranges project-euler.common sequences ;
IN: project-euler.063

! https://projecteuler.net/index.php?section=problems&id=63

! DESCRIPTION
! -----------

! The 5-digit number, 16807 = 7^5, is also a fifth power. Similarly, the
! 9-digit number, 134217728 = 8^9, is a ninth power.

! How many n-digit positive integers exist which are also an nth power?


! SOLUTION
! --------

! Only have to check from 1 to 9 because 10^n already has too many digits.
! In general, x^n has n digits when:

!     10^(n-1) <= x^n < 10^n

! ...take the left side of that equation, solve for n to see where they meet:

!     n = log(10) / [ log(10) - log(x) ]

! Round down since we already know that particular value of n is no good.

: euler063 ( -- answer )
    9 [1..b] [ log [ 10 log dup ] dip - /i ] map-sum ;

! [ euler063 ] 100 ave-time
! 0 ms ave run time - 0.0 SD (100 trials)

SOLUTION: euler063
