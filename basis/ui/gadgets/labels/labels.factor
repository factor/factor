! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes colors.constants combinators
fonts fry kernel make math.functions models namespaces sequences
splitting strings ui.baseline-alignment ui.gadgets
ui.gadgets.tracks ui.pens.solid ui.render ui.text
ui.theme.images ;
IN: ui.gadgets.labels

! A label gadget draws a string.
TUPLE: label < aligned-gadget text font ;

SLOT: string

M: label string>> ( label -- string )
    text>> dup string? [ "\n" join ] unless ; inline

<PRIVATE

PREDICATE: string-array < array [ string? ] all? ;

PRIVATE>

: ?string-lines ( string -- string/array )
    CHAR: \n over member-eq? [ string-lines ] when ;

M: label string<< ( string label -- )
    [
        dup string-array? [
            string check-instance ?string-lines
        ] unless
    ] dip [ text<< ] [ relayout ] bi ; inline

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

M: label baseline*
    label-metrics ascent>> ;

M: label cap-height*
    label-metrics cap-height>> ;

<PRIVATE

: label-background ( label -- color )
    gadget-background [ background get ] unless* ; inline

: label-foreground ( label -- color )
    gadget-foreground [ foreground get ] unless* ; inline

PRIVATE>

M: label draw-gadget*
    [ >label< ] keep
    [ label-background [ font-with-background ] when* ]
    [ label-foreground [ font-with-foreground ] when* ]
    bi-curry compose dip draw-text ;

M: label gadget-text* string>> % ;

TUPLE: label-control < label ;

M: label-control model-changed
    [ value>> ] [ string<< ] bi* ;

: <label-control> ( model -- gadget )
    "" label-control new-label
        swap >>model ;

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
