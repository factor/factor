! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl sdl-ttf ;

! A label draws a text label, centered on the gadget's bounding
! box.
TUPLE: label text delegate ;

C: label ( text -- )
    <empty-gadget> over set-label-delegate
    [ set-label-text ] keep ;

M: label layout* ( label -- )
    [ label-text dup shape-w swap shape-h ] keep resize-gadget ;

: label-x ( label -- x )
    dup shape-w swap label-text shape-w - 2 /i ;

: label-y ( label -- y )
    shape-h font get lookup-font TTF_FontHeight - 2 /i ;

M: label draw-shape ( label -- )
    dup label-x over label-y rect> over shape-pos +
    [ label-text draw-shape ] with-trans ;
