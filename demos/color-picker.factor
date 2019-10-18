! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: color-picker
USING: gadgets-sliders gadgets-labels gadgets models arrays
namespaces kernel math prettyprint sequences ;

! Simple example demonstrating the use of models.

: <color-slider> ( model -- gadget )
    <x-slider> 1 over set-slider-line ;

: <color-preview> ( model -- gadget )
    <gadget> { 100 100 } over set-rect-dim
    [ set-gadget-interior ] <control> ;

: <color-model> ( model -- model )
    [ [ 256 /f ] map 1 add <solid> ] <filter> ;

: <color-sliders> ( -- model gadget )
    3 [ drop 0 0 0 255 <range> ] map
    dup [ range-model ] map <compose>
    swap [ [ <color-slider> gadget, ] each ] make-filled-pile ;

: <color-picker> ( -- gadget )
    [
        <color-sliders> @top grid,
        dup <color-model> <color-preview> @center grid,
        [ unparse ] <filter> <label-control> @bottom grid,
    ] make-frame ;

PROVIDE: demos/color-picker ;

MAIN: demos/color-picker
    <color-picker> "Color Picker" open-window ;
