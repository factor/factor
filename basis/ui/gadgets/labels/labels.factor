! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays hashtables io kernel math math.functions
namespaces make opengl sequences strings splitting ui.gadgets
ui.gadgets.tracks ui.gadgets.packs fonts ui.render ui.pens.solid
ui.baseline-alignment ui.text colors colors.constants models
combinators opengl.gl ;
IN: ui.gadgets.labels

! A label gadget draws a string.
TUPLE: label < gadget text font ;

SLOT: string

M: label string>> ( label -- string )
    text>> dup string? [ "\n" join ] unless ; inline

<PRIVATE

PREDICATE: string-array < array [ string? ] all? ;

PRIVATE>

: ?string-lines ( string -- string/array )
    CHAR: \n over member-eq? [ string-lines ] when ;

ERROR: not-a-string object ;

M: label string<< ( string label -- )
    [
        {
            { [ dup string-array? ] [ ] }
            { [ dup string? ] [ ?string-lines ] }
            [ not-a-string ]
        } cond
    ] dip text<< ; inline

: label-theme ( gadget -- gadget )
    sans-serif-font >>font ; inline

: new-label ( string class -- label )
    new
    swap >>string
    label-theme ; inline

: <label> ( string -- label )
    label new-label ;

: >label< ( label -- font text )
    [ font>> ] [ text>> ] bi ; inline

M: label pref-dim*
    >label< text-dim ;

<PRIVATE

: label-metrics ( label -- metrics )
    >label< dup string? [ first ] unless line-metrics ;

PRIVATE>

M: label baseline
    label-metrics ascent>> round ;

M: label cap-height
    label-metrics cap-height>> round ;

M: label draw-gadget*
    >label<
    [
        background get [ font-with-background ] when*
        foreground get [ font-with-foreground ] when*
    ] dip
    draw-text ;

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
    COLOR: black <solid> >>interior ;

GENERIC: >label ( obj -- gadget )
M: string >label <label> ;
M: array >label <label> ;
M: object >label ;
M: f >label drop <gadget> ;

<PRIVATE

: label-on-left/right ( -- track )
    horizontal <track>
        0 >>fill
        +baseline+ >>align
        { 5 5 } >>gap ; inline
PRIVATE>

: label-on-left ( gadget label -- track )
    label-on-left/right
        swap >label f track-add
        swap 1 track-add ;

: label-on-right ( label gadget -- track )
    label-on-left/right
        swap f track-add
        swap >label 1 track-add ;
