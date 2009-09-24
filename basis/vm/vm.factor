! Copyright (C) 2009 Phil Dawes.
! See http://factorcode.org/license.txt for BSD license.
USING: classes.struct alien.syntax ;
IN: vm

TYPEDEF: void* cell

STRUCT: zone
    { start cell }
    { here cell }
    { size cell }
    { end cell } ;

STRUCT: vm
    { stack_chain context* }
    { nursery zone }
    { cards_offset cell }
    { decks_offset cell }
    { userenv cell[70] } ;

: vm-field-offset ( field -- offset ) vm offset-of ; inline
