! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-labels
USING: arrays freetype gadgets gadgets-theme
generic hashtables io kernel math namespaces opengl sequences
styles strings ;

! A label gadget draws a string.
TUPLE: label text font color ;

: label-string ( label -- string )
    label-text dup string? [ "\n" join ] unless ; inline

: set-label-string ( string label -- )
    CHAR: \n pick memq? [
        >r string-lines r> set-label-text
    ] [
        set-label-text
    ] if ; inline

C: label ( string -- label )
    dup delegate>gadget
    [ set-label-string ] keep
    dup label-theme ;

M: label pref-dim*
    dup label-font open-font swap label-text text-dim ;

M: label draw-gadget*
    dup label-color gl-color
    dup label-font swap label-text origin get draw-text ;

: <label-control> ( model -- gadget )
    "" <label> [ set-label-string ] <control> ;
