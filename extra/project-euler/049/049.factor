! Copyright (c) 2009 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel math math.primes project-euler.common
sequences sets ;
FROM: project-euler.common => permutations? ;
IN: project-euler.049

! https://projecteuler.net/index.php?section=problems&id=49

! DESCRIPTION
! -----------

! The arithmetic sequence, 1487, 4817, 8147, in which each of the terms
! increases by 3330, is unusual in two ways: (i) each of the three terms are
! prime, and, (ii) each of the 4-digit numbers are permutations of one another.

! There are no arithmetic sequences made up of three 1-, 2-, or 3-digit primes,
! exhibiting this property, but there is one other 4-digit increasing sequence.

! What 12-digit number do you form by concatenating the three terms in this
! sequence?


! SOLUTION
! --------

<PRIVATE

: collect-permutations ( seq -- seq )
    [ V{ } clone ] [ dup ] bi* [
        dupd '[ _ permutations? ] filter
        [ diff ] keep pick push
    ] each drop ;

: potential-sequences ( -- seq )
    1000 9999 primes-between
    collect-permutations [ length 3 >= ] filter ;

: arithmetic-terms ( m n -- seq )
    2dup [ swap - ] keep + 3array ;

: (find-unusual-terms) ( n seq -- seq/f )
    [ [ arithmetic-terms ] with map ] keep
    '[ _ [ last ] dip member? ] find nip ;

: find-unusual-terms ( seq -- seq/? )
    unclip-slice over (find-unusual-terms) [
        nip
    ] [
        dup length 3 >= [ find-unusual-terms ] [ drop f ] if
    ] if* ;

: 4digit-concat ( seq -- str )
    0 [ [ 10000 * ] dip + ] reduce ;

PRIVATE>

: euler049 ( -- answer )
    potential-sequences [ find-unusual-terms ] map sift
    [ { 1487 4817 8147 } = not ] find nip 4digit-concat ;

! [ euler049 ] 100 ave-time
! 206 ms ave run time - 10.25 SD (100 trials)

SOLUTION: euler049
