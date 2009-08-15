! Copyright (c) 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.combinatorics math.parser math.primes
    project-euler.common sequences sets ;
IN: project-euler.035

! http://projecteuler.net/index.php?section=problems&id=35

! DESCRIPTION
! -----------

! The number, 197, is called a circular prime because all rotations of the
! digits: 197, 971, and 719, are themselves prime.

! There are thirteen such primes below 100:
!     2, 3, 5, 7, 11, 13, 17, 31, 37, 71, 73, 79, and 97.

! How many circular primes are there below one million?


! SOLUTION
! --------

<PRIVATE

: source-035 ( -- seq )
    1000000 primes-upto [ number>digits ] map ;

: possible? ( seq -- ? )
    dup length 1 > [
        dup { 0 2 4 5 6 8 } diff =
    ] [
        drop t
    ] if ;

: rotate ( seq n -- seq )
    cut* prepend ;

: (circular?) ( seq n -- ? )
    dup 0 > [
        2dup rotate 10 digits>integer
        prime? [ 1 - (circular?) ] [ 2drop f ] if
    ] [
        2drop t
    ] if ;

: circular? ( seq -- ? )
    dup length 1 - (circular?) ;

PRIVATE>

: euler035 ( -- answer )
    source-035 [ possible? ] filter [ circular? ] count ;

! [ euler035 ] 100 ave-time
! 538 ms ave run time - 17.16 SD (100 trials)

! TODO: try using bit arrays or other methods outlined here:
!     http://home.comcast.net/~babdulbaki/Circular_Primes.html

SOLUTION: euler035
