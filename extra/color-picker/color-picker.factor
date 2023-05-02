! Copyright (C) 2006, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors classes.tuple colors colors.hsl colors.hsv
colors.hwb colors.ryb colors.xyy colors.xyz colors.yiq
colors.yuv formatting inverse kernel math math.functions models
models.arrow models.product models.range quotations sequences
splitting ui ui.gadgets ui.gadgets.borders ui.gadgets.labels
ui.gadgets.packs ui.gadgets.sliders ui.gadgets.tabbed
ui.gadgets.tracks ui.pens.solid ui.tools.common ;

IN: color-picker

! Simple example demonstrating the use of models.

TUPLE: color-preview < gadget ;

: <color-preview> ( model -- gadget )
    color-preview new
        swap >>model
        { 300 300 } >>dim ;

M: color-preview model-changed
    swap value>> <solid> >>interior relayout-1 ;

: <color-model> ( model constructor -- model )
    1quotation '[ first3 [ 255 /f ] tri@ 1.0 @ ] <arrow> ;

: <color-slider> ( model -- gadget )
    horizontal <slider> 1 >>line ;

: <color-range> ( -- range )
    0 0 0 255 1 <range> ;

: <color-label> ( text -- label )
    [ <label> dup font>> ] [ ?named-color [ >>foreground ] when* drop ] bi ;

:: <color-sliders> ( constructor -- gadget model )
    constructor def>> [ length 2 - ] [ ?nth ] bi
    ?wrapped all-slots but-last [ name>> ] map
    [ length [ <color-range> ] replicate ] keep
    '[
        _ <filled-pile> { 5 5 } >>gap [
            [ <color-slider> ]
            [ <color-label> label-on-left add-gadget ] bi*
        ] 2reduce
    ]
    [ [ range-model ] map <product> constructor <color-model> ] bi ;

: color>string ( color -- str )
    >rgba-components drop [ 255 * round >integer ] tri@
    3dup "%d %d %d #%02x%02x%02x" sprintf ;

: <color-status> ( model -- gadget )
    [ color>string ] <arrow> <label-control> ;

: <color-picker> ( constructor -- gadget )
    vertical <track> white-interior { 5 5 } >>gap
    swap <color-sliders> [ f track-add ] dip
    [ <color-preview> 1 track-add ]
    [ <color-status> f track-add ] bi ;

: <color-pickers> ( -- gadget )
    <tabbed-gadget> {
        <rgba>
        <hwba>
        <xyza>
        <xyYa>
        ! <laba>
        ! <luva>
        ! <cmyka>
        <hsla>
        <hsva>
        <hwba>
        <ryba>
        <yiqa>
        <yuva>
        ! <gray>

    } [
        [ <color-picker> ]
        [ name>> "<" ?head drop ">" ?tail drop add-tab ] bi
    ] each ;

MAIN-WINDOW: color-picker-window { { title "Color Picker" } }
    <color-pickers> { 5 5 } <border> >>gadgets ;
