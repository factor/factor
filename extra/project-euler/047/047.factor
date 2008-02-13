! Copyright (c) 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators.lib kernel math math.primes math.primes.factors
    math.ranges namespaces sequences ;
IN: project-euler.047

! http://projecteuler.net/index.php?section=problems&id=47

! DESCRIPTION
! -----------

! The first two consecutive numbers to have two distinct prime factors are:

!     14 = 2 * 7
!     15 = 3 * 5

! The first three consecutive numbers to have three distinct prime factors are:

!     644 = 2² * 7 * 23
!     645 = 3 * 5 * 43
!     646 = 2 * 17 * 19.

! Find the first four consecutive integers to have four distinct primes
! factors. What is the first of these numbers?


! SOLUTION
! --------

! Brute force, not sure why it's incredibly slow compared to other languages

<PRIVATE

: (consecutive) ( count goal test -- n )
    pick pick = [
        swap - nip
    ] [
        dup prime? [ [ drop 0 ] dipd ] [
            2dup unique-factors length = [ [ 1+ ] dipd ] [ [ drop 0 ] dipd ] if
        ] if 1+ (consecutive)
    ] if ;

: consecutive ( goal test -- n )
    0 -rot (consecutive) ;

PRIVATE>

: euler047 ( -- answer )
    4 646 consecutive ;

! [ euler047 ] time
! 542708 ms run / 60548 ms GC time


! ALTERNATE SOLUTIONS
! -------------------

! Use a sieve to generate prime factor counts up to an arbitrary limit, then
! look for a repetition of the specified number of factors.

<PRIVATE

SYMBOL: sieve

: initialize-sieve ( n -- )
    0 <repetition> >array sieve set ;

: is-prime? ( index -- ? )
    sieve get nth zero? ;

: multiples ( n -- seq )
    sieve get length 1- over <range> ;

: increment-counts ( n -- )
     multiples [ sieve get [ 1+ ] change-nth ] each ;

: prime-tau-upto ( limit -- seq )
    dup initialize-sieve 2 swap [a,b) [
        dup is-prime? [ increment-counts ] [ drop ] if
    ] each sieve get ;

: consecutive-under ( m limit -- n/f )
    prime-tau-upto [ dup <repetition> ] dip start ;

PRIVATE>

: euler047a ( -- answer )
    4 200000 consecutive-under ;

! [ euler047a ] 100 ave-time
! 503 ms run / 5 ms GC ave time - 100 trials

! TODO: I don't like that you have to specify the upper bound, maybe try making
! this lazy so it could also short-circuit when it finds the answer?

MAIN: euler047a
