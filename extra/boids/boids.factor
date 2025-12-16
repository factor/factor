! Copyright (C) 2008 Eduardo Cavazos.
! Copyright (C) 2011 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays boids.simulation calendar classes colors
kernel literals math math.functions math.vectors models
models.range namespaces opengl opengl.demo-support opengl.gl sequences
threads ui ui.commands ui.gadgets ui.gadgets.borders
ui.gadgets.buttons ui.gadgets.frames ui.gadgets.grids
ui.gadgets.labeled ui.gadgets.labels ui.gadgets.packs
ui.gadgets.sliders ui.render ui.render.gl3 ui.theme ui.tools.common ;

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

: vec>rad ( vec -- rad )
    first2 rect> arg ; inline

! Rotate a 2D point by angle (in radians)
:: rotate-point ( pt angle -- pt' )
    pt first :> x
    pt second :> y
    angle cos :> c
    angle sin :> s
    x c * y s * -
    x s * y c * +
    2array ;

! Triangle vertices for a boid (pointing right)
CONSTANT: boid-triangle { { -6.0 4.0 } { -6.0 -4.0 } { 8.0 0.0 } }

:: draw-boid-gl3 ( boid -- )
    boid pos>> first2 :> ( px py )
    boid vel>> vec>rad :> angle
    angle cos :> c
    angle sin :> s
    ! Triangle vertices (projection handles scaling)
    ! vertex 1: (-6, 4)
    -6.0 c * 4.0 s * - px + :> x1
    -6.0 s * 4.0 c * + py + :> y1
    ! vertex 2: (-6, -4)
    -6.0 c * -4.0 s * - px + :> x2
    -6.0 s * -4.0 c * + py + :> y2
    ! vertex 3: (8, 0)
    8.0 c * px + :> x3
    8.0 s * py + :> y3
    { { x1 y1 } { x2 y2 } { x3 y3 } }
    make-position-vertices
    upload-vertices
    GL_TRIANGLES 0 3 glDrawArrays ;

: draw-boid-legacy ( boid -- )
    [ pos>> ] keep '[
        _ vel>> vec>deg 0 0 1 glRotated
        GL_TRIANGLES [
            -6.0  4.0 glVertex2f
            -6.0 -4.0 glVertex2f
            8.0 0.0 glVertex2f
        ] do-state
    ] with-translation ;

: draw-boid ( boid -- )
    gl3-mode? get-global [ draw-boid-gl3 ] [ draw-boid-legacy ] if ;

: draw-boids ( boids -- )
    details-color >rgba-components drop 0.5 <rgba> gl-color
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

    behavior class-of name>> heading-color <framed-labeled-gadget> ;

:: set-population ( n boids-gadget -- )
    boids-gadget [
        dup length n >integer - dup 0 >
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

    "simulation" heading-color <framed-labeled-gadget> ;

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
    <boids-frame> white-interior >>gadgets ;
