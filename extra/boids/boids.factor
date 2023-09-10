! Copyright (C) 2008 Eduardo Cavazos.
! Copyright (C) 2011 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays boids.simulation calendar classes colors
kernel literals math math.functions models
models.range opengl opengl.demo-support opengl.gl sequences
threads ui ui.commands ui.gadgets ui.gadgets.borders
ui.gadgets.buttons ui.gadgets.frames ui.gadgets.grids
ui.gadgets.labeled ui.gadgets.labels ui.gadgets.packs
ui.gadgets.sliders ui.render ui.tools.common ;

QUALIFIED-WITH: models.range mr
IN: boids

TUPLE: boids-gadget < gadget paused boids behaviors dt ;

CONSTANT: initial-population 100
CONSTANT: initial-dt 5

: initial-behaviors ( -- seq )
    1.0 75 -0.1 <cohesion>
    1.0 40 -0.5 <alignment>
    1.0 25 -1.0 <separation>
    3array ;

: <boids-gadget> ( -- gadget )
    boids-gadget new
        t >>clipped?
        ${ WIDTH HEIGHT } >>pref-dim
        initial-population random-boids >>boids
        initial-behaviors >>behaviors
        initial-dt >>dt ;

M: boids-gadget ungraft*
    t >>paused drop ;

: vec>deg ( vec -- deg )
    first2 rect> arg rad>deg ; inline

: draw-boid ( boid -- )
    dup pos>> [
        vel>> vec>deg 0 0 1 glRotated
        GL_TRIANGLES [
            -6.0  4.0 glVertex2f
            -6.0 -4.0 glVertex2f
            8.0 0.0 glVertex2f
        ] do-state
    ] with-translation ;

: draw-boids ( boids -- )
    0.0 0.0 0.0 0.5 glColor4f
    [ draw-boid ] each ;

M: boids-gadget draw-gadget* ( boids-gadget -- )
    boids>> draw-boids ;

: iterate-system ( boids-gadget -- )
    dup [ boids>> ] [ behaviors>> ] [ dt>> ] tri
    simulate >>boids drop ;

:: start-boids-thread ( gadget -- )
    [
        [ gadget paused>> ]
        [
            gadget iterate-system
            gadget relayout-1
            10 milliseconds sleep
        ] until
    ] in-thread ;

TUPLE: range-observer quot ;

M: range-observer model-changed
    [ range-value ] dip quot>> call( value -- ) ;

: connect ( range-model quot -- )
    range-observer boa swap add-connection ;

:: behavior-panel ( behavior -- gadget )
    2 3 <frame> white-interior { 2 4 } >>gap { 0 0 } >>filled-cell

    "weight" <label> { 0 0 } grid-add
    behavior weight>> 100 * >fixnum 0 0 200 1 mr:<range>
    dup [ 100.0 / behavior weight<< ] connect
    horizontal <slider> { 1 0 } grid-add

    "radius" <label> { 0 1 } grid-add
    behavior radius>> 0 0 100 1 mr:<range>
    dup [ behavior radius<< ] connect
    horizontal <slider> { 1 1 } grid-add

    "angle" <label> { 0 2 } grid-add
    behavior angle-cos>> acos rad>deg >fixnum 0 0 180 1 mr:<range>
    dup [ deg>rad cos behavior angle-cos<< ] connect
    horizontal <slider> { 1 2 } grid-add

    { 5 5 } <border> white-interior

    behavior class-of name>> COLOR: gray <framed-labeled-gadget> ;

:: set-population ( n boids-gadget -- )
    boids-gadget [
        dup length n - dup 0 >
        [ head* ]
        [ neg random-boids append ] if
    ] change-boids drop ;

<PRIVATE
: find-boids-gadget ( gadget -- boids-gadget )
    dup boids-gadget? [ children>> [ boids-gadget? ] find nip ] unless ;
PRIVATE>

: com-pause ( boids-gadget -- )
    find-boids-gadget
    dup paused>> not [ >>paused ] keep
    [ drop ] [ start-boids-thread ] if ;

: com-randomize ( boids-gadget -- )
    find-boids-gadget
    [ length random-boids ] change-boids relayout-1 ;

:: simulation-panel ( boids-gadget -- gadget )
    <pile> white-interior

    2 2 <frame> { 2 4 } >>gap { 0 0 } >>filled-cell

    "population" <label> { 0 0 } grid-add
    initial-population 0 0 200 10 mr:<range>
    dup [ boids-gadget set-population ] connect
    horizontal <slider> { 1 0 } grid-add

    "speed" <label> { 0 1 } grid-add
    boids-gadget dt>> 0 1 10 1 mr:<range>
    dup [ boids-gadget dt<< ] connect
    horizontal <slider> { 1 1 } grid-add

    { 5 5 } <border> add-gadget

    <shelf> { 2 2 } >>gap
    "pause" [ drop boids-gadget com-pause ]
    <border-button> add-gadget
    "randomize" [ drop boids-gadget com-randomize ]
    <border-button> add-gadget

    { 5 5 } <border> add-gadget

    "simulation" COLOR: gray <framed-labeled-gadget> ;

TUPLE: boids-frame < pack ;

:: <boids-frame> ( -- boids-frame )
    boids-frame new horizontal >>orientation
    <boids-gadget> :> boids-gadget
    boids-gadget [ start-boids-thread ] keep
    add-gadget

    <pile> { 5 5 } >>gap 1.0 >>fill

    boids-gadget simulation-panel
    add-gadget

    boids-gadget behaviors>>
    [ behavior-panel add-gadget ] each

    { 5 5 } <border> add-gadget ;

boids-frame "touchbar" f {
    { f com-pause }
    { f com-randomize }
} define-command-map

MAIN-WINDOW: boids { { title "Boids" } }
    <boids-frame> >>gadgets ;
