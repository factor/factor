! Copyright (c) 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math ;
IN: project-euler.031

! http://projecteuler.net/index.php?section=problems&id=31

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
    dup 0 >= [ [ 2 - 2p ] keep 1p + ] [ drop 0 ] if ;

: 5p ( m -- n )
    dup 0 >= [ [ 5 - 5p ] keep 2p + ] [ drop 0 ] if ;

: 10p ( m -- n )
    dup 0 >= [ [ 10 - 10p ] keep 5p + ] [ drop 0 ] if ;

: 20p ( m -- n )
    dup 0 >= [ [ 20 - 20p ] keep 10p + ] [ drop 0 ] if ;

: 50p ( m -- n )
    dup 0 >= [ [ 50 - 50p ] keep 20p + ] [ drop 0 ] if ;

: 100p ( m -- n )
    dup 0 >= [ [ 100 - 100p ] keep 50p + ] [ drop 0 ] if ;

: 200p ( m -- n )
    dup 0 >= [ [ 200 - 200p ] keep 100p + ] [ drop 0 ] if ;

PRIVATE>

: euler031 ( -- answer )
    200 200p ;

! [ euler031 ] 100 ave-time
! 4 ms run / 0 ms GC ave time - 100 trials

! TODO: generalize to eliminate duplication; use a sequence to specify denominations?

MAIN: euler031
