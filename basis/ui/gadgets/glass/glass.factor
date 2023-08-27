! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math.rectangles
math.rectangles.positioning math.vectors namespaces ui.gadgets
ui.gadgets.viewports ui.gadgets.worlds ui.gadgets.wrappers
ui.gestures vectors ;
FROM: ui.gadgets.wrappers => wrapper ;
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
    [ visible-rect>> ] [ owner>> ] bi
    [ screen-loc ] [ [ viewport? ] find-parent [ screen-loc vmax ] when* ] bi
    offset-rect ;

M: glass layout*
    [
        [ visible-rect ]
        [ gadget-child pref-dim ]
        [ find-world dim>> ]
        tri popup-rect
    ] [ gadget-child ] bi set-rect-bounds ;

M: glass ungraft* gadget-child hide-glass-hook ;

: add-glass ( glass world -- )
    [ swap add-gadget drop ] [ [ ?push ] change-layers drop ] 2bi ;

PRIVATE>

: hide-glass ( child -- )
    [ glass? ] find-parent
    [ dup find-world [ unparent ] dip request-focus ]
    when* ;

: show-glass ( owner child visible-rect -- )
    <glass>
    dup gadget-child hand-clicked set-global
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
    dup owner>> 2dup popup>> eq?
    [ f >>popup request-focus drop ] [ 2drop ] if ;

PRIVATE>

popup H{
    { T{ key-down f f "ESC" } [ hide-glass ] }
} set-gestures

: pass-to-popup ( gesture owner -- ? )
    popup>> focusable-child resend-gesture ;

: show-popup ( owner popup visible-rect -- )
    [ [ dup dup popup>> [ hide-glass ] when* ] dip <popup> ] dip
    [ drop >>popup drop ] [ show-glass ] 3bi ;
