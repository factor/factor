! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: formatting io kernel math math.parser sequences ;
IN: rosetta-code.menu

! https://rosettacode.org/wiki/Menu

! Given a list containing a number of strings of which one is to
! be selected and a prompt string, create a function that:

! * Print a textual menu formatted as an index value followed by
!   its corresponding string for each item in the list.
! * Prompt the user to enter a number.
! * Return the string corresponding to the index number.

! The function should reject input that is not an integer or is
! an out of range integer index by recreating the whole menu
! before asking again for a number. The function should return an
! empty string if called with an empty list.

! For test purposes use the four phrases: "fee fie", "huff and
! puff", "mirror mirror" and "tick tock" in a list.

! Note: This task is fashioned after the action of the Bash
! select statement.

: print-menu ( seq -- )
    [ 1 + swap "%d - %s\n" printf ] each-index
    "Your choice? " write flush ;

: select ( seq -- result )
    dup print-menu
    readln string>number [
        1 - swap 2dup bounds-check?
        [ nth ] [ nip select ] if
    ] [ select ] if* ;
