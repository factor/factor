! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl ;

! A label draws a text label, centered on the gadget's bounding
! box.
TUPLE: label text delegate ;

C: label ( text -- )
    0 0 0 0 <rectangle> <gadget> over set-label-delegate
    [ set-label-text ] keep ;

M: label layout* ( label -- )
    [
        dup label-text swap gadget-paint
        [ font get lookup-font ] bind
        swap size-string
    ] keep resize-gadget ;

M: label draw-shape ( label -- )
    dup shape-x x get +
    over shape-y y get +
    rot label-text
    >r font get lookup-font r>
    foreground get 3unlist make-color
    draw-string drop ;
