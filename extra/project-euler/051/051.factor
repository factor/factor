! Copyright (C) 2009 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel math math.combinatorics math.functions
math.parser math.primes namespaces project-euler.common
sequences sets strings grouping math.ranges arrays ;
IN: project-euler.051

SYMBOL: family-count
SYMBOL: large-families
: reset-globals ( -- ) 
    H{ } clone family-count set
    H{ } clone large-families set ;

: append-or-create ( value seq/f -- seq )
    dup [ swap suffix ] [ drop 1array ] if ;
: append-at ( value key assoc -- )
    [ at append-or-create ] 2keep set-at ;
: digits-positions ( str -- positions )
    H{ } clone swap over [ swapd append-at ] curry each-index ;

: *-if-index ( char combination index -- char )
    member? [ drop CHAR: * ] when ;
: replace-positions-with-* ( str positions -- str )
    [ *-if-index ] curry map-index ;
: all-size-combinations ( seq -- combinations )
    dup length [1,b] [ all-combinations ] with map concat ;

: families ( stra -- seq )
    dup digits-positions values 
    [ all-size-combinations [ replace-positions-with-* ] with map ] with map concat ;

: save-family ( family -- )
    family-count get dupd at 8 = [ large-families get conjoin ] [ drop ] if ;
: increment-family ( family -- )
    family-count get dupd at* [ 1 + ] [ drop 1 ] if swap family-count get set-at ;
: handle-family ( family -- )
    [ increment-family ] [ save-family ] bi ;

! Test all primes that have length n
: n-digits-primes ( n -- primes )
    [ 1 - 10^ ] [ 10^ ] bi primes-between ; 
: test-n-digits-primes ( n -- seq )
    reset-globals 
    n-digits-primes 
    [ number>string families [ handle-family ] each ] each
    large-families get ;

: fill-*-with-ones ( str -- str )
    [ dup CHAR: * = [ drop CHAR: 1 ] when ] map ;

! recursively test all primes by length until we find an answer
: (euler051) ( i -- answer )
    dup test-n-digits-primes 
    dup assoc-size 0 > 
    [ nip values [ fill-*-with-ones string>number ] map infimum ]
    [ drop 1 + (euler051) ] if ;
: euler051 ( -- answer )
    2 (euler051) ;
