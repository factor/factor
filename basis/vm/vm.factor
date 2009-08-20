! Copyright (C) 2009 Phil Dawes.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.structs alien.syntax ;
IN: vm

TYPEDEF: void* cell

C-STRUCT: zone
    { "cell" "start" }
    { "cell" "here" }
    { "cell" "size" }
    { "cell" "end" }
    ;

C-STRUCT: vm
    { "context*" "stack_chain" }
    { "zone" "nursery" }
    { "cell" "cards_offset" }
    { "cell" "decks_offset" }
    ;

: vm-field-offset ( field -- offset ) "vm" offset-of ;