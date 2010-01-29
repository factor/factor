! Copyright (C) 2010 Erik Charlebois
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays classes.struct combinators
combinators.short-circuit game.loop game.worlds gpu gpu.buffers
gpu.util.wasd gpu.framebuffers gpu.render gpu.shaders gpu.state
gpu.textures gpu.util grouping http.client images images.loader
io io.encodings.ascii io.files io.files.temp kernel locals math
math.matrices math.vectors.simd math.parser math.vectors
method-chains namespaces sequences splitting threads ui ui.gadgets
ui.gadgets.worlds ui.pixel-formats specialized-arrays
specialized-vectors literals collada fry xml xml.traversal sequences.deep

opengl.gl
prettyprint ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
SPECIALIZED-VECTOR: uint
IN: collada.viewer

GLSL-SHADER: collada-vertex-shader vertex-shader
uniform mat4 mv_matrix, p_matrix;
uniform vec3 light_position;

attribute vec3 POSITION;

void main()
{
    vec4 position = mv_matrix * vec4(POSITION, 1.0);
    gl_Position = p_matrix * position;
}
;

GLSL-SHADER: collada-fragment-shader fragment-shader
void main()
{
    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
;

GLSL-PROGRAM: collada-program
    collada-vertex-shader collada-fragment-shader ;

UNIFORM-TUPLE: collada-uniforms < mvp-uniforms
    { "light-position" vec3-uniform  f } ;

TUPLE: collada-state
    models
    vertex-arrays
    index-vectors ;

TUPLE: collada-world < wasd-world
    { collada collada-state } ;

VERTEX-FORMAT: collada-vertex
    { "POSITION" float-components 3 f }
    { f          float-components 3 f } ;

:: mymax ( x y -- x ) x third y third > [ x ] [ y ] if ;

: <collada-buffers> ( models -- buffers )
    ! drop
    ! float-array{ -0.5 0 0 0 0 0 0 1 0 0 0 0 0.5 0 0 0 0 0 }
    ! uint-array{ 0 1 2 }
    ! f model boa 1array
    [
        [ attribute-buffer>> underlying>> static-upload draw-usage vertex-buffer byte-array>buffer ]
        [ index-buffer>> underlying>> static-upload draw-usage index-buffer byte-array>buffer ]
        [ index-buffer>> length ] tri 3array
    ] map ;

: fill-collada-state ( collada-state -- )
    dup models>> <collada-buffers>
    [
        [
            first collada-program <program-instance> collada-vertex buffer>vertex-array
        ] map >>vertex-arrays drop
    ]
    [
        [
            [ second ] [ third ] bi
            '[ _ 0 <buffer-ptr> _ uint-indexes <index-elements> ] call
        ] map >>index-vectors drop
    ] 2bi ;
    
: <collada-state> ( -- collada-state )
    collada-state new
    "C:/Users/erikc/Downloads/mech.dae" file>xml "mesh" deep-tags-named [ collada-mesh>model ] map flatten >>models ;

M: collada-world begin-game-world
    init-gpu
    { 0.0 0.0 2.0 } 0 0 set-wasd-view
    <collada-state> [ fill-collada-state drop ] [ >>collada drop ] 2bi ;

: <collada-uniforms> ( world -- uniforms )
    [ wasd-mv-matrix ] [ wasd-p-matrix ] bi
    { -10000.0 10000.0 10000.0 } ! light position
    collada-uniforms boa ;

: draw-collada ( world -- )
    GL_COLOR_BUFFER_BIT glClear
    triangle-lines dup t <triangle-state> set-gpu-state
    [ collada>> vertex-arrays>> ]
    [ collada>> index-vectors>> ]
    [ <collada-uniforms> ]
    tri
    [
        {
            { "primitive-mode"     [ 3drop triangles-mode ] }
            { "uniforms"           [ swap drop swap drop ] }
            { "vertex-array"       [ drop drop ] }
            { "indexes"            [ drop swap drop ] }
        } 3<render-set> render
    ] curry 2each ;

M: collada-world draw-world*
    draw-collada ;

M: collada-world wasd-movement-speed drop 1/16. ;
M: collada-world wasd-near-plane drop 1/32. ;
M: collada-world wasd-far-plane drop 1024.0 ;

GAME: collada-game {
        { world-class collada-world }
        { title "Collada Viewer" }
        { pixel-format-attributes {
            windowed
            double-buffered
        } }
        { grab-input? t }
        { use-game-input? t }
        { pref-dim { 1024 768 } }
        { tick-interval-micros $[ 60 fps ] }
    } ;
