! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math.functions ranges project-euler.common
sequences math.order ;
IN: project-euler.056

! https://projecteuler.net/problem=56

! DESCRIPTION
! -----------

! A googol (10^100) is a massive number: one followed by
! one-hundred zeros; 100^100 is almost unimaginably large: one
! followed by two-hundred zeros. Despite their size, the sum of
! the digits in each number is only 1.

! Considering natural numbers of the form, a^b, where a, b <
! 100, what is the maximum digital sum?


! SOLUTION
! --------

! Through analysis, you only need to check when a and b > 90

: euler056 ( -- answer )
    90 100 [a..b) dup cartesian-product concat
    [ first2 ^ number>digits sum ] [ max ] map-reduce ;

! [ euler056 ] 100 ave-time
! 22 ms ave run time - 2.13 SD (100 trials)

SOLUTION: euler056
