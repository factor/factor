USING: accessors arrays boids boids.simulation kernel sequences tools.test ;

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
