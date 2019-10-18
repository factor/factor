! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: random USING: kernel lists math ;

: power-of-2? ( n -- ? ) dup dup neg bitand = ;

: (random-int-0) ( n bits val -- n )
    3dup - + 1 < [
        2drop (random-int) 2dup swap mod (random-int-0)
    ] [
        2nip
    ] ifte ;

: random-int-0 ( max -- n )
    1 + dup power-of-2? [
        (random-int) * -31 shift
    ] [
        (random-int) 2dup swap mod (random-int-0)
    ] ifte ;

: random-int ( min max -- n ) dupd swap - random-int-0 + ;
: random-boolean ( -- ? ) 0 1 random-int 0 = ;
: random-digit ( -- digit ) 0 9 random-int ;
