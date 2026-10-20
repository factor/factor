USING: accessors arrays boids.simulation boids.simulation.private kernel
locals math math.functions math.vectors namespaces random
random.mersenne-twister sequences sets tools.test ;
IN: boids.simulation.tests

{ { 600 700 } } [ { 600 700 } { 1024 768 } wrap-pos-in ] unit-test
{ { 176 132 } } [ { 1200 900 } { 1024 768 } wrap-pos-in ] unit-test
{ { 1023 767 } } [ { -2049 -1537 } { 1024 768 } wrap-pos-in ] unit-test
{ { 0 0 } } [ { 10 20 } { 0 0 } wrap-pos-in ] unit-test
{ { 88 188 } } [ { 600 700 } wrap-pos ] unit-test

! The same flock moves into the expanded area, then wraps after shrinking.
{ { 603.0 600.0 } { 91.0 88.0 } } [
    { 598.0 600.0 } { 1.0 0.0 } <boid> 1array
    { } 5 { 1024 768 } simulate-in
    dup first pos>> swap
    { } 0 { 256 256 } simulate-in first pos>>
] unit-test

{ 10 t } [
    10 { 1 1 } random-boids-in
    [ length ] [ [ pos>> { 0 0 } = ] all? ] bi
] unit-test

:: all-pairs-step ( boids behaviors dt dim -- boids )
    boids [| boid |
        boid boids behaviors
        [ [ (force) ] keep weight>> v*n ] 2with map vsum :> acceleration
        boid vel>> acceleration dt v*n v+ normalize :> velocity
        boid pos>> velocity dt v*n v+ dim wrap-pos-in :> position
        position velocity <boid>
    ] map ;

: same-component? ( left right -- ? )
    2dup [ fp-nan? ] both?
    [ 2drop t ] [ 1.0e-9 ~ ] if ;

: same-vector? ( left right -- ? )
    [ same-component? ] 2all? ;

: same-boid? ( left right -- ? )
    [ [ pos>> ] bi@ same-vector? ]
    [ [ vel>> ] bi@ same-vector? ] 2bi and ;

:: matches-all-pairs? ( boids behaviors dt dim -- ? )
    boids behaviors dt dim simulate-in
    boids behaviors dt dim all-pairs-step
    [ same-boid? ] 2all? ;

: test-behaviors ( -- behaviors )
    1.0 75.0 -0.1 <cohesion>
    1.0 40.0 -0.5 <alignment>
    1.0 25.0 -1.0 <separation> 3array ;

{ t } [
    12345 <mersenne-twister> random-generator [
        { { 512 512 } { 2048 1536 } { 64 64 } { 1 1 } } [| dim |
            150 dim random-boids-in test-behaviors 5.0 dim matches-all-pairs?
        ] all?
    ] with-variable
] unit-test

: boundary-flock ( -- boids )
    { { -150.0 -75.0 } { -75.0 -75.0 } { -0.01 -0.01 }
      { 0.0 0.0 } { 74.99 74.99 } { 75.0 75.0 }
      { 149.99 0.0 } { 150.0 0.0 } { 512.0 512.0 } }
    [ { 1.0 0.2 } <boid> ] map ;

{ t } [
    boundary-flock test-behaviors 5.0 { 512 512 } matches-all-pairs?
] unit-test

{ { -1 -1 } { 0 0 } { 1 1 } } [
    { -0.01 -75.0 } 75.0 position>cell
    { 0.0 74.99 } 75.0 position>cell
    { 75.0 149.99 } 75.0 position>cell
] unit-test

:: all-neighbors-retained? ( -- ? )
    boundary-flock :> flock
    flock 75.0 index-boids :> grid
    flock [| boid |
        test-behaviors [| behavior |
            boid flock behavior neighbors
            boid boid grid 75.0 nearby-boids behavior neighbors set=
        ] all?
    ] all? ;

{ t } [ all-neighbors-retained? ] unit-test

{ t } [
    12345 <mersenne-twister> random-generator [let
        100 { 512 512 } random-boids-in :> flock
        { -1.0 0.0 0.25 1.0 75.0 1024.0 } [| radius |
            { -1.0 0.0 0.5 1.0 } [| angle |
                1.0 radius angle <cohesion>
                1.0 radius angle <alignment>
                1.0 radius angle <separation> 3array :> behaviors
                flock behaviors 5.0 { 512 512 } matches-all-pairs?
            ] all?
        ] all?
    ] with-variable
] unit-test

{ t } [
    { { 0.0 0.0 } { 0.0 0.0 } { 75.0 75.0 } { 150.0 150.0 } }
    [ { 1.0 0.0 } <boid> ] map
    dup first suffix test-behaviors 5.0 { 512 512 } matches-all-pairs?
] unit-test

{ t } [
    boundary-flock
    { 0/0. 0.0 } { 1.0 0.0 } <boid> suffix
    { 1/0. 0.0 } { 1.0 0.0 } <boid> suffix
    test-behaviors 5.0 { 512 512 } matches-all-pairs?
] unit-test

{ t } [
    boundary-flock { 0.0 0.0 } { 0.0 0.0 } <boid> suffix
    test-behaviors 5.0 { 512 512 } simulate-in
    test-behaviors 5.0 { 512 512 } matches-all-pairs?
] unit-test

{ { } } [ { } test-behaviors 5.0 { 512 512 } simulate-in ] unit-test

{ t } [
    12345 <mersenne-twister> random-generator [let
        1000 { 2048 1536 } random-boids-in :> flock
        flock 75.0 index-boids :> grid
        flock [ grid 75.0 nearby-boids length ] map sum
        flock length sq 10 / <
    ] with-variable
] unit-test
