! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl sdl-ttf stdio ;

! A label gadget draws a string.
TUPLE: label text delegate ;

C: label ( text -- )
    <empty-gadget> over set-label-delegate
    [ set-label-text ] keep ;

: update-rollover ( gadget -- )
    dup dup my-hand hand-gadget child?
    rollover? set-paint-property redraw ;

: <roll-label> ( text -- )
    #! A label that shows an outline when the mouse is over it.
    <label> 0 0 0 0 <roll-rect> <gadget> over set-label-delegate
    dup [ update-rollover ] [ mouse-enter ] set-action
    dup [ update-rollover ] [ mouse-leave ] set-action ;

M: label layout* ( label -- )
    [ label-text dup shape-w swap shape-h ] keep resize-gadget ;

M: label draw-shape ( label -- )
    dup label-delegate draw-shape
    dup shape-pos [ label-text draw-shape ] with-trans ;
