! Copyright (c) 2009 Guillaume Nargeot.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs hashtables kernel math math.ranges
project-euler.common sequences sets ;
IN: project-euler.074

! http://projecteuler.net/index.php?section=problems&id=074

! DESCRIPTION
! -----------

! The number 145 is well known for the property that the sum of the factorial
! of its digits is equal to 145:

! 1! + 4! + 5! = 1 + 24 + 120 = 145

! Perhaps less well known is 169, in that it produces the longest chain of
! numbers that link back to 169; it turns out that there are only three such
! loops that exist:

! 169 → 363601 → 1454 → 169
! 871 → 45361 → 871
! 872 → 45362 → 872

! It is not difficult to prove that EVERY starting number will eventually get
! stuck in a loop. For example,

! 69 → 363600 → 1454 → 169 → 363601 (→ 1454)
! 78 → 45360 → 871 → 45361 (→ 871)
! 540 → 145 (→ 145)

! Starting with 69 produces a chain of five non-repeating terms, but the
! longest non-repeating chain with a starting number below one million is sixty
! terms.

! How many chains, with a starting number below one million, contain exactly
! sixty non-repeating terms?


! SOLUTION
! --------

! Brute force

<PRIVATE

: digit-factorial ( n -- n! )
    { 1 1 2 6 24 120 720 5040 40320 362880 } nth ;

: digits-factorial-sum ( n -- n )
    number>digits [ digit-factorial ] sigma ;

: chain-length ( n -- n )
    61 <hashtable>
    [ 2dup key? not ]
    [ [ conjoin ] [ [ digits-factorial-sum ] dip ] 2bi ]
    while nip assoc-size ;

PRIVATE>

: euler074 ( -- answer )
    1000000 [1,b] [ chain-length 60 = ] count ;

! [ euler074 ] 10 ave-time
! 25134 ms ave run time - 31.96 SD (10 trials)

SOLUTION: euler074

