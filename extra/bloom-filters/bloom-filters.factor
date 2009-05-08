! Copyright (C) 2009 Alec Berryman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs bit-arrays kernel layouts locals math
math.functions math.ranges multiline sequences ;
IN: bloom-filters

/*

TODO:

- How to singal an error when too many bits?  It looks like a built-in for some
  types of arrays, but bit-array just returns a zero-length array.  What we do
  now is completely broken: -1 hash codes?  Really?

- The false positive rate is 10x what it should be, based on informal testing.
  Better object hashes or a better method of generating extra hash codes would
  help.  Another way is to increase the number of bits used.

  - Try something smarter than the bitwise complement for a second hash code.

  - http://spyced.blogspot.com/2009/01/all-you-ever-wanted-to-know-about.html
    makes a case for http://murmurhash.googlepages.com/ instead of enhanced
    double-hashing.

  - Be sure to adjust the test that asserts the number of false positives isn't
    unreasonable.

- Should round bits up to next power of two, use wrap instead of mod.

- Should allow user to specify the hash codes, either as inputs to enhanced
  double hashing or for direct use.

- Support for serialization.

- Wrappers for combining filters.

- Should we signal an error when inserting past the number of objects the filter
  is sized for?  The filter will continue to work, just not very well.

- The other TODOs sprinkled through the code.

*/

TUPLE: bloom-filter
{ n-hashes fixnum read-only }
{ bits bit-array read-only }
{ maximum-n-objects fixnum read-only }
{ current-n-objects fixnum } ;

<PRIVATE

! number-bits = -(n-objects * n-hashes) / ln(1 - error-rate ^ 1/n-hashes)
:: bits-to-satisfy-error-rate ( n-hashes error-rate n-objects -- size )
    n-objects n-hashes * -1 *
    1 error-rate 1 n-hashes / ^ - log
    /
    ceiling >integer ; ! should check that it's below max-array-capacity

! TODO: this should be a constant
!
! TODO: after very little experimentation, I never see this increase after about
! 20 or so.  Maybe it should be smaller.
: n-hashes-range ( -- range )
    100 [1,b] ;

! Ends up with a list of arrays - { n-bits position }
: find-bloom-filter-sizes ( error-rate number-objects -- seq )
    [ bits-to-satisfy-error-rate ] 2curry
    n-hashes-range swap
    map
    n-hashes-range zip ;

:: smallest-first ( seq1 seq2 -- seq )
    seq1 first seq2 first <= [ seq1 ] [ seq2 ] if ;

! The consensus on the tradeoff between increasing the number of bits and
! increasing the number of hash functions seems to be "go for the smallest
! number of bits", probably because most implementations just generate one hash
! value and cheaply mangle it into the number of hashes they need.  I have not
! seen any usage studies from the implementations that made this tradeoff to
! support it, and I haven't done my own, but we'll go with it anyway.
!
! TODO: check that error-rate is reasonable.
: size-bloom-filter ( error-rate number-objects -- number-hashes number-bits )
    find-bloom-filter-sizes
    max-array-capacity -1 2array
    [ smallest-first ]
    reduce
    [ second ] [ first ] bi ;

PRIVATE>

: <bloom-filter> ( error-rate number-objects -- bloom-filter )
    [ size-bloom-filter <bit-array> ] keep
    0 ! initially empty
    bloom-filter boa ;

<PRIVATE

! See "Bloom Filters in Probabilistic Verification" by Peter C. Dillinger and
! Panagiotis Manolios, section 5.2, "Enhanced Double Hashing":
! http://www.cc.gatech.edu/~manolios/research/bloom-filters-verification.html
!
! This is taken from the definition at the top of page 12:
!
! F(i) = (A(s) + (i * B(s)) + ((i^3 - i) / 6)) mod m
!
! Where i is the hash number, A and B are hash functions for object s, and m is
! the length of the array.

:: enhanced-double-hash ( index hash0 hash1 array-size -- hash )
    hash0
    index hash1 *
    +
    index 3 ^ index -
    6 /
    +
    array-size mod ;

: enhanced-double-hashes ( n hash0 hash1 array-size -- seq )
    [ enhanced-double-hash ] 3curry
    [ [0,b) ] dip
    map ;

! Stupid, should pick something good.
: hashcodes-from-hashcode ( n -- n n )
    dup
    ! we could be running this through a lot of double hashing, make sure it's a
    ! fixnum here
    most-positive-fixnum >fixnum bitxor ;

! TODO: This code calls abs because all the double-hashing stuff outputs array
! indices and those aren't good negative.  Are we throwing away bits?  -1000
! b. actually prints -1111101000, which confuses me.
: hashcodes-from-object ( obj -- n n )
    hashcode abs hashcodes-from-hashcode ;

: set-indices ( indices bit-array -- )
    [ [ drop t ] change-nth ] curry each ;

: increment-n-objects ( bloom-filter -- )
    dup current-n-objects>> 1 + >>current-n-objects drop ;

! This would be better as an each-relevant-hash that didn't cons.
: relevant-indices ( value bloom-filter -- indices )
    [ n-hashes>> ] [ bits>> length ] bi ! value n array-size
    swapd [ hashcodes-from-object ] dip ! n value1 value2 array-size
    enhanced-double-hashes ;

PRIVATE>

: bloom-filter-insert ( object bloom-filter -- )
    [ relevant-indices ]
    [ bits>> set-indices ]
    [ increment-n-objects ]
    tri ;

: bloom-filter-member? ( value bloom-filter -- ? )
    [ relevant-indices ]
    [ bits>> [ nth ] curry map [ t = ] all? ]
    bi ;
