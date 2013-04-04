! Copyright (C) 2008 Eduardo Cavazos.
! Copyright (C) 2011 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays boids.simulation calendar classes kernel
literals locals math math.functions math.trig models namespaces
opengl opengl.demo-support opengl.gl sequences threads ui
ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.frames ui.gadgets.grids ui.gadgets.labeled
ui.gadgets.labels ui.gadgets.packs ui.gadgets.sliders ui.render ;
QUALIFIED-WITH: models.range mr
IN: boids

TUPLE: boids-gadget < gadget paused boids behaviours dt ;

CONSTANT: initial-population 100
CONSTANT: initial-dt 5

: initial-behaviours ( -- seq )
    1.0 75 -0.1 <cohesion>
    1.0 40 -0.5 <alignment>
    1.0 25 -1.0 <separation>
    3array ;

: <boids-gadget> ( -- gadget )
    boids-gadget new
        t >>clipped?
        ${ width height } >>pref-dim
        initial-population random-boids >>boids
        initial-behaviours >>behaviours
        initial-dt >>dt ;

M:  boids-gadget ungraft*
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

M:: boids-gadget draw-gadget* ( boids-gadget -- )
    origin get
    [ boids-gadget boids>> draw-boids ] with-translation ;

: iterate-system ( boids-gadget -- )
    dup [ boids>> ] [ behaviours>> ] [ dt>> ] tri
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
    2 3 <frame> { 2 4 } >>gap { 0 0 } >>filled-cell

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

    behavior class-of name>> <labeled-gadget> ;

:: set-population ( n boids-gadget -- )
    boids-gadget [
        dup length n - dup 0 >
        [ head* ]
        [ neg random-boids append ] if
    ] change-boids drop ;

: pause-toggle ( boids-gadget -- )
    dup paused>> not [ >>paused ] keep
    [ drop ] [ start-boids-thread ] if ;

: randomize-boids ( boids-gadget -- )
    [ length random-boids ] change-boids drop ;

:: simulation-panel ( boids-gadget -- gadget )
    <pile> { 2 2 } >>gap

    2 2 <frame> { 4 4 } >>gap { 0 0 } >>filled-cell

    "population" <label> { 0 0 } grid-add
    initial-population 0 0 200 10 mr:<range>
    dup [ boids-gadget set-population ] connect
    horizontal <slider> { 1 0 } grid-add

    "speed" <label> { 0 1 } grid-add
    boids-gadget dt>> 0 1 10 1 mr:<range>
    dup [ boids-gadget dt<< ] connect
    horizontal <slider> { 1 1 } grid-add

    add-gadget

    <shelf> { 2 2 } >>gap
    "pause" [ drop boids-gadget pause-toggle ]
    <border-button> add-gadget
    "randomize" [ drop boids-gadget randomize-boids ]
    <border-button> add-gadget

    add-gadget

    "simulation" <labeled-gadget> ;

:: create-gadgets ( -- gadgets )
    <shelf>
    <boids-gadget> :> boids-gadget
    boids-gadget [ start-boids-thread ] keep
    add-gadget

    <pile> { 2 2 } >>gap 1.0 >>fill

    boids-gadget simulation-panel
    add-gadget 

    boids-gadget behaviours>>
    [ behavior-panel add-gadget ] each

    add-gadget
    { 2 2 } <border> ;

MAIN-WINDOW: boids { { title "Boids" } }
    create-gadgets
    >>gadgets ;

