! Copyright (C) 2008 Eduardo Cavazos.
! Copyright (C) 2011 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.short-circuit kernel math
math.functions math.order math.vectors random sequences ;
IN: boids.simulation

CONSTANT: WIDTH 512
CONSTANT: HEIGHT 512

TUPLE: behavior
    { weight float }
    { radius float }
    { angle-cos float } ;

TUPLE: boid
    { pos array }
    { vel array } ;

C: <boid> boid

: vsum ( vecs -- v )
    { 0.0 0.0 } [ v+ ] reduce ; inline

: vavg ( vecs -- v )
    [ vsum ] [ length ] bi v/n ; inline

: in-radius? ( self other radius -- ? )
    [ [ pos>> ] bi@ distance ] dip <= ; inline

: angle-between ( u v -- angle )
    [ normalize ] bi@ vdot ; inline

: relative-position ( self other -- v )
    swap [ pos>> ] bi@ v- ; inline

:: relative-angle ( self other -- angle )
    self other relative-position
    self vel>> angle-between ; inline

: in-view? ( self other angle-cos -- ? )
    [ relative-angle ] dip >= ; inline

:: within-neighborhood? ( self other behavior -- ? )
    self other {
        [ eq? not ]
        [ behavior radius>> in-radius? ]
        [ behavior angle-cos>> in-view? ]
    } 2&& ; inline

:: neighbors ( boid boids behavior -- neighbors )
    boid boids [ behavior within-neighborhood? ] with filter ;

GENERIC: force ( neighbors boid behavior -- force )

:: (force) ( boid boids behavior -- force )
    boid boids behavior neighbors
    [ { 0.0 0.0 } ] [ boid behavior force ] if-empty ;

: wrap-pos-in ( pos dim -- pos )
    [ 1 max [ mod ] keep [ + ] keep mod ] 2map ;

: wrap-pos ( pos -- pos )
    WIDTH HEIGHT 2array wrap-pos-in ;

<PRIVATE

CONSTANT: neighboring-cells
    { { -1 -1 } { 0 -1 } { 1 -1 }
      { -1 0 } { 0 0 } { 1 0 }
      { -1 1 } { 0 1 } { 1 1 } }

: position>cell ( pos cell-size -- cell )
    '[ _ / floor >integer ] map ;

: indexable-boid? ( boid -- ? )
    pos>> [ fp-special? not ] all? ;

:: index-boids ( boids cell-size -- grid )
    H{ } clone :> grid
    boids [| boid |
        boid indexable-boid? [
            boid boid pos>> cell-size position>cell grid push-at
        ] when
    ] each
    grid ;

:: nearby-boids ( boid grid cell-size -- candidates )
    boid indexable-boid? [
        boid pos>> cell-size position>cell :> cell
        neighboring-cells [ cell v+ grid at ] map concat
    ] [ { } ] if ;

PRIVATE>

:: simulate-in ( boids behaviors dt dim -- boids )
    behaviors [ radius>> ] map 1.0 [ max ] reduce :> cell-size
    behaviors empty? [ f ] [
        boids cell-size index-boids
        dup assoc-size 1 > [ ] [ drop f ] if
    ] if :> grid
    boids [| boid |
        grid [ boid grid cell-size nearby-boids ] [ boids ] if :> candidates
        boid candidates behaviors
        [ [ (force) ] keep weight>> v*n ] 2with map vsum :> a

        boid vel>> a dt v*n v+ normalize :> vel
        boid pos>> vel dt v*n v+ dim wrap-pos-in :> pos

        pos vel <boid>
    ] map ;

: simulate ( boids behaviors dt -- boids )
    WIDTH HEIGHT 2array simulate-in ;

: random-boids-in ( count dim -- boids )
    '[
        _ [ >integer 1 max random ] map
        2 [ 0 1 normal-random ] replicate
        <boid>
    ] replicate ;

: random-boids ( count -- boids )
    WIDTH HEIGHT 2array random-boids-in ;

TUPLE: cohesion < behavior ;
TUPLE: alignment < behavior ;
TUPLE: separation < behavior ;

C: <cohesion> cohesion
C: <alignment> alignment
C: <separation> separation

M: cohesion force ( neighbors boid behavior -- force )
    drop [ [ pos>> ] map vavg ] [ pos>> ] bi* v- normalize ;

M: alignment force ( neighbors boid behavior -- force )
    2drop [ vel>> ] map vsum normalize ;

M:: separation force ( neighbors boid behavior -- force )
    behavior radius>> :> r
    boid pos>> neighbors
    [ pos>> v- [ normalize ] [ r v/n ] bi v- ] with map vsum ;
