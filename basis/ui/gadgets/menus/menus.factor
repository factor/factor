! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: locals accessors arrays ui.commands ui.operations ui.gadgets
ui.gadgets.buttons ui.gadgets.worlds ui.gestures generic
hashtables kernel math models namespaces opengl sequences
math.vectors ui.gadgets.theme ui.gadgets.packs
ui.gadgets.borders colors math.geometry.rect ;
IN: ui.gadgets.menus

: menu-loc ( world menu -- loc )
    [ rect-dim ] [ pref-dim ] bi* [v-] hand-loc get-global vmin ;

TUPLE: menu-glass < gadget ;

: <menu-glass> ( world menu -- glass )
    tuck menu-loc >>loc
    menu-glass new-gadget
    swap add-gadget ;

M: menu-glass layout* gadget-child prefer ;

: hide-glass ( world -- )
    [ [ unparent ] when* f ] change-glass drop ;

: show-glass ( world gadget -- )
    [ [ hide-glass ] [ hand-clicked set-global ] bi* ]
    [ add-gadget drop ]
    [ >>glass drop ]
    2tri ;

: show-menu ( owner menu -- )
    [ find-world dup ] dip <menu-glass> show-glass ;

\ menu-glass H{
    { T{ button-down } [ find-world [ hide-glass ] when* ] }
    { T{ drag } [ update-clicked drop ] }
} set-gestures

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

: show-operations-menu ( gadget target -- )
    [ ] <operations-menu> show-menu ;