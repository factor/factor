! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions math.primes
project-euler.common sequences ;
IN: project-euler.026

! https://projecteuler.net/problem=26

! DESCRIPTION
! -----------

! A unit fraction contains 1 in the numerator. The decimal
! representation of the unit fractions with denominators 2 to 10
! are given:

!     1/2  =  0.5
!     1/3  =  0.(3)
!     1/4  =  0.25
!     1/5  =  0.2
!     1/6  =  0.1(6)
!     1/7  =  0.(142857)
!     1/8  =  0.125
!     1/9  =  0.(1)
!     1/10 =  0.1

! Where 0.1(6) means 0.166666..., and has a 1-digit recurring
! cycle. It can be seen that 1/7 has a 6-digit recurring cycle.

! Find the value of d < 1000 for which 1/d contains the longest
! recurring cycle in its decimal fraction part.


! SOLUTION
! --------

<PRIVATE

: source-026 ( -- seq )
    999 primes-upto [ recip ] map ;

: (mult-order) ( n a m -- k )
    3dup ^ swap mod 1 = [ 2nip ] [ 1 + (mult-order) ] if ;

PRIVATE>

: recurring-period? ( a/b -- ? )
    denominator 10 coprime? ;

! Multiplicative order a.k.a. modulo order
: mult-order ( a n -- k )
    swap 1 (mult-order) ;

: period-length ( a/b -- n )
    dup recurring-period?
    [ denominator 10 swap mult-order ] [ drop 0 ] if ;

<PRIVATE

: max-period ( seq -- elt n )
    dup [ period-length ] map dup supremum
    over index [ swap nth ] curry bi@ ;

PRIVATE>

: euler026 ( -- answer )
    source-026 max-period drop denominator ;

! [ euler026 ] 100 ave-time
! 290 ms ave run time - 19.2 SD (100 trials)

SOLUTION: euler026
