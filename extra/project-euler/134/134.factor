! Copyright (c) 2007 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math math.functions math.ranges math.primes.list namespaces
       sequences vars ;
IN: project-euler.134

! http://projecteuler.net/index.php?section=problems&id=134

! DESCRIPTION
! -----------

! Consider the consecutive primes p1 = 19 and p2 = 23. It can be
! verified that 1219 is the smallest number such that the last digits
! are formed by p1 whilst also being divisible by p2.

! In fact, with the exception of p1 = 3 and p2 = 5, for every pair of
! consecutive primes, p2 p1, there exist values of n for which the last
! digits are formed by p1 and n is divisible by p2. Let S be the
! smallest of these values of n.

! Find S for every pair of consecutive primes with 5 p1 1000000.

! SOLUTION
! --------

<PRIVATE

! Compute the smallest power of 10 greater than m
: next-power-of-10 ( m -- n )
  10 swap log 10 log / >integer [ 10 * ] times ; foldable

! Helper variables and words for the extended Euclidian algorithm
! See http://en.wikipedia.org/wiki/Extended_Euclidean_algorithm

VARS: r-1 u-1 v-1 r u v ;

: init ( a b -- )
  >r >r-1 0 >u 1 >u-1 1 >v 0 >v-1 ;

: advance ( r u v -- )
  v> >v-1 >v u> >u-1 >u r> >r-1 >r ;

: step ( -- )
  r-1> r> 2dup / >integer [ * - ] keep u-1> over u> * - v-1> rot v> * -
  advance ;

! Compute the inverse of a in field Z/bZ where b is prime
: inverse ( a b -- a-1 )
  [ init [ r> 0 > ] [ step ] [ ] while u-1> ] with-scope ;

! Compute S for a given pair (p1, p2)
: s ( p1 p2 -- s )
  over next-power-of-10 [ over inverse pick * neg swap rem ] keep * + ;

PRIVATE>

: euler134 ( -- answer )
  primes-under-million 2 tail dup 1 tail 1000003 add  [ s ] 2map sum ;

! [ euler134 ] 10 ave-time
! 6743 ms run / 79 ms GC ave time - 10 trials

MAIN: euler134
