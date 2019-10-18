! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ui.commands ui.gadgets ui.gadgets.buttons
ui.gadgets.worlds ui.gestures generic hashtables kernel math
models namespaces opengl sequences math.vectors
ui.gadgets.theme ui.gadgets.packs ui.gadgets.borders colors ;
IN: ui.gadgets.menus

: menu-loc ( world menu -- loc )
    >r rect-dim r> pref-dim [v-] hand-loc get-global vmin ;

TUPLE: menu-glass ;

: <menu-glass> ( menu world -- glass )
    menu-glass construct-gadget
    >r over menu-loc over set-rect-loc r>
    [ add-gadget ] keep ;

M: menu-glass layout* gadget-child prefer ;

: hide-glass ( world -- )
    dup world-glass [ unparent ] when*
    f swap set-world-glass ;

: show-glass ( gadget world -- )
    over hand-clicked set-global
    [ hide-glass ] keep
    [ add-gadget ] 2keep
    set-world-glass ;

: show-menu ( gadget owner -- )
    find-world [ <menu-glass> ] keep show-glass ;

\ menu-glass H{
    { T{ button-down } [ find-world [ hide-glass ] when* ] }
    { T{ drag } [ update-clicked drop ] }
} set-gestures

: <menu-item> ( hook target command -- button )
    dup command-name -rot command-button-quot
    swapd
    [ hand-clicked get find-world hide-glass ]
    3append <roll-button> ;

: menu-theme ( gadget -- )
    dup light-gray solid-interior
    faint-boundary ;

: <commands-menu> ( hook target commands -- gadget )
    [
        [ >r 2dup r> <menu-item> gadget, ] each 2drop
    ] make-filled-pile 5 <border> dup menu-theme ;
