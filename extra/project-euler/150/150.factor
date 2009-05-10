! Copyright (c) 2008 Eric Mertens.
! See http://factorcode.org/license.txt for BSD license.
USING: hints kernel locals math math.order math.ranges project-euler.common
    sequences sequences.private ;
IN: project-euler.150

! http://projecteuler.net/index.php?section=problems&id=150

! DESCRIPTION
! -----------

! In a triangular array of positive and negative integers, we wish to find a
! sub-triangle such that the sum of the numbers it contains is the smallest
! possible.

! In the example below, it can be easily verified that the marked triangle
! satisfies this condition having a sum of -42.

! We wish to make such a triangular array with one thousand rows, so we
! generate 500500 pseudo-random numbers sk in the range +/-2^19, using a type of
! random number generator (known as a Linear Congruential Generator) as
! follows:

! ...

! Find the smallest possible sub-triangle sum.


! SOLUTION
! --------

<PRIVATE

! sequence helper functions

: partial-sums ( seq -- sums )
    0 [ + ] accumulate swap suffix ; inline

: (partial-sum-infimum) ( inf sum elt -- inf sum )
    + [ min ] keep ; inline

: partial-sum-infimum ( seq -- seq )
    0 0 rot [ (partial-sum-infimum) ] each drop ; inline

: map-infimum ( seq quot -- min )
    [ min ] compose 0 swap reduce ; inline

! triangle generator functions

: next ( t -- new-t s )
    615949 * 797807 + 20 2^ rem dup 19 2^ - ; inline

: sums-triangle ( -- seq )
    0 1000 [1,b] [ [ next ] replicate partial-sums ] map nip ;

:: (euler150) ( m -- n )
    [let | table [ sums-triangle ] |
        m [| x |
            x 1+ [| y |
                m x - [0,b) [| z |
                    x z + table nth-unsafe
                    [ y z + 1+ swap nth-unsafe ]
                    [ y        swap nth-unsafe ] bi -
                ] map partial-sum-infimum
            ] map-infimum
        ] map-infimum
    ] ;

HINTS: (euler150) fixnum ;

PRIVATE>

: euler150 ( -- answer )
    1000 (euler150) ;

! [ euler150 ] 10 ave-time
! 30208 ms ave run time - 593.45 SD (10 trials)

SOLUTION: euler150
