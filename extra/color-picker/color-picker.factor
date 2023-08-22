! Copyright (C) 2006, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors classes.tuple colors colors.cmyk colors.gray
colors.hsl colors.hsv colors.hwb colors.ryb colors.xyy
colors.xyz colors.yiq colors.yuv formatting inverse kernel math
math.functions models models.arrow models.product models.range
sequences splitting ui ui.gadgets ui.gadgets.borders
ui.gadgets.labels ui.gadgets.packs ui.gadgets.sliders
ui.gadgets.tabbed ui.gadgets.tracks ui.pens.solid
ui.tools.common ;

IN: color-picker

! Simple example demonstrating the use of models.

TUPLE: color-preview < gadget ;

: <color-preview> ( model -- gadget )
    color-preview new
        swap >>model
        { 300 300 } >>dim ;

M: color-preview model-changed
    swap value>> <solid> >>interior relayout-1 ;

: <color-model> ( model class -- model )
    '[ [ 255 /f ] map 1.0 suffix _ slots>tuple ] <arrow> ;

: <color-slider> ( model -- gadget )
    horizontal <slider> 1 >>line ;

: <color-range> ( -- range )
    0 0 0 255 1 <range> ;

: <color-label> ( text -- label )
    [ <label> dup font>> ] [ ?named-color [ >>foreground ] when* drop ] bi ;

:: <color-sliders> ( constructor -- gadget model )
    constructor def>> first ?wrapped :> color-class
    color-class all-slots [ name>> ] map but-last :> slot-names
    slot-names length [ <color-range> ] replicate
    [
        slot-names <filled-pile> { 5 5 } >>gap [
            [ <color-slider> ]
            [ <color-label> label-on-left add-gadget ] bi*
        ] 2reduce
    ]
    [ [ range-model ] map <product> color-class <color-model> ] bi ;

: color>string ( color -- str )
    >rgba-components drop [ 255 * round >integer ] tri@
    3dup "%d %d %d #%02x%02x%02x" sprintf ;

: <color-status> ( model -- gadget )
    [ color>string ] <arrow> <label-control> ;

: <color-picker> ( constructor -- gadget )
    vertical <track> { 5 5 } >>gap
    swap <color-sliders> [ f track-add ] dip
    [ <color-preview> 1 track-add ]
    [ <color-status> f track-add ] bi ;

:: <color-tabs> ( quot: ( constructor -- gadget ) -- gadget )
    <tabbed-gadget> {
        <rgba>
        <hsla>
        <hsva>
        <hwba>
        <ryba>
        <cmyka>
        <gray>
        <xyza>
        <xyYa>
        <yiqa>
        <yuva>
    } [
        quot [ name>> "<" ?head drop ">" ?tail drop add-tab ] bi
    ] each ; inline

: <color-pickers> ( -- gadget )
    [ <color-picker> ] <color-tabs> ;

MAIN-WINDOW: color-picker-window
    { { title "Color Picker" } }
    <color-pickers> >>gadgets ;
