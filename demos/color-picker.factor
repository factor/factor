! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: color-picker
USING: gadgets-sliders gadgets-labels gadgets models arrays
namespaces kernel math prettyprint sequences ;

! Simple example demonstrating the use of models.

: <color-slider> ( -- gadget )
    <x-slider>
    1 over set-slider-line
    255 over set-slider-max ;

: <color-preview> ( model -- gadget )
    <gadget> { 100 100 } over set-rect-dim
    [ set-gadget-interior ] <control> ;

: <color-model> ( model -- model )
    [ [ 256 /f ] map 1 add <solid> ] <filter> ;

: <color-sliders> ( -- model gadget )
    [
        <color-slider> dup , control-model
        <color-slider> dup , control-model
        <color-slider> dup , control-model
        3array <compose>
    ] { } make make-pile 1 over set-pack-fill ;

: <color-picker> ( -- gadget )
    {
        { [ <color-sliders> ] f f @top }
        { [ dup <color-model> <color-preview> ] f f @center }
        { [ [ unparse ] <filter> <label-control> ] f f @bottom }
    } make-frame ;

PROVIDE: demos/color-picker ;

MAIN: demos/color-picker
    <color-picker> "Color Picker" open-titled-window ;
