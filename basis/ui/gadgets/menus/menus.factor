! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: colors.constants kernel locals math.rectangles
namespaces sequences ui.commands ui.gadgets ui.gadgets.borders
ui.gadgets.buttons ui.gadgets.glass ui.gadgets.packs
ui.gadgets.worlds ui.gestures ui.operations ;
IN: ui.gadgets.menus

: show-menu ( owner menu -- )
    [ find-world ] dip hand-loc get { 0 0 } <rect> show-glass ;

:: <menu-item> ( target hook command -- button )
    command command-name [
        hook call
        target command command-button-quot call
        hand-clicked get find-world hide-glass
    ] <roll-button> ;

: menu-theme ( gadget -- gadget )
    COLOR: light-gray <solid> >>interior ;

: <commands-menu> ( target hook commands -- menu )
    [ <filled-pile> ] 3dip
    [ <menu-item> add-gadget ] with with each
    { 5 5 } <border> menu-theme ;

: show-commands-menu ( target commands -- )
    [ dup [ ] ] dip <commands-menu> show-menu ;

: <operations-menu> ( target hook -- menu )
    over object-operations <commands-menu> ;

: show-operations-menu ( gadget target hook -- )
    <operations-menu> show-menu ;