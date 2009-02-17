! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces ui.gadgets ui.gadgets.worlds
ui.gadgets.wrappers ui.gestures math.rectangles
math.rectangles.positioning combinators ;
IN: ui.gadgets.glass

GENERIC: hide-glass-hook ( gadget -- )

M: gadget hide-glass-hook drop ;

<PRIVATE

TUPLE: glass < gadget visible-rect owner ;

: <glass> ( owner child visible-rect -- glass )
    glass new
        swap >>visible-rect
        swap add-gadget
        swap >>owner ;
    
: visible-rect ( glass -- rect )
    [ visible-rect>> ] [ owner>> ] bi screen-loc offset-rect ;

M: glass layout*
    [
        [ visible-rect ]
        [ gadget-child pref-dim ]
        [ find-world dim>> ]
        tri popup-rect
    ] [ gadget-child ] bi set-rect-bounds ;

M: glass ungraft* gadget-child hide-glass-hook ;

: (hide-glass) ( gadget -- )
    [ [ unparent ] when* f ] change-glass drop ;

: add-glass ( glass world -- )
    dup (hide-glass) swap [ add-gadget ] [ >>glass ] bi drop ;

PRIVATE>

: hide-glass ( child -- )
    find-world [ [ (hide-glass) ] [ request-focus ] bi ] when* ;

: show-glass ( owner child visible-rect -- )
    <glass>
    dup gadget-child hand-clicked set
    dup owner>> find-world add-glass ;

\ glass H{
    { T{ button-down } [ hide-glass ] }
    { T{ drag } [ update-clicked drop ] }
} set-gestures

SLOT: popup

<PRIVATE

TUPLE: popup < wrapper owner ;

: <popup> ( owner gadget -- popup )
    popup new-wrapper
        swap >>owner ; inline

M: popup hide-glass-hook
    owner>> f >>popup request-focus ;

PRIVATE>

popup H{
    { T{ key-down f f "ESC" } [ hide-glass ] }
} set-gestures

: pass-to-popup ( gesture interactor -- ? )
    popup>> focusable-child resend-gesture ;

: show-popup ( owner popup visible-rect -- )
    [ <popup> ] dip
    [ drop dup owner>> (>>popup) ]
    [ [ [ owner>> ] keep ] dip show-glass ]
    2bi ;