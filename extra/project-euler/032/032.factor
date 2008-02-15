! Copyright (c) 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.lib hashtables kernel math math.combinatorics math.functions
    math.parser math.ranges project-euler.common sequences ;
IN: project-euler.032

! http://projecteuler.net/index.php?section=problems&id=32

! DESCRIPTION
! -----------

! The product 7254 is unusual, as the identity, 39 × 186 = 7254, containing
! multiplicand, multiplier, and product is 1 through 9 pandigital.

! Find the sum of all products whose multiplicand/multiplier/product identity
! can be written as a 1 through 9 pandigital.

! HINT: Some products can be obtained in more than one way so be sure to only
! include it once in your sum.


! SOLUTION
! --------

! Generate all pandigital numbers and then check if they fit the identity

<PRIVATE

: source-032 ( -- seq )
    9 factorial [ 9 permutation [ 1+ ] map 10 digits>integer ] map ;

: 1and4 ( n -- ? )
    number>string 1 cut-slice 4 cut-slice
    [ string>number ] 3apply [ * ] dip = ;

: 2and3 ( n -- ? )
    number>string 2 cut-slice 3 cut-slice
    [ string>number ] 3apply [ * ] dip = ;

: valid? ( n -- ? )
    dup 1and4 swap 2and3 or ;

: products ( seq -- m )
    [ 10 4 ^ mod ] map ;

PRIVATE>

: euler032 ( -- answer )
    source-032 [ valid? ] subset products prune sum ;

! [ euler032 ] 10 ave-time
! 23922 ms run / 1505 ms GC ave time - 10 trials


! ALTERNATE SOLUTIONS
! -------------------

! Generate all reasonable multiplicand/multiplier pairs, then multiply and see
! if the equation is pandigital

<PRIVATE

: source-032a ( -- seq )
    50 [1,b] 2000 [1,b] cartesian-product ;

! multiplicand/multiplier/product
: mmp ( pair -- n )
    first2 2dup * [ number>string ] 3apply 3append string>number ;

PRIVATE>

: euler032a ( -- answer )
    source-032a [ mmp ] map [ pandigital? ] subset products prune sum ;

! [ euler032a ] 100 ave-time
! 5978 ms run / 327 ms GC ave time - 100 trials

MAIN: euler032a
