! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays hashtables io kernel math namespaces
opengl sequences io.streams.lines strings splitting
ui.gadgets ui.gadgets.tracks ui.gadgets.theme ui.render colors ;
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

TUPLE: label-control ;

M: label-control model-changed
    dup control-value over set-label-text relayout ;

: <label-control> ( model -- gadget )
    "" <label> label-control construct-control ;

: text-theme ( gadget -- )
    black over set-label-color
    monospace-font swap set-label-font ;

: reverse-video-theme ( label -- )
    white over set-label-color
    black solid-interior ;

GENERIC: >label ( obj -- gadget )
M: string >label <label> ;
M: array >label <label> ;
M: object >label ;
M: f >label drop <gadget> ;

: label-on-left ( gadget label -- button )
    [ >label f track, 1 track, ] { 1 0 } make-track ;

: label-on-right ( label gadget -- button )
    [ f track, >label 1 track, ] { 1 0 } make-track ;
