! Copyright (C) 2009 Alec Berryman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays bit-arrays kernel kernel.private
layouts math math.functions math.order math.private
ranges multiline sequences sequences.private typed ;

IN: bloom-filters

/*

TODO:

- The false positive rate is 10x what it should be, based on
  informal testing.  Better object hashes or a better method of
  generating extra hash codes would help.  Another way is to
  increase the number of bits used.

  - Try something smarter than the bitwise complement for a
    second hash code.

  - https://spyced.blogspot.com/2009/01/all-you-ever-wanted-to-know-about.html
    makes a case for https://murmurhash.googlepages.com/ instead
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
{ #hashes fixnum read-only }
{ bits bit-array read-only }
{ capacity fixnum read-only }
{ count fixnum } ;

ERROR: invalid-size size ;
ERROR: invalid-error-rate error-rate ;
ERROR: invalid-capacity capacity ;

<PRIVATE

:: bits-to-satisfy-error-rate ( hashes error objects -- size )
    objects hashes * neg error hashes recip ^ 1 swap - log /
    ceiling >integer ;

! 100 hashes ought to be enough for anybody.
: #hashes-range ( -- range )
    100 [1..b] ;

! { #hashes #bits }
: identity-configuration ( -- 2seq )
    0 max-array-capacity 2array ;

: smaller-second ( 2seq 2seq -- 2seq )
    [ [ second ] bi@ <= ] most ;

! If the number of hashes isn't positive, we haven't found
! anything smaller than the identity configuration.
: check-hashes ( 2seq -- 2seq )
    dup first 0 <= [ invalid-size ] when ;

! The consensus on the tradeoff between increasing the number of
! bits and increasing the number of hash functions seems to be
! "go for the smallest number of bits", probably because most
! implementations just generate one hash value and cheaply
! mangle it into the number of hashes they need.  I have not
! seen any usage studies from the implementations that made this
! tradeoff to support it, and I haven't done my own, but we'll
! go with it anyway.
: size-bloom-filter ( error-rate number-objects -- number-hashes number-bits )
    [ #hashes-range identity-configuration ] 2dip '[
        dup _ _ bits-to-satisfy-error-rate
        2array smaller-second
    ] reduce check-hashes first2 ;

: check-capacity ( capacity -- capacity )
    dup 0 <= [ invalid-capacity ] when ;

: check-error-rate ( error-rate -- error-rate )
    dup [ 0 after? ] [ 1 before? ] bi and
    [ invalid-error-rate ] unless ;

PRIVATE>

: <bloom-filter> ( error-rate capacity -- bloom-filter )
    [ check-error-rate ] [ check-capacity ] bi*
    [ size-bloom-filter <bit-array> ] keep
    0 ! initially empty
    bloom-filter boa ;

<PRIVATE

! See "Bloom Filters in Probabilistic Verification" by Peter C.
! Dillinger and Panagiotis Manolios, section 5.2, "Enhanced
! Double Hashing":
! https://www.ccs.neu.edu/home/pete/research/bloom-filters-verification.html
! https://www.cc.gatech.edu/~manolios/research/bloom-filters-verification.html
: combine-hashcodes ( index hash0 hash1 -- hash )
    { fixnum fixnum fixnum } declare
    [ [ [ 3 ^ ] [ - ] bi 6 /i ] keep ]
    [ fixnum*fast ] [ fixnum+fast ] tri* + abs ;

: double-hashcodes ( object -- hash0 hash1 )
    hashcode >fixnum dup most-positive-fixnum bitxor >fixnum ;

: increment-count ( bloom-filter -- )
    [ 1 + ] change-count drop ; inline

: #hashes-and-length ( bloom-filter -- #hashes length )
    [ #hashes>> ] [ bits>> length ] bi ; inline

: relevant-indices ( object bloom-filter -- n quot: ( elt -- n ) )
    [ double-hashcodes ] [ #hashes-and-length ] bi*
    -rotd '[ _ _ combine-hashcodes _ mod ] ; inline

PRIVATE>

TYPED: bloom-filter-insert ( object bloom-filter: bloom-filter -- )
    [ increment-count ]
    [ relevant-indices ]
    [ bits>> [ [ t ] 2dip set-nth-unsafe ] curry ]
    tri compose each-integer ;

TYPED: bloom-filter-member? ( object bloom-filter: bloom-filter -- ? )
    [ relevant-indices ]
    [ bits>> [ nth-unsafe ] curry ]
    bi compose all-integers? ;
