! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: kernel make math math.parser sequences ;
IN: rosetta-code.look-and-say

! https://rosettacode.org/wiki/Look-and-say_sequence

! Sequence Definition
! * Take a decimal number
! * Look at the number, visually grouping consecutive runs of
!   the same digit.
! * Say the number, from left to right, group by group; as how
!   many of that digit there are - followed by the digit grouped.
!   This becomes the next number of the sequence.

! The sequence is from John Conway, of Conway's Game of Life fame.

! An example:
! * Starting with the number 1, you have one 1 which produces 11.
! * Starting with 11, you have two 1's i.e. 21
! * Starting with 21, you have one 2, then one 1 i.e. (12)(11) which becomes 1211
! * Starting with 1211 you have one 1, one 2, then two 1's i.e. (11)(12)(21) which becomes 111221

! Task description

! Write a program to generate successive members of the look-and-say sequence.

: (look-and-say) ( str -- )
    unclip-slice swap [ 1 ] 2dip [
        2dup = [ drop [ 1 + ] dip ] [
            [ [ number>string % ] dip , 1 ] dip
        ] if
    ] each [ number>string % ] [ , ] bi* ;

: look-and-say ( str -- str' )
    [ (look-and-say) ] "" make ;
