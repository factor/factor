! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math ranges project-euler.common
sequences sets ;
IN: project-euler.023

! https://projecteuler.net/index.php?section=problems&id=23

! DESCRIPTION
! -----------

! A perfect number is a number for which the sum of its proper divisors is
! exactly equal to the number. For example, the sum of the proper divisors of
! 28 would be 1 + 2 + 4 + 7 + 14 = 28, which means that 28 is a perfect number.

! A number whose proper divisors are less than the number is called deficient
! and a number whose proper divisors exceed the number is called abundant.

! As 12 is the smallest abundant number, 1 + 2 + 3 + 4 + 6 = 16, the smallest
! number that can be written as the sum of two abundant numbers is 24. By
! mathematical analysis, it can be shown that all integers greater than 28123
! can be written as the sum of two abundant numbers. However, this upper limit
! cannot be reduced any further by analysis even though it is known that the
! greatest number that cannot be expressed as the sum of two abundant numbers
! is less than this limit.

! Find the sum of all the positive integers which cannot be written as the sum
! of two abundant numbers.


! SOLUTION
! --------

! The upper limit can be dropped to 20161 which reduces our search space
! and every even number > 46 can be expressed as a sum of two abundants

<PRIVATE

: source-023 ( -- seq )
    46 [1..b] 47 20161 2 <range> append ;

: abundants-upto ( n -- seq )
    [1..b] [ abundant? ] filter ;

: possible-sums ( seq -- seq )
    HS{ } clone
    [ dupd '[ _ [ + _ adjoin ] with each ] each ]
    keep members ;

PRIVATE>

: euler023 ( -- answer )
    source-023
    20161 abundants-upto possible-sums diff sum ;

! [ euler023 ] time
! 2.15542 seconds

SOLUTION: euler023
