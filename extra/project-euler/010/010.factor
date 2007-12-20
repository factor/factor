! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math math.functions math.ranges namespaces sequences ;
IN: project-euler.010

! http://projecteuler.net/index.php?section=problems&id=10

! DESCRIPTION
! -----------

! The sum of the primes below 10 is 2 + 3 + 5 + 7 = 17.

! Find the sum of all the primes below one million.


! SOLUTION
! --------

! Sieve of Eratosthenes

<PRIVATE

: candidates ( n -- seq )
    3 swap 2 <range> ;

: multiples ( max n -- seq )
    dup sq -rot <range> ;

: remove-multiples ( n seq -- seq )
    dup supremum rot multiples swap seq-diff ;

: keep-going? ( limit index seq -- ? )
    nth swap sqrt < ;

: (primes-below) ( limit index seq -- seq )
    3dup keep-going? [
        2dup nth swap remove-multiples
        >r 1+ r> (primes-below)
    ] [
        2nip
    ] if ;

PRIVATE>

: primes-below ( n -- seq )
    [ candidates ] keep 0 rot (primes-below) 2 add* ;

: euler010 ( -- answer )
    1000000 primes-below sum ;

! TODO: solution is still too slow for 1000000, probably due to seq-diff
! calling member? for each number that we want to remove

! [ euler010 ] time
! ? ms run / ? ms GC time

MAIN: euler010
