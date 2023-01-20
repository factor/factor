! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: formatting kernel math ;
IN: rosetta-code.towers-of-hanoi

! https://rosettacode.org/wiki/Towers_of_Hanoi

! In this task, the goal is to solve the Towers of Hanoi problem
! with recursion.

: move ( from to -- )
    "%d->%d\n" printf ;

:: hanoi ( n from to other -- )
    n 0 > [
        n 1 - from other to hanoi
        from to move
        n 1 - other to from hanoi
    ] when ;

! USAGE: 3 1 3 2 hanoi
