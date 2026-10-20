USING: accessors arrays boids boids.simulation kernel locals sequences tools.test ;
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
