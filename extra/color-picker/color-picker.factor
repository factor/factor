! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions math.parser models
models.arrow models.range models.product sequences ui
ui.gadgets ui.gadgets.frames ui.gadgets.labels ui.gadgets.packs
ui.gadgets.sliders ui.render math.rectangles accessors
ui.gadgets.grids colors ;
IN: color-picker

! Simple example demonstrating the use of models.

TUPLE: color-preview < gadget ;

: <color-preview> ( model -- gadget )
    color-preview new-gadget
        swap >>model
        { 100 100 } >>dim ;

M: color-preview model-changed
    swap value>> >>interior relayout-1 ;

: <color-model> ( model -- model )
    [ first3 [ 256 /f ] tri@ 1 <rgba> <solid> ] <arrow> ;

: <color-slider> ( model -- gadget )
    horizontal <slider> 1 >>line ;

: <color-sliders> ( -- gadget model )
    3 [ 0 0 0 255 <range> ] replicate
    [ <filled-pile> { 5 5 } >>gap [ <color-slider> add-gadget ] reduce ]
    [ [ range-model ] map <product> ]
    bi ;

: <color-picker> ( -- gadget )
    <frame>
        { 5 5 } >>gap
        <color-sliders>
        [ @top grid-add ]
        [
            [ <color-model> <color-preview> @center grid-add ]
            [
                [ [ truncate number>string ] map " " join ]
                <arrow> <label-control>
                @bottom grid-add
            ] bi
        ] bi* ;

: color-picker-window ( -- )
    [ <color-picker> "Color Picker" open-window ] with-ui ;

MAIN: color-picker-window
