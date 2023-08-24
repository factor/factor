! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions math.primes ranges
sequences project-euler.common ;
IN: project-euler.046

! https://projecteuler.net/index.php?section=problems&id=46

! DESCRIPTION
! -----------

! It was proposed by Christian Goldbach that every odd composite number can be
! written as the sum of a prime and twice a square.

!     9  =  7 + 2 * 1^2
!     15 =  7 + 2 * 2^2
!     21 =  3 + 2 * 3^2
!     25 =  7 + 2 * 3^2
!     27 = 19 + 2 * 2^2
!     33 = 31 + 2 * 1^2

! It turns out that the conjecture was false.

! What is the smallest odd composite that cannot be written as the sum of a
! prime and twice a square?


! SOLUTION
! --------

<PRIVATE

: perfect-squares ( n -- seq )
    2 /i sqrt >integer [1..b] [ sq ] map ;

: fits-conjecture? ( n -- ? )
    dup perfect-squares [ 2 * - ] with map [ prime? ] any? ;

: next-odd-composite ( n -- m )
    dup odd? [ 2 + ] [ 1 + ] if dup prime? [ next-odd-composite ] when ;

: disprove-conjecture ( n -- m )
    dup fits-conjecture? [ next-odd-composite disprove-conjecture ] when ;

PRIVATE>

: euler046 ( -- answer )
    9 disprove-conjecture ;

! [ euler046 ] 100 ave-time
! 37 ms ave run time - 3.39 SD (100 trials)

SOLUTION: euler046
