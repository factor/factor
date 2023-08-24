! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: combinators kernel make math ;
IN: rosetta-code.happy-numbers

! https://rosettacode.org/wiki/Happy_numbers#Factor

! From Wikipedia, the free encyclopedia:

! A happy number is defined by the following process. Starting
! with any positive integer, replace the number by the sum of the
! squares of its digits, and repeat the process until the number
! equals 1 (where it will stay), or it loops endlessly in a cycle
! which does not include 1. Those numbers for which this process
! ends in 1 are happy numbers, while those that do not end in 1
! are unhappy numbers. Display an example of your output here.

! Task: Find and print the first 8 happy numbers.

: squares ( n -- s )
    0 [ over 0 > ] [ [ 10 /mod sq ] dip + ] while nip ;

: (happy?) ( n1 n2 -- ? )
    [ squares ] [ squares squares ] bi* {
        { [ dup 1 = ] [ 2drop t ] }
        { [ 2dup = ] [ 2drop f ] }
        [ (happy?) ]
    } cond ;

: happy? ( n -- ? )
    dup (happy?) ;

: happy-numbers ( n -- seq )
    [
        0 [ over 0 > ] [
            dup happy? [ dup , [ 1 - ] dip ] when 1 +
        ] while 2drop
    ] { } make ;
