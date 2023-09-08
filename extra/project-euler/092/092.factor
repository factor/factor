! Copyright (c) 2008 Aaron Schaefer, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math ranges project-euler.common sequences ;
IN: project-euler.092

! https://projecteuler.net/problem=92

! DESCRIPTION
! -----------

! A number chain is created by continuously adding the square of
! the digits in a number to form a new number until it has been
! seen before.

! For example,

!     44 -> 32 -> 13 -> 10 -> 1 -> 1
!     85 -> 89 -> 145 -> 42 -> 20 -> 4 -> 16 -> 37 -> 58 -> 89

! Therefore any chain that arrives at 1 or 89 will become stuck
! in an endless loop. What is most amazing is that EVERY
! starting number will eventually arrive at 1 or 89.

! How many starting numbers below ten million will arrive at 89?


! SOLUTION
! --------

<PRIVATE

: next-link ( n -- m )
    number>digits [ sq ] map-sum ;

: chain-ending ( n -- m )
    dup [ 1 = ] [ 89 = ] bi or [ next-link chain-ending ] unless ;

: lower-endings ( -- seq )
    567 [1..b] [ chain-ending ] map ;

: fast-chain-ending ( seq n -- m )
    dup 567 > [ next-link ] when 1 - swap nth ;

PRIVATE>

: euler092 ( -- answer )
    lower-endings 9999999 [1..b] [ fast-chain-ending 89 = ] with count ;

! [ euler092 ] 10 ave-time
! 33257 ms ave run time - 624.27 SD (10 trials)

! TODO: this solution is not very efficient, much better optimizations exist

SOLUTION: euler092
