! Copyright (C) 2010 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes.struct destructors game.loop
game.worlds gpu gpu.buffers gpu.framebuffers gpu.render gpu.shaders
gpu.state gpu.textures gpu.util images images.loader kernel literals
locals make math math.rectangles math.vectors namespaces opengl.gl
sequences specialized-arrays ui.gadgets.worlds images.ppm
ui.gestures ui.pixel-formats images.pgm gpu.effects.blur ;
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
    particles texture framebuffer color-texture ramp { paused boolean initial: f } ;

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
    "C:/Users/erikc/Pictures/particle2.pgm" make-texture >>texture
    "C:/Users/erikc/Pictures/colors.ppm" make-texture >>ramp

    RGB float-components T{ texture-parameters
                           { wrap clamp-texcoord-to-edge }
                           { min-filter filter-linear }
                           { min-mipmap-filter f }
    } <texture-2d> >>color-texture

    dup color-texture>> 0 <texture-2d-attachment> 1array f f { 320 240 } <framebuffer> >>framebuffer
    drop ;

M: fluids-world end-game-world
    framebuffer>> dispose ;

M: fluids-world tick-game-world
    dup paused>> [ drop ] [ integrate ] if ;

M:: fluids-world draw-world* ( world -- )
    world framebuffer>> { { default-attachment { 0 0 0 } } } clear-framebuffer
    system-framebuffer { { default-attachment { 0 0 0 } } } clear-framebuffer

    f eq-add func-one func-one <blend-mode> dup <blend-state> set-gpu-state
    f origin-upper-left 1.0 <point-state> set-gpu-state
    world particles>> [
        [ p>> [ x>> , ] [ y>> , ] bi ] each
    ] curry float-array{ } make :> verts
    
    { 0 0 } { 320 240 } <rect> <viewport-state> set-gpu-state
    GL_POINT_SPRITE glEnable
    world verts {
        { "primitive-mode" [ 2drop points-mode ] }
        { "uniforms"       [ drop texture>> 50.0 window-point-uniforms boa ] }
        { "vertex-array"   [ nip stream-upload draw-usage vertex-buffer byte-array>buffer &dispose window-point-program <program-instance> &dispose <vertex-array> &dispose ] }
        { "indexes"        [ nip length 2 / 0 swap <index-range> ] }
        { "framebuffer"    [ drop framebuffer>> ] }
    } 2<render-set> render
    
    world color-texture>> gaussian-blur
    { 0 0 } { 640 480 } <rect> <viewport-state> set-gpu-state
    world ramp>> {
        { "primitive-mode" [ 2drop triangle-strip-mode ] }
        { "uniforms"       [ step-uniforms boa ] }
        { "vertex-array"   [ 2drop <window-vertex-buffer> step-program <program-instance> <vertex-array> ] }
        { "indexes"        [ 2drop T{ index-range f 0 4 } ] }
    } 2<render-set> render
    ;

GAME: fluids {
    { world-class fluids-world }
    { title "Fluids Test" }
    { pixel-format-attributes {
        windowed double-buffered T{ depth-bits { value 24 } } } }
    { pref-dim { 640 480 } }
    { tick-interval-micros $[ 60 fps ] }
} ;

MAIN: fluids

fluids-world H{
    { T{ button-down } [ [
        hand-loc get { 640 480 } v/ 2 v*n 1 v-n { 1 -1 } v* first2 float2_t <struct-boa>
        dup 2.0 particle_t <struct-boa> suffix
    ] change-particles drop ] }
} set-gestures
