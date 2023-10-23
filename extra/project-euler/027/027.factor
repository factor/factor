! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.primes project-euler.common sequences ;
IN: project-euler.027

! https://projecteuler.net/problem=27

! DESCRIPTION
! -----------

! Euler published the remarkable quadratic formula:

!     n² + n + 41

! It turns out that the formula will produce 40 primes for the
! consecutive values n = 0 to 39. However, when n = 40, 402 + 40
! + 41 = 40(40 + 1) + 41 is divisible by 41, and certainly when
! n = 41, 41² + 41 + 41 is clearly divisible by 41.

! Using computers, the incredible formula n² - 79n + 1601 was
! discovered, which produces 80 primes for the consecutive
! values n = 0 to 79. The product of the coefficients, -79 and
! 1601, is -126479.

! Considering quadratics of the form:

!     n² + an + b, where |a| < 1000 and |b| < 1000

!     where |n| is the modulus/absolute value of n
!     e.g. |11| = 11 and |-4| = 4

! Find the product of the coefficients, a and b, for the
! quadratic expression that produces the maximum number of
! primes for consecutive values of n, starting with n = 0.


! SOLUTION
! --------

! b must be prime since n = 0 must return a prime
! a + b + 1 must be prime since n = 1 must return a prime
! 1 - a + b must be prime as well, hence >= 2. Therefore:
!    1 - a + b >= 2
!        b - a >= 1
!            a < b

<PRIVATE

: source-027 ( -- seq )
    1000 <iota> [ prime? ] filter [ dup [ neg ] map append ] keep
    cartesian-product concat [ first2 < ] filter ;

: quadratic ( b a n -- m )
    dup sq -rot * + + ;

: (consecutive-primes) ( b a n -- m )
    3dup quadratic prime? [ 1 + (consecutive-primes) ] [ 2nip ] if ;

: consecutive-primes ( a b -- m )
    swap 0 (consecutive-primes) ;

: max-consecutive ( seq -- elt n )
    dup [ first2 consecutive-primes ] map dup maximum
    over index [ swap nth ] curry bi@ ;

PRIVATE>

: euler027 ( -- answer )
    source-027 max-consecutive drop product ;

! [ euler027 ] 100 ave-time
! 111 ms ave run time - 6.07 SD (100 trials)

! TODO: generalize max-consecutive/max-product (from #26) into a new word

SOLUTION: euler027
