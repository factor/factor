! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-labels
USING: gadgets gadgets-layouts generic hashtables io kernel math
namespaces sdl sequences styles vectors ;

! A label gadget draws a string.
TUPLE: label text ;

C: label ( text -- label )
    <gadget> over set-delegate [ set-label-text ] keep ;

: label-size ( gadget text -- dim )
    >r gadget-font r> size-string 0 3vector ;

M: label pref-dim ( label -- dim )
    dup label-text label-size ;

M: label draw-gadget* ( label -- )
    dup delegate draw-gadget* dup label-text draw-string ;
