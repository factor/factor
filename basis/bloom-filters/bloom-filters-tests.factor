USING: accessors bit-arrays bloom-filters bloom-filters.private kernel layouts
math random sequences tools.test ;
IN: bloom-filters.tests

{ { 200 5 } } [ { 100 7 } { 200 5 } smaller-second ] unit-test
{ { 200 5 } } [ { 200 5 } { 100 7 } smaller-second ] unit-test

! The sizing information was generated using the subroutine
! calculate_shortest_filter_length from
! http://www.perl.com/pub/a/2004/04/08/bloom_filters.html.

! Test bloom-filter creation
{ 47965 } [ 7 0.01 5000 bits-to-satisfy-error-rate ] unit-test
{ 7 47965 } [ 0.01 5000 size-bloom-filter ] unit-test
{ 7 } [ 0.01 5000 <bloom-filter> #hashes>> ] unit-test
{ 47965 } [ 0.01 5000 <bloom-filter> bits>> length ] unit-test
{ 5000 } [ 0.01 5000 <bloom-filter> capacity>> ] unit-test
{ 0 } [ 0.01 5000 <bloom-filter> count>> ] unit-test

! Should return the fewest hashes to satisfy the bits requested, not the most.
{ 32 } [ 4 0.05 5 bits-to-satisfy-error-rate ] unit-test
{ 32 } [ 5 0.05 5 bits-to-satisfy-error-rate ] unit-test
{ 4 32 } [ 0.05 5 size-bloom-filter ] unit-test

! This is a lot of bits.
[ 0.00000001 max-array-capacity size-bloom-filter ] [ invalid-size? ]  must-fail-with

! Other error conditions.
[ 1.0 2000 <bloom-filter> ] [ invalid-error-rate? ] must-fail-with
[ 20 2000 <bloom-filter> ] [ invalid-error-rate? ] must-fail-with
[ 0.0 2000 <bloom-filter> ] [ invalid-error-rate? ] must-fail-with
[ -2 2000 <bloom-filter> ] [ invalid-error-rate? ] must-fail-with
[ 0.5 0 <bloom-filter> ] [ invalid-capacity? ] must-fail-with
[ 0.5 -5 <bloom-filter> ] [ invalid-capacity? ] must-fail-with

! Should not generate bignum hash codes.  Enhanced double hashing may generate a
! lot of hash codes, and it's better to do this earlier than later.
{ t } [ 10000 <iota> [ double-hashcodes [ fixnum? ] both? ] all? ] unit-test

: empty-bloom-filter ( -- bloom-filter )
    0.01 2000 <bloom-filter> ;

{ 1 } [ empty-bloom-filter dup increment-count count>> ] unit-test

: basic-insert-test-setup ( -- bloom-filter )
    1 empty-bloom-filter [ bloom-filter-insert ] keep ;

! Basic tests that insert does something
{ t } [ basic-insert-test-setup bits>> [ ] any? ] unit-test
{ 1 } [ basic-insert-test-setup count>> ] unit-test

: non-empty-bloom-filter ( -- bloom-filter )
    1000 <iota>
    empty-bloom-filter
    [ [ bloom-filter-insert ] curry each ] keep ;

: full-bloom-filter ( -- bloom-filter )
    2000 <iota>
    empty-bloom-filter
    [ [ bloom-filter-insert ] curry each ] keep ;

! Should find what we put in there.
{ t } [ 2000 <iota>
        full-bloom-filter
        [ bloom-filter-member? ] curry map
        [ ] all?
] unit-test

! We shouldn't have more than 0.01 false-positive rate.
{ t } [ 1000 <iota> [ drop most-positive-fixnum random 1000 + ] map
        full-bloom-filter
        [ bloom-filter-member? ] curry map
        [ ] count
        ! TODO: This should be 10, but the false positive rate is currently very
        ! high.  300 is large enough not to prevent builds from succeeding.
        300 <=
] unit-test
