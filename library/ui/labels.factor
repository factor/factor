! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-labels
USING: arrays freetype gadgets gadgets-layouts gadgets-theme
generic hashtables io kernel math namespaces opengl sequences
styles ;

! A label gadget draws a string.
TUPLE: label text font color ;

C: label ( text -- label )
    dup delegate>gadget
    [ set-label-text ] keep
    dup label-theme ;

: set-label-text* ( text label -- )
    2dup label-text =
    [ 2dup [ set-label-text ] keep relayout ] unless 2drop ;

: label-font* ( label -- font )
    label-font lookup-font ;

: label-size ( gadget text -- dim )
    dup label-font* dup font-height >r
    swap label-text string-width r> 0 3array ;

M: label pref-dim ( label -- dim )
    label-size ;

: draw-label ( label -- )
    dup label-color gl-color
    dup label-font* swap label-text draw-string ;

M: label draw-gadget* ( label -- ) draw-label ;

M: label set-message ( string/f label -- )
    set-label-text* ;
