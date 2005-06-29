! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables io kernel lists math namespaces sdl
sequences styles vectors ;

! A label gadget draws a string.
TUPLE: label text ;

C: label ( text -- label )
    <empty-gadget> over set-delegate [ set-label-text ] keep ;

: label-size ( gadget text -- w h )
    >r gadget-font r> size-string ;

M: label pref-dim ( label -- dim )
    dup label-text label-size 0 3vector ;

M: label draw-shape ( label -- )
    [ dup gadget-font swap label-text ] keep
    [ draw-string ] with-trans ;
