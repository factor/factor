! Copyright (c) 2008 Eric Mertens.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.order ranges math.statistics
project-euler.common sequences sequences.private ;
IN: project-euler.150

! https://projecteuler.net/problem=150

! DESCRIPTION
! -----------

! In a triangular array of positive and negative integers, we
! wish to find a sub-triangle such that the sum of the numbers
! it contains is the smallest possible.

! In the example below, it can be easily verified that the
! marked triangle satisfies this condition having a sum of -42.

! We wish to make such a triangular array with one thousand
! rows, so we generate 500500 pseudo-random numbers sk in the
! range +/-2^19, using a type of random number generator (known
! as a Linear Congruential Generator) as follows:

! ...

! Find the smallest possible sub-triangle sum.


! SOLUTION
! --------

<PRIVATE

! sequence helper functions

: partial-sums ( seq -- sums )
    cum-sum 0 prefix ; inline

: partial-sum-minimum ( seq quot -- seq )
    [ 0 0 ] 2dip [ + [ min ] keep ] compose each drop ; inline

: map-minimum ( seq quot -- min )
    [ min ] compose 0 swap reduce ; inline

! triangle generator functions

: next ( t -- new-t s )
    615949 * 797807 + 20 2^ rem dup 19 2^ - ; inline

: sums-triangle ( -- seq )
    0 1000 [1..b] [ [ next ] replicate partial-sums ] map nip ; inline

:: (euler150) ( m -- n )
    sums-triangle :> table
    m <iota> [| x |
        x 1 + <iota> [| y |
            m x - <iota> [| z |
                x z + table nth-unsafe
                [ y z + 1 + swap nth-unsafe ]
                [ y         swap nth-unsafe ] bi -
            ] partial-sum-minimum
        ] map-minimum
    ] map-minimum ; inline

PRIVATE>

: euler150 ( -- answer )
    1000 (euler150) ;

! [ euler150 ] 10 ave-time
! 30208 ms ave run time - 593.45 SD (10 trials)

SOLUTION: euler150
