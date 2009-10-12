! (c)2009 Joe Groff bsd license
USING: accessors arrays combinators.tuple game.loop game.worlds
generalizations gpu gpu.render gpu.shaders gpu.util gpu.util.wasd
kernel literals math math.matrices math.order math.vectors
method-chains sequences ui ui.gadgets ui.gadgets.worlds
ui.pixel-formats ;
IN: gpu.demos.raytrace

GLSL-SHADER-FILE: raytrace-vertex-shader vertex-shader "raytrace.v.glsl"
GLSL-SHADER-FILE: raytrace-fragment-shader fragment-shader "raytrace.f.glsl"
GLSL-PROGRAM: raytrace-program
    raytrace-vertex-shader raytrace-fragment-shader ;

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
    [ [ axis>> ] [ theta>> ] bi rotation-matrix4 ]
    [ home>> ] bi m.v ;

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

BEFORE: raytrace-world begin-world
    init-gpu
    { -2.0 6.25 10.0 } 0.19 0.55 set-wasd-view
    initial-spheres [ clone ] map >>spheres    
    raytrace-program <program-instance> <window-vertex-array> >>vertex-array
    drop ;

CONSTANT: fov 0.7

AFTER: raytrace-world resize-world
    dup dim>> dup first2 min >float v/n fov v*n >>fov drop ;

AFTER: raytrace-world tick*
    spheres>> [ tick-sphere ] each ;

M: raytrace-world draw-world*
    {
        { "primitive-mode" [ drop triangle-strip-mode    ] }
        { "indexes"        [ drop T{ index-range f 0 4 } ] }
        { "uniforms"       [ <sphere-uniforms>           ] }
        { "vertex-array"   [ vertex-array>>              ] }
    } <render-set> render ;

M: raytrace-world pref-dim* drop { 1024 768 } ;
M: raytrace-world tick-length drop 1000 30 /i ;
M: raytrace-world wasd-movement-speed drop 1/4. ;

: raytrace-window ( -- )
    [
        f T{ world-attributes
            { world-class raytrace-world }
            { title "Raytracing" }
            { pixel-format-attributes {
                windowed
                double-buffered
            } }
            { grab-input? t }
        } open-window
    ] with-ui ;

MAIN: raytrace-window
