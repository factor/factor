! Copyright (C) 2009 Alec Berryman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays bit-arrays fry kernel layouts locals
math math.functions math.order math.private multiline sequences
sequences.private typed ;
FROM: math.ranges => [1,b] ;

IN: bloom-filters

/*

TODO:

- The false positive rate is 10x what it should be, based on
  informal testing.  Better object hashes or a better method of
  generating extra hash codes would help.  Another way is to
  increase the number of bits used.

  - Try something smarter than the bitwise complement for a
    second hash code.

  - http://spyced.blogspot.com/2009/01/all-you-ever-wanted-to-know-about.html
    makes a case for http://murmurhash.googlepages.com/ instead
    of enhanced double-hashing.

  - Be sure to adjust the test that asserts the number of false
    positives isn't unreasonable.

- Could round bits up to next power of two and use wrap instead
  of mod.  This would cost a lot of bits on 32-bit platforms,
  though, and limit the bit-array to 8MB.

- Should allow user to specify the hash codes, either as inputs
  to enhanced double hashing or for direct use.

- Support for serialization.

- Wrappers for combining filters.

- Should we signal an error when inserting past the number of
  objects the filter is sized for?  The filter will continue to
  work, just not very well.

*/

TUPLE: bloom-filter
{ n-hashes fixnum read-only }
{ bits bit-array read-only }
{ maximum-n-objects fixnum read-only }
{ current-n-objects fixnum } ;

ERROR: capacity-error ;
ERROR: invalid-error-rate error-rate ;
ERROR: invalid-n-objects n-objects ;

<PRIVATE

:: bits-to-satisfy-error-rate ( hashes error objects -- size )
    objects hashes * neg error hashes recip ^ 1 swap - log /
    ceiling >integer ;

! 100 hashes ought to be enough for anybody.
: n-hashes-range ( -- range )
    100 [1,b] ;

! { n-hashes n-bits }
: identity-configuration ( -- 2seq )
    0 max-array-capacity 2array ;

: smaller-second ( 2seq 2seq -- 2seq )
    [ [ second ] bi@ <= ] most ;

! If the number of hashes isn't positive, we haven't found
! anything smaller than the identity configuration.
: check-capacity ( 2seq -- 2seq )
    dup first 0 <= [ capacity-error ] when ;

! The consensus on the tradeoff between increasing the number of
! bits and increasing the number of hash functions seems to be
! "go for the smallest number of bits", probably because most
! implementations just generate one hash value and cheaply
! mangle it into the number of hashes they need.  I have not
! seen any usage studies from the implementations that made this
! tradeoff to support it, and I haven't done my own, but we'll
! go with it anyway.
: size-bloom-filter ( error-rate number-objects -- number-hashes number-bits )
    [ n-hashes-range identity-configuration ] 2dip '[
        dup _ _ bits-to-satisfy-error-rate
        2array smaller-second
    ] reduce check-capacity first2 ;

: check-n-objects ( n-objects -- n-objects )
    dup 0 <= [ invalid-n-objects ] when ;

: check-error-rate ( error-rate -- error-rate )
    dup [ 0 after? ] [ 1 before? ] bi and
    [ invalid-error-rate ] unless ;

PRIVATE>

: <bloom-filter> ( error-rate number-objects -- bloom-filter )
    [ check-error-rate ] [ check-n-objects ] bi*
    [ size-bloom-filter <bit-array> ] keep
    0 ! initially empty
    bloom-filter boa ;

<PRIVATE

! See "Bloom Filters in Probabilistic Verification" by Peter C.
! Dillinger and Panagiotis Manolios, section 5.2, "Enhanced
! Double Hashing":
! http://www.cc.gatech.edu/~manolios/research/bloom-filters-verification.html
TYPED:: enhanced-double-hash ( index: fixnum hash0: fixnum hash1: fixnum -- hash )
    hash0 index fixnum*fast hash1 fixnum+fast
    index 3 ^ index - 6 /i + abs ;

: enhanced-double-hashes ( hash0 hash1 n -- seq )
    -rot '[ _ _ enhanced-double-hash ] { } map-integers ;

! Make sure it's a fixnum here to speed up double-hashing.
: hashcodes-from-object ( obj -- n n )
    hashcode >fixnum dup most-positive-fixnum bitxor >fixnum ;

TYPED: set-indices ( indices: array bit-array: bit-array -- )
    [ t ] 2dip [ set-nth-unsafe ] curry with each ; inline

TYPED: increment-n-objects ( bloom-filter: bloom-filter -- )
    [ 1 + ] change-current-n-objects drop ; inline

TYPED: n-hashes-and-length ( bloom-filter: bloom-filter -- n-hashes length )
    [ n-hashes>> ] [ bits>> length ] bi ;

TYPED: relevant-indices ( value bloom-filter: bloom-filter -- indices )
    [ hashcodes-from-object ] [ n-hashes-and-length ] bi*
    [ enhanced-double-hashes ] dip '[ _ mod ] map ;

PRIVATE>

: bloom-filter-insert ( object bloom-filter -- )
    [ increment-n-objects ]
    [ relevant-indices ]
    [ bits>> set-indices ]
    tri ;

: bloom-filter-member? ( object bloom-filter -- ? )
    [ relevant-indices ] [ bits>> ] bi
    [ nth-unsafe ] curry all? ;
