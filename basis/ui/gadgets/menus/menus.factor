! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: colors.constants kernel locals math.rectangles namespaces
sequences ui.commands ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.glass ui.gadgets.packs ui.gadgets.frames ui.gadgets.worlds
ui.gadgets.corners ui.gestures ui.operations
ui.render ui.pens ui.pens.solid opengl math.vectors words accessors
math math.order sorting ;
IN: ui.gadgets.menus

: show-menu ( owner menu -- )
    [ find-world ] dip hand-loc get-global { 0 0 } <rect> show-glass ;

GENERIC: <menu-item> ( target hook command -- button )

M:: object <menu-item> ( target hook command -- button )
    command command-name [
        hook call
        target command command-button-quot call
        hide-glass
    ] <roll-button> ;

<PRIVATE

TUPLE: separator-pen color ;

C: <separator-pen> separator-pen

M: separator-pen draw-interior
    color>> gl-color
    dim>> [ { 0 0.5 } v* ] [ { 1 0.5 } v* ] bi
    [ [ >integer ] map ] bi@ gl-line ;

: <menu-items> ( items -- gadget )
    [ <filled-pile> ] dip add-gadgets
    panel-background-color <solid> >>interior ;

PRIVATE>

SINGLETON: ----

M: ---- <menu-item>
    3drop
    <gadget>
        { 0 5 } >>dim
        COLOR: black <separator-pen> >>interior ;

: menu-theme ( gadget -- gadget )
    COLOR: light-gray <solid> >>interior ;

: <menu> ( gadgets -- menu )
    <menu-items>
    frame "menu-background" [
        /-----\
        |-----|
        \-----/
    ] make-corners ;

: <commands-menu> ( target hook commands -- menu )
    [ <menu-item> ] with with map <menu> ;

: show-commands-menu ( target commands -- )
    [ dup [ ] ] dip <commands-menu> show-menu ;

: <operations-menu> ( target hook -- menu )
    over object-operations
    [ primary-operation? ] partition
    [ reverse ] [ [ command-name ] sort-with ] bi*
    { ---- } glue <commands-menu> ;

: show-operations-menu ( gadget target hook -- )
    <operations-menu> show-menu ;
