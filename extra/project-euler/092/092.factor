! Copyright (c) 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.lib kernel math math.ranges namespaces project-euler.common
    sequences ;
IN: project-euler.092

! http://projecteuler.net/index.php?section=problems&id=92

! DESCRIPTION
! -----------

! A number chain is created by continuously adding the square of the digits in
! a number to form a new number until it has been seen before.

! For example,

!     44 -> 32 -> 13 -> 10 -> 1 -> 1
!     85 -> 89 -> 145 -> 42 -> 20 -> 4 -> 16 -> 37 -> 58 -> 89

! Therefore any chain that arrives at 1 or 89 will become stuck in an endless
! loop. What is most amazing is that EVERY starting number will eventually
! arrive at 1 or 89.

! How many starting numbers below ten million will arrive at 89?


! SOLUTION
! --------

<PRIVATE

: next-link ( n -- m )
    number>digits [ sq ] sigma ;

: chain-ending ( n -- m )
    dup 1 = over 89 = or [ next-link chain-ending ] unless ;

: lower-endings ( -- seq )
    567 [1,b] [ chain-ending ] map ;

: fast-chain-ending ( seq n -- m )
    dup 567 > [ next-link ] when 1- swap nth ;

PRIVATE>

: euler092 ( -- answer )
    lower-endings 9999999 [1,b] [ fast-chain-ending 89 = ] with count ;

! [ euler092 ] time
! 68766 ms run / 372 ms GC time

! TODO: solution is still too slow, maybe try using a 10000000-byte array that
! keeps track of each number in the chain and their endings

MAIN: euler092
