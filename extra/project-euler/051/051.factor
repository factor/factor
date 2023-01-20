! Copyright (C) 2009 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.

! https://projecteuler.net/index.php?section=problems&id=1

! DESCRIPTION
! -----------


! By replacing the first digit of *3, it turns out that
! six of the nine possible values:
! 13, 23, 43, 53, 73, and 83, are all prime.
! By replacing the third and fourth digits of 56**3 with the same digit,
! this 5-digit number is the first example having seven primes among
! the ten generated numbers, yielding the family:
! 56003, 56113, 56333, 56443, 56663, 56773, and 56993.
! Consequently 56003, being the first member of this family,
! is the smallest prime with this property.
!
! Find the smallest prime which, by replacing part of the number
! (not necessarily adjacent digits) with the same digit,
! is part of an eight prime value family.

! SOLUTION
! --------

! for each prime number, count the families it belongs to. When one reaches count of 8, stop, and get the smallest number by replacing * with ones.

USING: assocs kernel math math.combinatorics math.functions
math.order math.parser math.primes ranges namespaces
project-euler.common sequences sets ;
IN: project-euler.051
<PRIVATE
SYMBOL: family-count
SYMBOL: large-families
: reset-globals ( -- )
    H{ } clone family-count namespaces:set
    HS{ } clone large-families namespaces:set ;

: digits-positions ( str -- positions )
    H{ } clone [ '[ swap _ push-at ] each-index ] keep ;

: *-if-index ( char combination index -- char )
    member? [ drop CHAR: * ] when ;
: replace-positions-with-* ( str positions -- str )
    [ *-if-index ] curry map-index ;
: all-positions-combinations ( seq -- combinations )
    dup length [1..b] [ all-combinations ] with map concat ;

: families ( stra -- seq )
    dup digits-positions values
    [ all-positions-combinations [ replace-positions-with-* ] with map ] with map concat ;

: save-family ( family -- )
    dup family-count get at 8 = [ large-families get adjoin ] [ drop ] if ;
: increment-family ( family -- )
    family-count get inc-at ;
: handle-family ( family -- )
    [ increment-family ] [ save-family ] bi ;

! Test all primes that have length n
: n-digits-primes ( n -- primes )
    [ 1 - 10^ ] [ 10^ ] bi primes-between ;
: test-n-digits-primes ( n -- seq )
    reset-globals
    n-digits-primes
    [ number>string families [ handle-family ] each ] each
    large-families get members ;

: fill-*-with-ones ( str -- str )
    [ dup CHAR: * = [ drop CHAR: 1 ] when ] map ;

! recursively test all primes by length until we find an answer
: (euler051) ( i -- answer )
    dup test-n-digits-primes [
        1 + (euler051)
    ] [
        nip [ fill-*-with-ones string>number ] [ min ] map-reduce
    ] if-empty ;

PRIVATE>

: euler051 ( -- answer )
    2 (euler051) ;

SOLUTION: euler051
