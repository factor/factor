! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data alien.strings
combinators.short-circuit fry kernel layouts sequences accessors
specialized-arrays ;
IN: unix.utilities

SPECIALIZED-ARRAY: void*

: more? ( alien -- ? )
    { [ ] [ void* deref ] } 1&& ;

: advance ( void* -- void* )
    cell swap <displaced-alien> ;

: alien>strings ( alien encoding -- strings )
    [ [ dup more? ] ] dip
    '[ [ advance ] [ void* deref _ alien>string ] bi ]
    produce nip ;

: strings>alien ( strings encoding -- array )
    '[ _ malloc-string ] void*-array{ } map-as f suffix ;
