! Copyright (c) 2007-2009 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel lists make math math.functions math.matrices
    math.primes.miller-rabin math.order math.parser math.primes.factors
    math.primes.lists math.ranges math.ratios namespaces parser prettyprint
    quotations sequences sorting strings unicode.case vocabs vocabs.parser
    words ;
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
! number>digits - #16, #20, #30, #34, #35, #38, #43, #52, #55, #56, #92
! palindrome? - #4, #36, #55
! pandigital? - #32, #38
! pentagonal? - #44, #45
! penultimate - #69, #71
! propagate-all - #18, #67
! sum-proper-divisors - #21
! tau* - #12
! [uad]-transform - #39, #75


: nth-pair ( seq n -- nth next )
    tail-slice first2 ;

: perfect-square? ( n -- ? )
    dup sqrt mod zero? ;

<PRIVATE

: max-children ( seq -- seq )
    [ dup length 1- [ nth-pair max , ] with each ] { } make ;

! Propagate one row into the upper one
: propagate ( bottom top -- newtop )
    [ over rest rot first2 max rot + ] map nip ;

: (sum-divisors) ( n -- sum )
    dup sqrt >integer [1,b] [
        [ 2dup divisor? [ 2dup / + , ] [ drop ] if ] each
        dup perfect-square? [ sqrt >fixnum neg , ] [ drop ] if
    ] { } make sum ;

: transform ( triple matrix -- new-triple )
    [ 1array ] dip m. first ;

PRIVATE>

: alpha-value ( str -- n )
    >lower [ CHAR: a - 1+ ] sigma ;

: cartesian-product ( seq1 seq2 -- seq1xseq2 )
    [ [ 2array ] with map ] curry map concat ;

: log10 ( m -- n )
    log 10 log / ;

: mediant ( a/c b/d -- (a+b)/(c+d) )
    2>fraction [ + ] 2bi@ / ;

: max-path ( triangle -- n )
    dup length 1 > [
        2 cut* first2 max-children [ + ] 2map suffix max-path
    ] [
        first first
    ] if ;

: number>digits ( n -- seq )
    [ dup 0 = not ] [ 10 /mod ] produce reverse nip ;

: number-length ( n -- m )
    log10 floor 1+ >integer ;

: nth-prime ( n -- n )
    1- lprimes lnth ;

: nth-triangle ( n -- n )
    dup 1+ * 2 / ;

: palindrome? ( n -- ? )
    number>string dup reverse = ;

: pandigital? ( n -- ? )
    number>string natural-sort >string "123456789" = ;

: pentagonal? ( n -- ? )
    dup 0 > [ 24 * 1+ sqrt 1+ 6 / 1 mod zero? ] [ drop f ] if ;

: penultimate ( seq -- elt )
    dup length 2 - swap nth ;

! Not strictly needed, but it is nice to be able to dump the triangle after the
! propagation
: propagate-all ( triangle -- new-triangle )
    reverse [ first dup ] [ rest ] bi
    [ propagate dup ] map nip reverse swap suffix ;

: sum-divisors ( n -- sum )
    dup 4 < [ { 0 1 3 4 } nth ] [ (sum-divisors) ] if ;

: sum-proper-divisors ( n -- sum )
    dup sum-divisors swap - ;

: abundant? ( n -- ? )
    dup sum-proper-divisors < ;

: deficient? ( n -- ? )
    dup sum-proper-divisors > ;

: perfect? ( n -- ? )
    dup sum-proper-divisors = ;

! The divisor function, counts the number of divisors
: tau ( m -- n )
    group-factors flip second 1 [ 1+ * ] reduce ;

! Optimized brute-force, is often faster than prime factorization
: tau* ( m -- n )
    factor-2s dup [ 1+ ]
    [ perfect-square? -1 0 ? ]
    [ dup sqrt >fixnum [1,b] ] tri* [
        dupd divisor? [ [ 2 + ] dip ] when
    ] each drop * ;

! These transforms are for generating primitive Pythagorean triples
: u-transform ( triple -- new-triple )
    { { 1 2 2 } { -2 -1 -2 } { 2 2 3 } } transform ;
: a-transform ( triple -- new-triple )
    { { 1 2 2 } { 2 1 2 } { 2 2 3 } } transform ;
: d-transform ( triple -- new-triple )
    { { -1 -2 -2 } { 2 1 2 } { 2 2 3 } } transform ;

SYNTAX: SOLUTION:
    scan-word
    [ name>> "-main" append create-in ] keep
    [ drop in get vocab (>>main) ]
    [ [ . ] swap prefix (( -- )) define-declared ]
    2bi ;
