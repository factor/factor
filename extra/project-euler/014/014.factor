! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit kernel make math math.ranges sequences ;
IN: project-euler.014

! http://projecteuler.net/index.php?section=problems&id=14

! DESCRIPTION
! -----------

! The following iterative sequence is defined for the set of positive integers:

!     n -> n / 2  (n is even)
!     n -> 3n + 1 (n is odd)

! Using the rule above and starting with 13, we generate the following
! sequence:

!     13 -> 40 -> 20 -> 10 -> 5 -> 16 -> 8 -> 4 -> 2 -> 1

! It can be seen that this sequence (starting at 13 and finishing at 1)
! contains 10 terms. Although it has not been proved yet (Collatz Problem), it
! is thought that all starting numbers finish at 1.

! Which starting number, under one million, produces the longest chain?

! NOTE: Once the chain starts the terms are allowed to go above one million.


! SOLUTION
! --------

! Brute force

<PRIVATE

: next-collatz ( n -- n )
    dup even? [ 2 / ] [ 3 * 1+ ] if ;

: longest ( seq seq -- seq )
    2dup [ length ] bi@ > [ drop ] [ nip ] if ;

PRIVATE>

: collatz ( n -- seq )
    [ [ dup 1 > ] [ dup , next-collatz ] while , ] { } make ;

: euler014 ( -- answer )
    1000000 [1,b] 0 [ collatz longest ] reduce first ;

! [ euler014 ] time
! 52868 ms run / 483 ms GC time


! ALTERNATE SOLUTIONS
! -------------------

<PRIVATE

: worth-calculating? ( n -- ? )
    1- 3 { [ mod 0 = ] [ / even? ] } 2&& ;

PRIVATE>

: euler014a ( -- answer )
    500000 1000000 [a,b] 1 [
        dup worth-calculating? [ collatz longest ] [ drop ] if
    ] reduce first ;

! [ euler014a ] 10 ave-time
! 4821 ms run / 41 ms GC time

! TODO: try using memoization

MAIN: euler014a
