! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: bit-arrays formatting kernel math ranges sequences ;
IN: rosetta-code.100-doors

! https://rosettacode.org/wiki/100_doors

! Problem: You have 100 doors in a row that are all initially
! closed. You make 100 passes by the doors. The first time
! through, you visit every door and toggle the door (if the door
! is closed, you open it; if it is open, you close it). The second
! time you only visit every 2nd door (door #2, #4, #6, ...). The
! third time, every 3rd door (door #3, #6, #9, ...), etc, until
! you only visit the 100th door.

! Question: What state are the doors in after the last pass?
! Which are open, which are closed? [1]

! Alternate: As noted in this page's discussion page, the only
! doors that remain open are whose numbers are perfect squares of
! integers. Opening only those doors is an optimization that may
! also be expressed.

CONSTANT: number-of-doors 100

: multiples ( n -- range )
    0 number-of-doors rot <range> ;

: toggle-multiples ( n doors -- )
    [ multiples ] dip '[ _ [ not ] change-nth ] each ;

: toggle-all-multiples ( doors -- )
    [ number-of-doors [1..b] ] dip '[ _ toggle-multiples ] each ;

: print-doors ( doors -- )
    [
        swap "open" "closed" ? "Door %d is %s\n" printf
    ] each-index ;

: doors-main ( -- )
    number-of-doors 1 + <bit-array>
    [ toggle-all-multiples ] [ print-doors ] bi ;
