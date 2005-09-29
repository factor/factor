! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-labels
USING: arrays gadgets gadgets-layouts generic hashtables io
kernel math namespaces sdl sequences styles ;

! A label gadget draws a string.
TUPLE: label text ;

C: label ( text -- label )
    dup gadget-delegate [ set-label-text ] keep ;

: label-size ( gadget text -- dim )
    >r gadget-font r> size-string 0 3array ;

M: label pref-dim ( label -- dim )
    dup label-text label-size ;

M: label draw-gadget* ( label -- )
    dup delegate draw-gadget* dup label-text draw-string ;
