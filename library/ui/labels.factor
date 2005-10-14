! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-labels
USING: arrays freetype gadgets gadgets-layouts generic
hashtables io kernel math namespaces sequences styles ;

! A label gadget draws a string.
TUPLE: label text ;

C: label ( text -- label )
    dup delegate>gadget [ set-label-text ] keep ;

: set-label-text* ( text label -- )
    2dup label-text =
    [ 2dup [ set-label-text ] keep relayout ] unless 2drop ;

: label-size ( gadget text -- dim )
    dup gadget-font swap label-text string-size 0 3array ;

M: label pref-dim ( label -- dim )
    label-size ;

: draw-label ( label -- )
    dup label-text swap gadget-font draw-string ;

M: label draw-gadget* ( label -- )
    dup delegate draw-gadget* draw-label ;

M: label set-message ( string/f label -- )
    set-label-text* ;
