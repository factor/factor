! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces ui.gadgets ui.gadgets.worlds
ui.gestures math.rectangles math.rectangles.positioning
combinators ;
IN: ui.gadgets.glass

GENERIC: hide-glass-hook ( gadget -- )

M: gadget hide-glass-hook drop ;

: hide-glass ( world -- )
    [ [ unparent ] when* f ] change-glass drop ;

<PRIVATE

TUPLE: glass < gadget visible-rect owner ;

: <glass> ( owner child visible-rect -- glass )
    glass new-gadget
        swap >>visible-rect
        swap add-gadget
        swap >>owner ;
    
: visible-rect ( glass -- rect )
    [ visible-rect>> ] [ owner>> ] bi screen-loc offset-rect ;

M: glass layout*
    {
        [ gadget-child ]
        [ visible-rect ]
        [ gadget-child pref-dim ]
        [ find-world dim>> ]
    } cleave popup-loc >>loc prefer ;

M: glass ungraft* gadget-child hide-glass-hook ;

: add-glass ( glass world -- )
    dup hide-glass swap [ add-gadget ] [ >>glass ] bi drop ;

\ glass H{
    { T{ button-down } [ find-world [ hide-glass ] when* ] }
    { T{ drag } [ update-clicked drop ] }
} set-gestures

PRIVATE>

: show-glass ( owner child visible-rect -- )
    <glass>
    dup gadget-child hand-clicked set
    dup owner>> find-world add-glass ;