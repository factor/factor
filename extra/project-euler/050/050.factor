! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel math math.order math.primes
project-euler.common sequences ;
IN: project-euler.050

! https://projecteuler.net/index.php?section=problems&id=50

! DESCRIPTION
! -----------

! The prime 41, can be written as the sum of six consecutive primes:

!     41 = 2 + 3 + 5 + 7 + 11 + 13

! This is the longest sum of consecutive primes that adds to a prime below
! one-hundred.

! The longest sum of consecutive primes below one-thousand that adds to a
! prime, contains 21 terms, and is equal to 953.

! Which prime, below one-million, can be written as the sum of the most
! consecutive primes?


! SOLUTION
! --------

! 1) Create an sequence of all primes under 1000000.
! 2) Start summing elements in the sequence until the next number would put you
!    over 1000000.
! 3) Check if that sum is prime, if not, subtract the last number added.
! 4) Repeat step 3 until you get a prime number, and store it along with the
!    how many consecutive numbers from the original sequence it took to get there.
! 5) Drop the first number from the sequence of primes, and do steps 2-4 again
! 6) Compare the longest chain from the first run with the second run, and store
!    the longer of the two.
! 7) If the sequence of primes is still longer than the longest chain, then
!    repeat steps 5-7...otherwise, you've found the longest sum of consecutive
!    primes!

<PRIVATE

:: sum-upto ( seq limit -- length sum )
    0 seq [ + dup limit > ] find
    [ swapd - ] [ drop seq length swap ] if* ;

: pop-until-prime ( seq sum -- seq prime )
    over length 0 > [
        [ unclip-last-slice ] dip swap -
        dup prime? [ pop-until-prime ] unless
    ] [
        2drop { } 0
    ] if ;

! a pair is { length of chain, prime the chain sums to }

: longest-prime ( seq limit -- pair )
    dupd sum-upto dup prime? [
        2array nip
    ] [
        [ head-slice ] dip pop-until-prime
        [ length ] dip 2array
    ] if ;

: continue? ( pair seq -- ? )
    [ first ] [ length 1 - ] bi* < ;

: (find-longest) ( best seq limit -- best )
    [ longest-prime max ] 2keep 2over continue? [
        [ rest-slice ] dip (find-longest)
    ] [ 2drop ] if ;

: find-longest ( seq limit -- best )
    { 1 2 } -rot (find-longest) ;

: solve ( n -- answer )
    [ primes-upto ] keep find-longest second ;

PRIVATE>

: euler050 ( -- answer )
    1000000 solve ;

! [ euler050 ] 100 ave-time
! 291 ms run / 20.6 ms GC ave time - 100 trials

SOLUTION: euler050
