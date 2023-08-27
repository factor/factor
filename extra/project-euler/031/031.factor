! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math project-euler.common ;
IN: project-euler.031

! https://projecteuler.net/index.php?section=problems&id=31

! DESCRIPTION
! -----------

! In England the currency is made up of pound, £, and pence, p, and there are
! eight coins in general circulation:

!     1p, 2p, 5p, 10p, 20p, 50p, £1 (100p) and £2 (200p).

! It is possible to make £2 in the following way:

!     1×£1 + 1×50p + 2×20p + 1×5p + 1×2p + 3×1p

! How many different ways can £2 be made using any number of coins?



! SOLUTION
! --------

<PRIVATE

: 1p ( m -- n )
    drop 1 ;

: 2p ( m -- n )
    dup 0 >= [ [ 2 - 2p ] [ 1p ] bi + ] [ drop 0 ] if ;

: 5p ( m -- n )
    dup 0 >= [ [ 5 - 5p ] [ 2p ] bi + ] [ drop 0 ] if ;

: 10p ( m -- n )
    dup 0 >= [ [ 10 - 10p ] [ 5p ] bi + ] [ drop 0 ] if ;

: 20p ( m -- n )
    dup 0 >= [ [ 20 - 20p ] [ 10p ] bi + ] [ drop 0 ] if ;

: 50p ( m -- n )
    dup 0 >= [ [ 50 - 50p ] [ 20p ] bi + ] [ drop 0 ] if ;

: 100p ( m -- n )
    dup 0 >= [ [ 100 - 100p ] [ 50p ] bi + ] [ drop 0 ] if ;

: 200p ( m -- n )
    dup 0 >= [ [ 200 - 200p ] [ 100p ] bi + ] [ drop 0 ] if ;

PRIVATE>

: euler031 ( -- answer )
    200 200p ;

! [ euler031 ] 100 ave-time
! 3 ms ave run time - 0.91 SD (100 trials)

! TODO: generalize to eliminate duplication; use a sequence to specify denominations?

SOLUTION: euler031
