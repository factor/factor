! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: arrays io kernel math ranges prettyprint sequences vectors ;
IN: rosetta-code.hailstone-sequence

! https://rosettacode.org/wiki/Hailstone_sequence

! The Hailstone sequence of numbers can be generated from a
! starting positive integer, n by:

! * If n is 1 then the sequence ends.
! * If n is even then the next n of the sequence = n/2
! * If n is odd then the next n of the sequence = (3 * n) + 1

! The (unproven), Collatz conjecture is that the hailstone
! sequence for any starting number always terminates.

! Task Description:

! 1. Create a routine to generate the hailstone sequence for a
!    number.

! 2. Use the routine to show that the hailstone sequence for the
!    number 27 has 112 elements starting with 27, 82, 41, 124 and
!    ending with 8, 4, 2, 1

! 3. Show the number less than 100,000 which has the longest
!    hailstone sequence together with that sequences length.
!    (But don't show the actual sequence)!

: hailstone ( n -- seq )
    [ 1vector ] keep
    [ dup 1 number= ]
    [
        dup even? [ 2 / ] [ 3 * 1 + ] if
        2dup swap push
    ] until
    drop ;

: hailstone-main ( -- )
    27 hailstone dup dup
    "The hailstone sequence from 27:" print
    "  has length " write length .
    "  starts with " write 4 head [ unparse ] map ", " join print
    "  ends with " write 4 tail* [ unparse ] map ", " join print

    ! Maps n => { length n }, and reduces to longest Hailstone sequence.
    100000 [1..b)
    [ [ hailstone length ] keep 2array ]
    [ [ [ first ] bi@ > ] most ] map-reduce
    first2
    "The hailstone sequence from " write pprint
    " has length " write pprint "." print ;

MAIN: hailstone-main
