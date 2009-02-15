! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences colors fonts ui.gadgets
ui.gadgets.frames ui.gadgets.grids ui.gadgets.icons ui.gadgets.labels
ui.gadgets.borders ui.pens.image ;
IN: ui.gadgets.labeled

TUPLE: labeled-gadget < frame content ;

<PRIVATE

: labeled-image ( name -- image )
    "labeled-block-" prepend theme-image ;

: labeled-icon ( name -- icon )
    labeled-image <icon> dup interior>> t >>fill? drop ;

CONSTANT: labeled-title-background
    T{ rgba f
        0.7843137254901961
        0.7686274509803922
        0.7176470588235294
        1.0
    }

: <labeled-title> ( gadget -- label )
    >label
    [ labeled-title-background font-with-background ] change-font
    { 0 2 } <border>
    "title-middle" labeled-image
    <image-pen> t >>fill? >>interior ;

: /-FOO-\ ( title labeled -- labeled )
    "title-left" labeled-icon @top-left grid-add
    swap <labeled-title> @top grid-add
    "title-right" labeled-icon @top-right grid-add ;

: |-----| ( gadget labeled -- labeled )
    "left-edge" labeled-icon @left grid-add
    swap [ >>content ] [ @center grid-add ] bi
    "right-edge" labeled-icon @right grid-add ;

: \-----/ ( labeled -- labeled )
    "bottom-left" labeled-icon @bottom-left grid-add
    "bottom-middle" labeled-icon @bottom grid-add
    "bottom-right" labeled-icon @bottom-right grid-add ;

M: labeled-gadget focusable-child* content>> ;

PRIVATE>

: <labeled-gadget> ( gadget title -- newgadget )
    labeled-gadget new-frame
        /-FOO-\
        |-----|
        \-----/ ;
