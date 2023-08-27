! Copyright (c) 2007-2010 Aaron Schaefer.
! The contents of this file are licensed under the Simplified BSD License
! A copy of the license is available at https://factorcode.org/license.txt
USING: accessors arrays byte-arrays hints kernel lists make
math math.functions math.matrices math.order math.parser
math.primes.factors math.primes.lists ranges math.ratios
math.vectors parser prettyprint sequences sorting strings
unicode vocabs.parser words ;
IN: project-euler.common

! A collection of words used by more than one Project Euler solution
! and/or related words that could be useful for future problems.

! Problems using each public word
! -------------------------------
! alpha-value - #22, #42
! cartesian-product - #4, #27, #29, #32, #33, #43, #44, #56
! log10 - #25, #134
! max-path - #18, #67
! mediant - #71, #73
! nth-prime - #7, #69
! nth-triangle - #12, #42
! number>digits - #16, #20, #30, #34, #35, #38, #43, #52, #55, #56, #92, #206
! palindrome? - #4, #36, #55
! pandigital? - #32, #38
! pentagonal? - #44, #45
! penultimate - #69, #71
! propagate-all - #18, #67
! permutations? - #49, #70
! sum-proper-divisors - #21
! tau* - #12
! [uad]-transform - #39, #75


: nth-pair ( seq n -- nth next )
    tail-slice first2 ;

: perfect-square? ( n -- ? )
    dup sqrt mod zero? ;

: alpha-value ( str -- n )
    >lower [ CHAR: a - 1 + ] map-sum ;

: mediant ( a/c b/d -- (a+b)/(c+d) )
    2>fraction [ + ] 2bi@ / ;

<PRIVATE

: max-children ( seq -- seq )
    [ dup length 1 - <iota> [ nth-pair max , ] with each ] { } make ;

PRIVATE>

: max-path ( triangle -- n )
    dup length 1 > [
        2 cut* first2 max-children v+ suffix max-path
    ] [
        first first
    ] if ;

: number>digits ( n -- seq )
    [ dup 0 = not ] [ 10 /mod ] produce reverse! nip ;

: digits>number ( seq -- n )
    0 [ [ 10 * ] [ + ] bi* ] reduce ;

: number-length ( n -- m )
    abs [
        1
    ] [
        1 0 [ 2over >= ]
        [ [ 10 * ] [ 1 + ] bi* ] while 2nip
    ] if-zero ;

: nth-place ( x n -- y )
    10^ [ * round >integer ] keep /f ;

: nth-prime ( n -- n )
    1 - lprimes lnth ;

: nth-triangle ( n -- n )
    dup 1 + * 2 / ;

: palindrome? ( n -- ? )
    number>string dup reverse = ;

: pandigital? ( n -- ? )
    number>string sort >string "123456789" = ;

: pentagonal? ( n -- ? )
    dup 0 > [ 24 * 1 + sqrt 1 + 6 / 1 mod zero? ] [ drop f ] if ; inline

: penultimate ( seq -- elt )
    dup length 2 - swap nth ;

<PRIVATE

! Propagate one row into the upper one
: propagate ( bottom top -- newtop )
    [ over rest rot first2 max rot + ] map nip ;

PRIVATE>

! Not strictly needed, but it is nice to be able to dump the
! triangle after the propagation
: propagate-all ( triangle -- new-triangle )
    reverse unclip dup rot
    [ propagate dup ] map nip
    reverse swap suffix ;

<PRIVATE

: count-digits ( n -- byte-array )
    10 <byte-array> [
        '[ 10 /mod _ [ 1 + ] change-nth dup 0 > ] loop drop
    ] keep ;

HINTS: count-digits fixnum ;

PRIVATE>

: permutations? ( n m -- ? )
    [ count-digits ] same? ;

<PRIVATE

: (sum-divisors) ( n -- sum )
    dup sqrt >integer [1..b] [
        [ 2dup divisor? [ 2dup / + , ] [ drop ] if ] each
        dup perfect-square? [ sqrt >fixnum neg , ] [ drop ] if
    ] { } make sum ;

PRIVATE>

: sum-divisors ( n -- sum )
    dup 4 < [ { 0 1 3 4 } nth ] [ (sum-divisors) ] if ;

: sum-proper-divisors ( n -- sum )
    [ sum-divisors ] keep - ;

: abundant? ( n -- ? )
    dup sum-proper-divisors < ;

: deficient? ( n -- ? )
    dup sum-proper-divisors > ;

: perfect? ( n -- ? )
    dup sum-proper-divisors = ;

! The divisor function, counts the number of divisors
: tau ( m -- n )
    group-factors flip second 1 [ 1 + * ] reduce ;

! Optimized brute-force, is often faster than prime factorization
: tau* ( m -- n )
    factor-2s dup [ 1 + ]
    [ perfect-square? -1 0 ? ]
    [ dup sqrt >fixnum [1..b] ] tri* [
        dupd divisor? [ [ 2 + ] dip ] when
    ] each drop * ;

<PRIVATE

: transform ( triple matrix -- new-triple )
    [ 1array ] dip mdot first ;

PRIVATE>

! These transforms are for generating primitive Pythagorean triples
: u-transform ( triple -- new-triple )
    { { 1 2 2 } { -2 -1 -2 } { 2 2 3 } } transform ;
: a-transform ( triple -- new-triple )
    { { 1 2 2 } { 2 1 2 } { 2 2 3 } } transform ;
: d-transform ( triple -- new-triple )
    { { -1 -2 -2 } { 2 1 2 } { 2 2 3 } } transform ;

SYNTAX: SOLUTION:
    scan-word
    [ name>> "-main" append create-word-in ] keep
    [ drop current-vocab main<< ]
    [ [ . ] swap prefix ( -- ) define-declared ]
    2bi ;
