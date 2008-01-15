! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions math.ranges sequences ;
IN: project-euler.006

! http://projecteuler.net/index.php?section=problems&id=6

! DESCRIPTION
! -----------

! The sum of the squares of the first ten natural numbers is,
!     1² + 2² + ... + 10² = 385

! The square of the sum of the first ten natural numbers is,
!    (1 + 2 + ... + 10)² = 55² = 3025

! Hence the difference between the sum of the squares of the first ten natural
! numbers and the square of the sum is 3025 385 = 2640.

! Find the difference between the sum of the squares of the first one hundred
! natural numbers and the square of the sum.


! SOLUTION
! --------

<PRIVATE

: sum-of-squares ( seq -- n )
    0 [ sq + ] reduce ;

: square-of-sum ( seq -- n )
    sum sq ;

PRIVATE>

: euler006 ( -- answer )
    1 100 [a,b] dup sum-of-squares swap square-of-sum - abs ;

! [ euler006 ] 100 ave-time
! 0 ms run / 0 ms GC ave time - 100 trials

MAIN: euler006
