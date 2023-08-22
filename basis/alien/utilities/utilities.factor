! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data alien.strings
combinators.short-circuit kernel layouts sequences
specialized-arrays ;
IN: alien.utilities

SPECIALIZED-ARRAY: void*

: deref? ( alien -- ? )
    { [ ] [ void* deref ] } 1&& ;

: advance ( void* -- void* )
    cell swap <displaced-alien> ;

: alien>strings ( alien encoding -- strings )
    [ [ dup deref? ] ] dip
    '[ [ advance ] [ void* deref _ alien>string ] bi ]
    produce nip ;

: strings>alien ( strings encoding -- array )
    '[ _ malloc-string ] void*-array{ } map-as f suffix ;
