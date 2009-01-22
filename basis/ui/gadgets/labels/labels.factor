! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays hashtables io kernel math namespaces
make opengl sequences strings splitting ui.gadgets
ui.gadgets.tracks ui.gadgets.theme ui.render
ui.text colors models ;
IN: ui.gadgets.labels

! A label gadget draws a string.
TUPLE: label < gadget text font color ;

: label-string ( label -- string )
    text>> dup string? [ "\n" join ] unless ; inline

: set-label-string ( string label -- )
    [ CHAR: \n over memq? [ string-lines ] when ] dip (>>text) ; inline

: label-theme ( gadget -- gadget )
    sans-serif-font >>font
    black >>color ; inline

: new-label ( string class -- label )
    new-gadget
    [ set-label-string ] keep
    label-theme ; inline

: <label> ( string -- label )
    label new-label ;

M: label pref-dim*
    [ font>> ] [ text>> ] bi text-dim ;

M: label draw-gadget*
    [ color>> gl-color ]
    [ [ font>> ] [ text>> ] bi origin get draw-text ] bi ;

M: label gadget-text* label-string % ;

TUPLE: label-control < label ;

M: label-control model-changed
    swap value>> over set-label-string relayout ;

: <label-control> ( model -- gadget )
    "" label-control new-label
        swap >>model ;

: text-theme ( gadget -- gadget )
    black >>color
    monospace-font >>font ;

: reverse-video-theme ( label -- label )
    white >>color
    black solid-interior ;

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
