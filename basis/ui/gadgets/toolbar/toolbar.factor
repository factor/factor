! Copyright (C) 2015 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes colors.constants fry kernel
ui.commands ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.buttons.private ui.gadgets.packs ui.gadgets.tracks
ui.pens.solid ;
IN: ui.gadgets.toolbar

CONSTANT: toolbar-background COLOR: grey95

: <toolbar> ( target -- toolbar )
    <shelf>
        1 >>fill
        { 5 5 } >>gap
        swap
        [ [ "toolbar" ] dip class-of get-command-at commands>> ]
        [ '[ [ _ ] 2dip <command-button> add-gadget ] ]
        bi assoc-each ;

: add-toolbar ( track -- track )
    dup <toolbar> { 3 3 } <border> 
    toolbar-background <solid> >>interior
    align-left f track-add ;
