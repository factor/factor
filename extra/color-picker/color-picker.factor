! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors formatting kernel math math.functions
math.vectors models models.arrow models.product models.range sequences
ui ui.gadgets ui.gadgets.labels ui.gadgets.packs ui.gadgets.sliders
ui.gadgets.tracks ui.pens.solid ;
IN: color-picker

! Simple example demonstrating the use of models.

TUPLE: color-preview < gadget ;

: <color-preview> ( model -- gadget )
    color-preview new
        swap >>model
        { 200 200 } >>dim ;

M: color-preview model-changed
    swap value>> >>interior relayout-1 ;

: <color-model> ( model -- model )
    [ first3 [ 256 /f ] tri@ 1 <rgba> <solid> ] <arrow> ;

: <color-slider> ( model -- gadget )
    horizontal <slider> 1 >>line ;

: <color-sliders> ( -- gadget model )
    3 [ 0 0 0 255 1 <range> ] replicate
    [ <filled-pile> { 5 5 } >>gap [ <color-slider> add-gadget ] reduce ]
    [ [ range-model ] map <product> ]
    bi ;

: color>str ( seq -- str )
    vtruncate v>integer first3 3dup "%d %d %d #%02x%02x%02x" sprintf ;

: <color-picker> ( -- gadget )
    vertical <track> { 5 5 } >>gap
    <color-sliders>
    [ f track-add ]
    [
        [ <color-model> <color-preview> 1 track-add ]
        [ [ color>str ] <arrow> <label-control> f track-add ] bi
    ] bi* ;

MAIN-WINDOW: color-picker-window { { title "Color Picker" } }
    <color-picker> >>gadgets ;
