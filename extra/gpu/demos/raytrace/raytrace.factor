! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays audio.engine audio.loader game.loop
game.worlds gpu gpu.render gpu.shaders gpu.util gpu.util.wasd
kernel literals math math.libm math.matrices
math.matrices.extras math.order math.vectors method-chains
sequences ui.gadgets.worlds ui.pixel-formats ;
IN: gpu.demos.raytrace

GLSL-SHADER-FILE: raytrace-vertex-shader vertex-shader "raytrace.v.glsl"
GLSL-SHADER-FILE: raytrace-fragment-shader fragment-shader "raytrace.f.glsl"
GLSL-PROGRAM: raytrace-program
    raytrace-vertex-shader raytrace-fragment-shader
    window-vertex-format ;

UNIFORM-TUPLE: sphere-uniforms
    { "center" vec3-uniform  f }
    { "radius" float-uniform f }
    { "color"  vec4-uniform  f } ;

UNIFORM-TUPLE: raytrace-uniforms
    { "mv-inv-matrix"    mat4-uniform f }
    { "fov"              vec2-uniform f }

    { "spheres"          sphere-uniforms 4 }

    { "floor-height"     float-uniform f }
    { "floor-color"      vec4-uniform 2 }
    { "background-color" vec4-uniform f }
    { "light-direction"  vec3-uniform f } ;

CONSTANT: reflection-color { 1.0 0.0 1.0 0.0 }

TUPLE: sphere
    { axis array }
    { home array }
    { dtheta float }
    { radius float }
    { color array }
    { theta float initial: 0.0 } ;

TUPLE: raytrace-world < wasd-world
    fov
    spheres
    vertex-array ;

: tick-sphere ( sphere -- )
    dup dtheta>> [ + ] curry change-theta drop ;

: sphere-center ( sphere -- center )
    [ [ axis>> ] [ theta>> ] bi <rotation-matrix4> ]
    [ home>> ] bi mdotv ;

M: sphere audio-position sphere-center ; inline
M: sphere audio-distance radius>> fsqrt 2.0 * ; inline

: <sphere-uniforms> ( world -- uniforms )
    [ wasd-mv-inv-matrix ]
    [ fov>> ]
    [
        spheres>>
        [ [ sphere-center ] [ radius>> ] [ color>> ] tri sphere-uniforms boa ] map
    ] tri
    -30.0 ! floor_height
    { { 1.0 0.0 0.0 1.0 } { 1.0 1.0 1.0 1.0 } } ! floor_color
    { 0.15 0.15 1.0 1.0 } ! background_color
    { 0.0 -1.0 -0.1 } ! light_direction
    raytrace-uniforms boa ;

CONSTANT: initial-spheres {
    T{ sphere f { 0.0 1.0  0.0 } {  0.0 0.0 0.0 } 0.0   4.0 $ reflection-color  }
    T{ sphere f { 0.0 1.0  0.0 } {  7.0 0.0 0.0 } 0.02  1.0 { 1.0 0.0 0.0 1.0 } }
    T{ sphere f { 0.0 0.0 -1.0 } { -9.0 0.0 0.0 } 0.03  1.0 { 0.0 1.0 0.0 1.0 } }
    T{ sphere f { 1.0 0.0  0.0 } {  0.0 5.0 0.0 } 0.025 1.0 { 1.0 1.0 0.0 1.0 } }
}

:: set-up-audio ( world -- )
    world audio-engine>> :> audio-engine
    world spheres>> :> spheres

    audio-engine world >>listener update-audio

    audio-engine spheres first
    "vocab:gpu/demos/raytrace/mirror-ball.aiff" read-audio t <static-audio-clip>
    audio-engine spheres second
    "vocab:gpu/demos/raytrace/red-ball.aiff" read-audio t <static-audio-clip>
    audio-engine spheres third
    "vocab:gpu/demos/raytrace/green-ball.aiff" read-audio t <static-audio-clip>
    audio-engine spheres fourth
    "vocab:gpu/demos/raytrace/yellow-ball.aiff" read-audio t <static-audio-clip>

    4array play-clips ;

M: raytrace-world begin-game-world
    init-gpu
    { -2.0 6.25 10.0 } 0.19 0.55 set-wasd-view
    initial-spheres [ clone ] map >>spheres
    raytrace-program <program-instance> <window-vertex-array> >>vertex-array
    set-up-audio ;

CONSTANT: fov 0.7

AFTER: raytrace-world resize-world
    dup dim>> dup first2 min >float v/n fov v*n >>fov drop ;

AFTER: raytrace-world tick-game-world
    spheres>> [ tick-sphere ] each ;

M: raytrace-world draw-world*
    {
        { "primitive-mode" [ drop triangle-strip-mode    ] }
        { "indexes"        [ drop T{ index-range f 0 4 } ] }
        { "uniforms"       [ <sphere-uniforms>           ] }
        { "vertex-array"   [ vertex-array>>              ] }
    } <render-set> render ;

M: raytrace-world wasd-movement-speed drop 1/4. ;

GAME: raytrace-game {
        { world-class raytrace-world }
        { title "Raytracing" }
        { pixel-format-attributes {
            windowed
            double-buffered
        } }
        { grab-input? t }
        { use-game-input? t }
        { use-audio-engine? t }
        { pref-dim { 1024 768 } }
        { tick-interval-nanos $[ 60 fps ] }
    } ;
