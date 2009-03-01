! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.strings
combinators.short-circuit fry kernel layouts sequences
specialized-arrays.alien accessors ;
IN: unix.utilities

: more? ( alien -- ? )
    { [ ] [ *void* ] } 1&& ;

: advance ( void* -- void* )
    cell swap <displaced-alien> ;

: alien>strings ( alien encoding -- strings )
    [ [ dup more? ] ] dip
    '[ [ advance ] [ *void* _ alien>string ] bi ]
    produce nip ;

: strings>alien ( strings encoding -- array )
    '[ _ malloc-string ] void*-array{ } map-as f suffix ;
