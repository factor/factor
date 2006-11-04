! Rewritten by Matthew Willis, July 2006
! Copyright (C) 2004 Chris Double.
! See http://factorcode.org/license.txt for BSD license.

USING: lazy-lists math kernel sequences test ;
IN: lazy-examples

: naturals 0 lfrom ;
: positives 1 lfrom ;
: evens 0 [ 2 + ] lfrom-by ;
: odds 1 lfrom [ 2 mod 1 = ] lsubset ;
: powers-of-2 1 [ 2 * ] lfrom-by ;
: ones 1 [ ] lfrom-by ;
: squares naturals [ dup * ] lmap ;
: first-five-squares 5 squares ltake list>array ;

: divisible-by? ( a b -- bool )
    #! Return true if a is divisible by b
    mod 0 = ;

: filter-multiples ( n list -- list )
    #! Given a lazy list of numbers, filter multiples of n
    swap [ divisible-by? not ] curry lsubset ;

! : primes ( -- list )
!    2 lfrom [ filter-multiples ] lapply ;

! : first-ten-primes 10 primes ltake list>array ;
