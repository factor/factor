! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions math.parser models sequences
ui ui.gadgets ui.gadgets.frames
ui.gadgets.labels ui.gadgets.packs ui.gadgets.sliders ui.render
;
IN: color-picker

! Simple example demonstrating the use of models.

: <color-slider> ( model -- gadget )
    <x-slider> 1 over set-slider-line ;

TUPLE: color-preview ;

: <color-preview> ( model -- gadget )
    <gadget> color-preview construct-control
    { 100 100 } over set-rect-dim ;

M: color-preview model-changed
    swap model-value over set-gadget-interior relayout-1 ;

: <color-model> ( model -- model )
    [ [ 256 /f ] map 1 add <solid> ] <filter> ;

: <color-sliders> ( -- model gadget )
    3 [ drop 0 0 0 255 <range> ] map
    dup [ range-model ] map <compose>
    swap [ [ <color-slider> gadget, ] each ] make-filled-pile ;

: <color-picker> ( -- gadget )
    [
        <color-sliders> @top frame,
        dup <color-model> <color-preview> @center frame,
        [ [ truncate number>string ] map " " join ] <filter>
        <label-control> @bottom frame,
    ] make-frame ;

: color-picker-window ( -- )
    [ <color-picker> "Color Picker" open-window ] with-ui ;

MAIN: color-picker-window
