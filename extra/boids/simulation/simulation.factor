! Copyright (C) 2008 Eduardo Cavazos.
! Copyright (C) 2011 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators.short-circuit kernel
locals math math.vectors random sequences ;
IN: boids.simulation

CONSTANT: width 512
CONSTANT: height 512

TUPLE: behaviour
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
    [ normalize ] bi@ v. ; inline

: relative-position ( self other -- v )
    swap [ pos>> ] bi@ v- ; inline

:: relative-angle ( self other -- angle )
    self other relative-position
    self vel>> angle-between ; inline

: in-view? ( self other angle-cos -- ? )
    [ relative-angle ] dip >= ; inline

:: within-neighborhood? ( self other behaviour -- ? )
    self other {
        [ eq? not ]
        [ behaviour radius>> in-radius? ]
        [ behaviour angle-cos>> in-view? ]
    } 2&& ; inline

:: neighbors ( boid boids behaviour -- neighbors )
    boid boids [ behaviour within-neighborhood? ] with filter ;


GENERIC: force ( neighbors boid behaviour -- force )

:: (force) ( boid boids behaviour -- force )
    boid boids behaviour neighbors
    [ { 0.0 0.0 } ] [ boid behaviour force ] if-empty ;

: wrap-pos ( pos -- pos )
    width height [ 1 - ] bi@ 2array
    [ [ + ] keep mod ] 2map ;

:: simulate ( boids behaviours dt -- boids )
    boids [| boid |
        boid boids behaviours
        [ [ (force) ] keep weight>> v*n ] 2with map vsum :> a

        boid vel>> a dt v*n v+ normalize :> vel
        boid pos>> vel dt v*n v+ wrap-pos :> pos

        pos vel <boid>
    ] map ;

: random-boids ( count -- boids )
    [
        width height [ random ] bi@ 2array
        2 [ 0 1 normal-random-float ] replicate
        <boid>
    ] replicate ;

TUPLE: cohesion < behaviour ;
TUPLE: alignment < behaviour ;
TUPLE: separation < behaviour ;

C: <cohesion> cohesion
C: <alignment> alignment
C: <separation> separation

M: cohesion force ( neighbors boid behaviour -- force )
    drop [ [ pos>> ] map vavg ] [ pos>> ] bi* v- normalize ;

M: alignment force ( neighbors boid behaviour -- force )
    2drop [ vel>> ] map vsum normalize ;

M:: separation force ( neighbors boid behaviour -- force )
    behaviour radius>> :> r
    boid pos>> neighbors
    [ pos>> v- [ normalize ] [ r v/n ] bi v- ] with map vsum ;
