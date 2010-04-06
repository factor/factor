! Copyright (C) 2010 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes.struct destructors game.loop
game.worlds gpu gpu.buffers gpu.effects.blur gpu.framebuffers
gpu.render gpu.shaders gpu.state gpu.textures gpu.util images
images.loader kernel literals locals make math math.rectangles
math.vectors namespaces opengl.gl sequences specialized-arrays
ui.gadgets.worlds ui.gestures ui.pixel-formats gpu.effects.step
images.pgm images.ppm ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
IN: fluids

STRUCT: float2_t
    { x float }
    { y float } ;

: f2+ ( lhs rhs -- res )
    [ [ x>> ] bi@ + ]
    [ [ y>> ] bi@ + ]
    2bi float2_t <struct-boa> ; inline

: f2- ( lhs rhs -- res )
    [ [ x>> ] bi@ - ]
    [ [ y>> ] bi@ - ]
    2bi float2_t <struct-boa> ; inline

: f2*n ( lhs rhs -- res ) 
    [ [ x>> ] dip * ]
    [ [ y>> ] dip * ]
    2bi float2_t <struct-boa> ; inline

STRUCT: particle_t
    { p  float2_t }
    { p' float2_t }
    { m  float    } ;
SPECIALIZED-ARRAY: particle_t

CONSTANT: gravity S{ float2_t f 0.0 -0.1 }

:: verlet-integrate-particle ( p dt -- p' )
    p p>> 2.0 f2*n :> v1
    p p'>> :> v2
    gravity dt dt * 1.0 p m>> 2.0 * / * f2*n :> v3
    v1 v2 f2- v3 f2+
    p p m>> particle_t <struct-boa> ; inline

CONSTANT: initial-particles
particle_t-array{
    S{ particle_t f S{ float2_t f 0.5 0.6 } S{ float2_t f 0.499 0.599 } 1.0 }
    S{ particle_t f S{ float2_t f 0.5 0.6 } S{ float2_t f 0.501 0.599 } 3.0 }
    
    S{ particle_t f S{ float2_t f 0.5 0.5 } S{ float2_t f 0.5 0.5 } 2.0 }
    S{ particle_t f S{ float2_t f 0.5 0.6 } S{ float2_t f 0.5 0.599 } 1.0 }
    S{ particle_t f S{ float2_t f 0.6 0.5 } S{ float2_t f 0.6 0.5 } 3.0 }
    S{ particle_t f S{ float2_t f 0.7 0.5 } S{ float2_t f 0.7 0.5 } 1.0 }
    S{ particle_t f S{ float2_t f 0.1 0.5 } S{ float2_t f 0.1 0.5 } 5.0 }
    S{ particle_t f S{ float2_t f 0.2 0.5 } S{ float2_t f 0.2 0.5 } 1.0 }
    S{ particle_t f S{ float2_t f 0.3 0.3 } S{ float2_t f 0.3 0.3 } 4.0 }
    S{ particle_t f S{ float2_t f 0.5 0.15 } S{ float2_t f 0.5 0.15 } 1.0 }
    S{ particle_t f S{ float2_t f 0.5 0.1 } S{ float2_t f 0.5 0.1 } 9.0 }
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
        0 swap [ allocate-texture-image ] 3keep 2drop
    ] bi ;

SYMBOL: fluid

: integrate ( world -- )
    particles>> $[ 60 fps 1000000 /f ] integrate-particles! drop ;

: pause ( -- )
    fluid get [ not ] change-paused drop ;

: step ( -- )
    fluid get paused>> [ fluid get integrate ] when ;

M: fluids-world begin-game-world
    dup fluid set
    init-gpu
    initial-particles clone >>particles
    "resource:extra/fluids/particle2.pgm" make-texture >>texture
    "resource:extra/fluids/colors.ppm" make-texture >>ramp
    drop ;

M: fluids-world end-game-world
    drop ;

M: fluids-world tick-game-world
    dup paused>> [ drop ] [ integrate ] if ;

M:: fluids-world draw-world* ( world -- )
    world particles>> [
        [ p>> [ x>> , ] [ y>> , ] bi ] each
    ] curry float-array{ } make :> verts
    
    [ 
        verts world texture>> 50.0 { 320 240 } blended-point-sprite-batch &dispose
        
        blend-state new set-gpu-state
        
        gaussian-blur &dispose world ramp>> { 1024 768 } step-texture &dispose
        { 1024 768 } draw-texture
    ] with-destructors
    ;

GAME: fluids {
    { world-class fluids-world }
    { title "Fluids Test" }
    { pixel-format-attributes {
        windowed double-buffered T{ depth-bits { value 24 } } } }
    { pref-dim { 1024 768 } }
    { tick-interval-micros $[ 60 fps ] }
} ;

MAIN: fluids

fluids-world H{
    { T{ button-down } [ [
        hand-loc get { 1024 768 } v/ 2 v*n 1 v-n { 1 -1 } v* first2 float2_t <struct-boa>
        dup 2.0 particle_t <struct-boa> suffix
    ] change-particles drop ] }
} set-gestures
