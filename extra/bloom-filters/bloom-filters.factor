! Copyright (C) 2009 Alec Berryman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays bit-arrays fry kernel layouts locals math math.functions
multiline sequences ;
IN: bloom-filters

FROM: math.ranges => [1,b] [0,b) ;
FROM: math.intervals => (a,b) interval-contains? ;

/*

TODO:

- The false positive rate is 10x what it should be, based on informal testing.
  Better object hashes or a better method of generating extra hash codes would
  help.  Another way is to increase the number of bits used.

  - Try something smarter than the bitwise complement for a second hash code.

  - http://spyced.blogspot.com/2009/01/all-you-ever-wanted-to-know-about.html
    makes a case for http://murmurhash.googlepages.com/ instead of enhanced
    double-hashing.

  - Be sure to adjust the test that asserts the number of false positives isn't
    unreasonable.

- Could round bits up to next power of two and use wrap instead of mod.  This
  would cost a lot of bits on 32-bit platforms, though, and limit the bit-array
  to 8MB.

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

ERROR: capacity-error ;
ERROR: invalid-error-rate ;
ERROR: invalid-n-objects ;

<PRIVATE

! number-bits = -(n-objects * n-hashes) / ln(1 - error-rate ^ 1/n-hashes)
:: bits-to-satisfy-error-rate ( n-hashes error-rate n-objects -- size )
    n-objects n-hashes * -1 *
    1 error-rate 1 n-hashes / ^ - log
    /
    ceiling >integer ; ! should check that it's below max-array-capacity

! 100 hashes ought to be enough for anybody.
: n-hashes-range ( -- range )
    100 [1,b] ;

! { n-hashes n-bits }
: identity-configuration ( -- 2seq )
    0 max-array-capacity 2array ;

: smaller-second ( 2seq 2seq -- 2seq )
    [ [ second ] bi@ <= ] most ;

! If the number of hashes isn't positive, we haven't found anything smaller than the
! identity configuration.
: validate-sizes ( 2seq -- )
    first 0 <= [ capacity-error ] when* ;

! The consensus on the tradeoff between increasing the number of bits and
! increasing the number of hash functions seems to be "go for the smallest
! number of bits", probably because most implementations just generate one hash
! value and cheaply mangle it into the number of hashes they need.  I have not
! seen any usage studies from the implementations that made this tradeoff to
! support it, and I haven't done my own, but we'll go with it anyway.
!
: size-bloom-filter ( error-rate number-objects -- number-hashes number-bits )
    '[ _ _ bits-to-satisfy-error-rate ]
    '[ dup _ call 2array smaller-second ]
    '[ n-hashes-range identity-configuration _ reduce ]
    call
    dup validate-sizes
    first2 ;

: validate-n-objects ( n-objects -- )
    0 <= [ invalid-n-objects ] when ;

: valid-error-rate-interval ( -- interval )
    0 1 (a,b) ;

: validate-error-rate ( error-rate -- )
    valid-error-rate-interval interval-contains?
    [ invalid-error-rate ] unless ;

: validate-constraints ( error-rate n-objects -- )
    validate-n-objects validate-error-rate ;

PRIVATE>

: <bloom-filter> ( error-rate number-objects -- bloom-filter )
    [ validate-constraints ] 2keep
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
    '[ _ _ _ enhanced-double-hash ] [ [0,b) ] dip map ;

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

: increment-n-objects ( bloom-filter -- bloom-filter )
    [ 1 + ] change-current-n-objects ;

: n-hashes-and-bits ( bloom-filter -- n-hashes n-bits )
    [ n-hashes>> ] [ bits>> length ] bi ;

: relevant-indices ( value bloom-filter -- indices )
    n-hashes-and-bits
    [ swap hashcodes-from-object ] dip
    enhanced-double-hashes ;

PRIVATE>

: bloom-filter-insert ( object bloom-filter -- )
    increment-n-objects
    [ relevant-indices ] [ bits>> set-indices ] bi ;

: bloom-filter-member? ( value bloom-filter -- ? )
    [ relevant-indices ] keep
    bits>> nths [ ] all? ;
