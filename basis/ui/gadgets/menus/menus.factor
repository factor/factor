! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: locals accessors kernel math namespaces sequences
math.vectors colors math.geometry.rect ui.commands ui.operations ui.gadgets
ui.gadgets.buttons ui.gadgets.worlds ui.gestures ui.gadgets.theme
ui.gadgets.packs ui.gadgets.glass ui.gadgets.borders ;
IN: ui.gadgets.menus

: menu-loc ( world menu -- loc )
    [ dim>> ] [ pref-dim ] bi* [v-] hand-loc get-global vmin ;

: show-menu ( owner menu -- )
    [ find-world dup ] dip tuck menu-loc show-glass ;

:: <menu-item> ( target hook command -- button )
    command command-name [
        hook call
        target command command-button-quot call
        hand-clicked get find-world hide-glass
    ] <roll-button> ;

: menu-theme ( gadget -- gadget )
    light-gray solid-interior
    faint-boundary ;

: <commands-menu> ( target hook commands -- menu )
    [ <filled-pile> ] 3dip
    [ <menu-item> add-gadget ] with with each
    5 <border> menu-theme ;

: show-commands-menu ( target commands -- )
    [ dup [ ] ] dip <commands-menu> show-menu ;

: <operations-menu> ( target hook -- menu )
    over object-operations <commands-menu> ;

: show-operations-menu ( gadget target hook -- )
    <operations-menu> show-menu ;