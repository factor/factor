! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-labels
USING: arrays freetype gadgets gadgets-theme
generic hashtables io kernel math namespaces opengl sequences
styles ;

! A label gadget draws a string.
TUPLE: label text font color ;

C: label ( text -- label )
    dup delegate>gadget
    [ set-label-text ] keep
    dup label-theme ;

M: label pref-dim*
    dup label-font lookup-font dup font-height >r
    swap label-text string-width r> 2array ;

M: label draw-gadget*
    dup label-color gl-color
    dup label-font swap label-text
    origin get draw-string ;

: <label-control> ( model -- gadget )
    "" <label> [ set-label-text ] <control> ;
