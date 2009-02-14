! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences colors fonts ui.gadgets
ui.gadgets.frames ui.gadgets.grids ui.gadgets.icons ui.gadgets.labels
ui.gadgets.theme ui.gadgets.borders ui.pens.image ;
IN: ui.gadgets.labelled

TUPLE: labelled-gadget < frame content ;

<PRIVATE

: labelled-image ( name -- image )
    "labeled-block-" prepend theme-image ;

: labelled-icon ( name -- icon )
    labelled-image <icon> dup interior>> t >>fill? drop ;


CONSTANT: labelled-title-background
    T{ rgba f
        0.7843137254901961
        0.7686274509803922
        0.7176470588235294
        1.0
    }

: <labelled-title> ( gadget -- label )
    >label
    [ labelled-title-background font-with-background ] change-font
    { 0 2 } <border>
    "title-middle" labelled-image
    <image-pen> t >>fill? >>interior ;

: /-FOO-\ ( title labelled -- labelled )
    "title-left" labelled-icon @top-left grid-add
    swap <labelled-title> @top grid-add
    "title-right" labelled-icon @top-right grid-add ;

: |-----| ( gadget labelled -- labelled )
    "left-edge" labelled-icon @left grid-add
    swap [ >>content ] [ @center grid-add ] bi
    "right-edge" labelled-icon @right grid-add ;

: \-----/ ( labelled -- labelled )
    "bottom-left" labelled-icon @bottom-left grid-add
    "bottom-middle" labelled-icon @bottom grid-add
    "bottom-right" labelled-icon @bottom-right grid-add ;

M: labelled-gadget focusable-child* content>> ;

PRIVATE>

: <labelled-gadget> ( gadget title -- newgadget )
    labelled-gadget new-frame
        /-FOO-\
        |-----|
        \-----/ ;
