! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays hashtables io kernel math namespaces
opengl sequences io.streams.lines strings splitting
ui.gadgets ui.gadgets.controls ui.gadgets.theme ui.render
colors ;
IN: ui.gadgets.labels

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

: label-theme ( gadget -- )
    black over set-label-color
    sans-serif-font swap set-label-font ;

: <label> ( string -- label )
    label construct-gadget
    [ set-label-string ] keep
    dup label-theme ;

M: label pref-dim*
    dup label-font open-font swap label-text text-dim ;

M: label draw-gadget*
    dup label-color gl-color
    dup label-font swap label-text origin get draw-text ;

M: label gadget-text* label-string % ;

: <label-control> ( model -- gadget )
    "" <label> [ set-label-string ] <control> ;

: text-theme ( gadget -- )
    black over set-label-color
    monospace-font swap set-label-font ;

: reverse-video-theme ( label -- )
    white over set-label-color
    black solid-interior ;
