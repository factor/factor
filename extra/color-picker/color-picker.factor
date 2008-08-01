! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions math.parser models
       models.filter models.range models.compose sequences ui
       ui.gadgets ui.gadgets.frames ui.gadgets.labels ui.gadgets.packs
       ui.gadgets.sliders ui.render math.geometry.rect accessors
       ui.gadgets.grids colors ;
IN: color-picker

! Simple example demonstrating the use of models.

: <color-slider> ( model -- gadget )
    <x-slider> 1 over set-slider-line ;

TUPLE: color-preview < gadget ;

: <color-preview> ( model -- gadget )
    color-preview new-gadget
      swap        >>model
      { 100 100 } >>dim ;

M: color-preview model-changed
    swap model-value over set-gadget-interior relayout-1 ;

: <color-model> ( model -- model )
    [ [ 256 /f ] map 1 suffix first4 rgba boa <solid> ] <filter> ;

: <color-sliders> ( -- model gadget )
    3 [ 0 0 0 255 <range> ] replicate
    dup [ range-model ] map <compose>
    swap
    <filled-pile>
    swap
      [ <color-slider> add-gadget ] each ;

: <color-picker> ( -- gadget )
  <frame>
    <color-sliders>
      swap dup
      [                               @top    grid-add ]
      [ <color-model> <color-preview> @center grid-add ]
      [
        [ [ truncate number>string ] map " " join ] <filter> <label-control>
        @bottom grid-add
      ]
      tri* ;

: color-picker-window ( -- )
    [ <color-picker> "Color Picker" open-window ] with-ui ;

MAIN: color-picker-window
