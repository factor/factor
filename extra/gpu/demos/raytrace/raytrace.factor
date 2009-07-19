! (c)2009 Joe Groff bsd license
USING: accessors arrays game-loop game-worlds generalizations
gpu gpu.render gpu.shaders gpu.util gpu.util.wasd kernel
literals math math.matrices math.order math.vectors
method-chains sequences ui ui.gadgets ui.gadgets.worlds
ui.pixel-formats ;
IN: gpu.demos.raytrace

GLSL-SHADER-FILE: raytrace-vertex-shader vertex-shader "raytrace.v.glsl"
GLSL-SHADER-FILE: raytrace-fragment-shader fragment-shader "raytrace.f.glsl"
GLSL-PROGRAM: raytrace-program
    raytrace-vertex-shader raytrace-fragment-shader ;

UNIFORM-TUPLE: raytrace-uniforms
    { "mv_inv_matrix" float-uniform { 4 4 } }
    { "fov" float-uniform 2 }

    { "spheres[0].center" float-uniform 3 }
    { "spheres[0].radius" float-uniform 1 }
    { "spheres[0].color"  float-uniform 4 }

    { "spheres[1].center" float-uniform 3 }
    { "spheres[1].radius" float-uniform 1 }
    { "spheres[1].color"  float-uniform 4 }

    { "spheres[2].center" float-uniform 3 }
    { "spheres[2].radius" float-uniform 1 }
    { "spheres[2].color"  float-uniform 4 }

    { "spheres[3].center" float-uniform 3 }
    { "spheres[3].radius" float-uniform 1 }
    { "spheres[3].color"  float-uniform 4 }
    
    { "floor_height"   float-uniform 1 }
    { "floor_color[0]" float-uniform 4 }
    { "floor_color[1]" float-uniform 4 }
    { "background_color" float-uniform 4 }
    { "light_direction" float-uniform 3 } ;

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
        [ [ sphere-center ] [ radius>> ] [ color>> ] tri 3array ] map
        first4 [ first3 ] 4 napply
    ] tri
    -30.0 ! floor_height
    { 1.0 0.0 0.0 1.0 } ! floor_color[0]
    { 1.0 1.0 1.0 1.0 } ! floor_color[1]
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
    render-set new
        triangle-strip-mode >>primitive-mode
        T{ index-range f 0 4 } >>indexes
        swap
        [ <sphere-uniforms> >>uniforms ]
        [ vertex-array>> >>vertex-array ] bi
    render ;

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
