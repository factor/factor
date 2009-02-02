! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays hashtables io kernel math namespaces
make opengl sequences strings splitting ui.gadgets
ui.gadgets.tracks fonts ui.render
ui.text colors models ;
IN: ui.gadgets.labels

! A label gadget draws a string.
TUPLE: label < gadget text font ;

SLOT: string

M: label string>> ( label -- string )
    text>> dup string? [ "\n" join ] unless ; inline

M: label (>>string) ( string label -- )
    [ CHAR: \n over memq? [ string-lines ] when ] dip (>>text) ; inline

: label-theme ( gadget -- gadget )
    sans-serif-font >>font ; inline

: new-label ( string class -- label )
    new-gadget
    swap >>string
    label-theme ; inline

: <label> ( string -- label )
    label new-label ;

: >label< ( label -- font text )
    [ font>> ] [ text>> ] bi ;

M: label pref-dim*
    >label< text-dim ;

M: label baseline
    >label< line-metrics ascent>> ;

M: label draw-gadget*
    >label< origin get draw-text ;

M: label gadget-text* string>> % ;

TUPLE: label-control < label ;

M: label-control model-changed
    swap value>> >>string relayout ;

: <label-control> ( model -- gadget )
    "" label-control new-label
        swap >>model ;

: text-theme ( gadget -- gadget )
    monospace-font >>font ;

: reverse-video-theme ( label -- label )
    sans-serif-font reverse-video-font >>font
    black <solid> >>interior ;

GENERIC: >label ( obj -- gadget )
M: string >label <label> ;
M: array >label <label> ;
M: object >label ;
M: f >label drop <gadget> ;

: label-on-left ( gadget label -- button )
    { 1 0 } <track>
        swap >label f track-add
        swap 1 track-add ;

: label-on-right ( label gadget -- button )
    { 1 0 } <track>
        swap f track-add
        swap >label 1 track-add ;
