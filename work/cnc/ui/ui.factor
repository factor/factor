! File: cnc.ui
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2023 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays boids.simulation calendar classes colors
kernel literals math math.functions math.trig models
models.range opengl opengl.demo-support opengl.gl sequences
threads ui ui.commands ui.gadgets ui.gadgets.borders
ui.gadgets.buttons ui.gadgets.frames ui.gadgets.grids
ui.gadgets.labeled ui.gadgets.labels ui.gadgets.packs
ui.gadgets.sliders ui.render ui.tools.common fonts
cnc.tools ; 

QUALIFIED-WITH: models.range mr
IN: cnc.ui

SYMBOLS: job-x job-y job-bit job-speed job-feed job-depth job-step ; 

TUPLE: cnc-gadget < gadget xmax ymax bit speed feed depth step ;

CONSTANT: initial-feed 1000
CONSTANT: initial-speed 10000
CONSTANT: initial-bit 25.4
CONSTANT: initial-depth 0.5
CONSTANT: initial-step 60

: <cnc-gadget> ( -- gadget )
    cnc-gadget new
    t >>clipped?
    ${ WIDTH HEIGHT } >>pref-dim
;

: <12-point-label-control> ( model -- gadget )
    <label-control> sans-serif-font 12 >>size >>font ;

TUPLE: range-observer quot ;

M: range-observer model-changed
    [ range-value ] dip quot>> call( value -- ) ;

: connect ( range-model quot -- )
    range-observer boa swap add-connection ;

<PRIVATE
: find-cnc-gadget ( gadget -- cnc-gadget )
    dup cnc-gadget? [ children>> [ cnc-gadget? ] find nip ] unless ;
PRIVATE>

:: cnc-panel ( cnc-gadget -- gadget )
    <pile> white-interior
    2 2 <frame> { 2 4 } >>gap { 0 0 } >>filled-cell

    ! toolpath model 
    "speed" <label> { 0 0 } grid-add
    initial-speed 0 0 200 10 mr:<range>
    horizontal <slider> { 1 0 } grid-add

    "feed" <label> { 0 1 } grid-add
    cnc-gadget feed>> 0 1 10 1 mr:<range>
    dup [ cnc-gadget feed>> ] connect
    horizontal <slider> { 1 1 } grid-add

    { 5 5 } <border> add-gadget

    <shelf> { 2 2 } >>gap
    "button2" [ B ] 
    <border-button> add-gadget

    { 5 5 } <border> add-gadget

    "cnc" COLOR: gray <framed-labeled-gadget> ;

TUPLE: cnc-frame < pack ;

: <cnc-frame> ( -- cnc-frame )
    cnc-frame new  horizontal >>orientation
    <cnc-gadget>
    cnc-panel  { 5 5 } <border> add-gadget 
    ;


MAIN-WINDOW: cnc { { title "CNC" } }
    <cnc-frame> >>gadgets ;
