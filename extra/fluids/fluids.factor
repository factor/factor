! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.data classes.struct destructors game.loop
game.worlds gpu gpu.effects.blur gpu.effects.step gpu.state
gpu.textures gpu.util images.loader kernel literals make math
math.vectors namespaces sequences specialized-arrays
ui.gadgets.worlds ui.gestures ui.pixel-formats ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
IN: fluids

STRUCT: particle_t
    { p float[2] }
    { v float[2] }
    { m float    } ;
SPECIALIZED-ARRAY: particle_t

CONSTANT: gravity { 0.0 -0.1 }

:: verlet-integrate-particle ( particle dt -- particle' )
    particle [ p>> ] [ v>> ] bi dt v*n v+
    gravity dt dt * particle m>> 2 * / v*n v+ :> p'
    p' particle p>> v- dt v/n :> v'
    p' v' particle m>> particle_t boa ; inline

CONSTANT: initial-particles
particle_t-array{
    S{ particle_t f float-array{ 0.5 0.6 } float-array{ 0 0.1 } 1.0 }
    S{ particle_t f float-array{ 0.5 0.6 } float-array{ 0.1 0 } 3.0 }

    S{ particle_t f float-array{ 0.5 0.5 } float-array{ 0.1 0.1 } 2.0 }
    S{ particle_t f float-array{ 0.5 0.6 } float-array{ -0.1 0 } 1.0 }
    S{ particle_t f float-array{ 0.6 0.5 } float-array{ 0 -0.1 } 3.0 }
    S{ particle_t f float-array{ 0.7 0.5 } float-array{ 0.1 0.1 } 1.0 }
    S{ particle_t f float-array{ 0.1 0.5 } float-array{ -0.1 -0.1 } 5.0 }
    S{ particle_t f float-array{ 0.2 0.5 } float-array{ 0 0 } 1.0 }
    S{ particle_t f float-array{ 0.3 0.3 } float-array{ 0 0 } 4.0 }
    S{ particle_t f float-array{ 0.5 0.15 } float-array{ 0 0 } 1.0 }
    S{ particle_t f float-array{ 0.5 0.1 } float-array{ 0 0 } 9.0 }
}

: integrate-particles! ( particles dt -- particles )
    [ verlet-integrate-particle ] curry map! ;

TUPLE: fluids-world < game-world
    particles texture ramp { paused boolean initial: f } ;

: make-texture ( pathname -- texture )
    load-image
    [
        [ component-order>> ]
        [ component-type>> ] bi
        T{ texture-parameters
           { wrap clamp-texcoord-to-edge }
           { min-filter filter-nearest }
           { mag-filter filter-nearest }
           { min-mipmap-filter f } }
        <texture-2d>
    ]
    [
        0 swap [ allocate-texture-image ] keepdd
    ] bi ;

SYMBOL: fluid

: integrate ( world -- )
    particles>> 1/60 integrate-particles! drop ;

: pause ( -- )
    fluid get [ not ] change-paused drop ;

: step ( -- )
    fluid get paused>> [ fluid get integrate ] when ;

M: fluids-world begin-game-world
    dup fluid set
    init-gpu
    initial-particles clone >>particles
    "vocab:fluids/particle2.pgm" make-texture >>texture
    "vocab:fluids/colors.ppm" make-texture >>ramp
    drop ;

M: fluids-world end-game-world
    drop ;

M: fluids-world tick-game-world
    dup paused>> [ drop ] [ integrate ] if ;

M:: fluids-world draw-world* ( world -- )
    world particles>> [
        [ p>> [ first , ] [ second , ] bi ] each
    ] curry float-array{ } make :> verts

    [
        verts world texture>> 30.0 world dim>> { 4 4 } v/
        blended-point-sprite-batch &dispose
        blend-state new set-gpu-state
        gaussian-blur &dispose
        world ramp>> world dim>> step-texture &dispose
        world dim>> draw-texture
    ] with-destructors ;

GAME: fluids {
    { world-class fluids-world }
    { title "Fluids Test" }
    { pixel-format-attributes {
        windowed double-buffered T{ depth-bits { value 24 } } } }
    { pref-dim { 1024 768 } }
    { tick-interval-nanos $[ 60 fps ] }
} ;

fluids-world H{
    { T{ button-down } [ [
        hand-loc get float >c-array
        world get dim>> float >c-array v/ 2 v*n 1 v-n { 1 -1 } v*
        float-array{ 0 0.2 } 2.0 particle_t boa suffix
    ] change-particles drop ] }
} set-gestures
