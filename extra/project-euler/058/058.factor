! Copyright (c) 2009 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.primes project-euler.common ranges
sequences ;
IN: project-euler.058

! https://projecteuler.net/index.php?section=problems&id=58

! DESCRIPTION
! -----------

! Starting with 1 and solveling anticlockwise in the following way, a square
! solve with side length 7 is formed.

!     37 36 35 34 33 32 31
!     38 17 16 15 14 13 30
!     39 18  5  4  3 12 29
!     40 19  6  1  2 11 28
!     41 20  7  8  9 10 27
!     42 21 22 23 24 25 26
!     43 44 45 46 47 48 49

! It is interesting to note that the odd squares lie along the bottom right
! diagonal, but what is more interesting is that 8 out of the 13 numbers lying
! along both diagonals are prime; that is, a ratio of 8/13 ≈ 62%.

! If one complete new layer is wrapped around the solve above, a square solve
! with side length 9 will be formed. If this process is continued, what is the
! side length of the square solve for which the ratio of primes along both
! diagonals first falls below 10%?


! SOLUTION
! --------

<PRIVATE

CONSTANT: PERCENT_PRIME 0.1

! The corners of a square of side length n are:
!    (n-2)² + 1(n-1)
!    (n-2)² + 2(n-1)
!    (n-2)² + 3(n-1)
!    (n-2)² + 4(n-1) = odd squares, no need to calculate

: prime-corners ( n -- m )
    3 [1..b] swap '[ _ [ 1 - * ] keep 2 - sq + prime? ] count ;

: total-corners ( n -- m )
    1 - 2 * ; foldable

: ratio-below? ( count length -- ? )
    total-corners 1 + / PERCENT_PRIME < ;

: next-layer ( count length -- count' length' )
    2 + [ prime-corners + ] keep ;

: solve ( count length -- length )
    2dup ratio-below? [ nip ] [ next-layer solve ] if ;

PRIVATE>

: euler058 ( -- answer )
    8 7 solve ;

! [ euler058 ] 10 ave-time
! 12974 ms ave run time - 284.46 SD (10 trials)

SOLUTION: euler058
