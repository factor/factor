USING: accessors arrays boids boids.simulation kernel locals math
math.vectors namespaces sequences tools.test ui.gadgets
ui.gadgets.private ui.test ;
IN: boids.tests

{ { 603.0 600.0 } } [
    <boids-gadget> { 1024 768 } >>dim
    { } >>behaviors
    { 598.0 600.0 } { 1.0 0.0 } <boid> 1array >>boids
    dup iterate-system boids>> first pos>>
] unit-test

! Adding and randomizing boids also use the allocated area.
{ 5 t } [
    <boids-gadget> { 1 1 } >>dim { } >>boids
    5 over set-population
    boids>> [ length ] [ [ pos>> { 0 0 } = ] all? ] bi
] unit-test

{ t } [
    <boids-gadget> { 1 1 } >>dim
    dup com-randomize boids>> [ pos>> { 0 0 } = ] all?
] unit-test

:: position-after-frames ( intervals -- pos )
    <boids-gadget> { 1024 768 } >>dim { } >>behaviors
    { 100.0 100.0 } { 1.0 0.0 } <boid> 1array >>boids :> gadget
    intervals [ gadget swap advance-system ] each
    gadget boids>> first pos>> ;

{ t } [
    { 10,000,000 10,000,000 10,000,000 10,000,000 } position-after-frames
    { 40,000,000 } position-after-frames =
] unit-test

{ { 120.0 100.0 } } [ { 40,000,000 } position-after-frames ] unit-test
{ { 100.0 100.0 } } [ { 0 -10,000,000 } position-after-frames ] unit-test
{ { 150.0 100.0 } } [ { 1,000,000,000 } position-after-frames ] unit-test

{ 2 { 108.0 100.0 } } [
    <boids-gadget> { 1024 768 } >>dim { } >>behaviors 2 >>dt
    { 100.0 100.0 } { 1.0 0.0 } <boid> 1array >>boids
    dup 40,000,000 advance-system
    [ dt>> ] [ boids>> first pos>> ] bi
] unit-test

: <paused-boids-frame> ( -- frame )
    <boids-frame> dup children>> first t >>paused drop ;

:: resize-frame ( frame dim -- )
    frame dim >>dim t in-layout? [ layout ] with-variable ;

:: fills-frame? ( frame -- ? )
    frame children>> first :> view
    frame children>> last :> panel
    view dim>> first panel dim>> first + frame dim>> first number=
    view dim>> second frame dim>> second number= and
    panel loc>> first view dim>> first number= and ;

{ { 400.0 200.0 } t t } [
    [let
        <paused-boids-frame> :> frame
        frame { 800 600 } resize-frame
        frame children>> first dim>> :> previous-area
        frame children>> last dim>> first :> panel-width
        frame { 1200 800 } resize-frame
        frame children>> first dim>> previous-area v-
        frame children>> last dim>> first panel-width number=
        frame fills-frame?
    ]
] unscaled-ui-test unit-test

{ t } [
    [let
        <paused-boids-frame> :> frame
        frame { 1400 1000 } resize-frame
        frame { 800 600 } resize-frame
        frame fills-frame?
    ]
] unscaled-ui-test unit-test

{ { 905.0 800.0 } } [
    [let
        <paused-boids-frame> :> frame
        frame { 1400 1000 } resize-frame
        frame children>> first { } >>behaviors
        { 900.0 800.0 } { 1.0 0.0 } <boid> 1array >>boids
        dup iterate-system boids>> first pos>>
    ]
] unscaled-ui-test unit-test
