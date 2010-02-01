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
specialized-vectors literals game.models.collada fry xml xml.traversal sequences.deep

math.bitwise
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
attribute vec3 NORMAL;
attribute vec2 TEXCOORD;

varying vec2 texit;
varying vec3 norm;

void main()
{
    vec4 position = mv_matrix * vec4(POSITION, 1.0);
    gl_Position = p_matrix * position;
    texit = TEXCOORD;
    norm = NORMAL;
}
;

GLSL-SHADER: collada-fragment-shader fragment-shader
varying vec2 texit;
varying vec3 norm;
void main()
{
    gl_FragColor = vec4(texit, 0, 1) + vec4(norm, 1);
}
;

GLSL-PROGRAM: collada-program
    collada-vertex-shader collada-fragment-shader ;

GLSL-SHADER: debug-vertex-shader vertex-shader
uniform mat4 mv_matrix, p_matrix;
uniform vec3 light_position;

attribute vec3 POSITION;
attribute vec3 COLOR;
varying vec4 color;

void main()
{
    gl_Position = p_matrix * mv_matrix * vec4(POSITION, 1.0);
    color = vec4(COLOR, 1);
}
;

GLSL-SHADER: debug-fragment-shader fragment-shader
varying vec4 color;
void main()
{
    gl_FragColor = color;
}
;

GLSL-PROGRAM: debug-program debug-vertex-shader debug-fragment-shader ;

UNIFORM-TUPLE: collada-uniforms < mvp-uniforms
    { "light-position" vec3-uniform  f } ;

TUPLE: collada-state
    models
    vertex-arrays
    index-vectors ;

TUPLE: collada-world < wasd-world
    { collada collada-state } ;

VERTEX-FORMAT: collada-vertex
    { "POSITION"   float-components 3 f }
    { "NORMAL" float-components 3 f }
    { "TEXCOORD" float-components 2 f } ;

VERTEX-FORMAT: debug-vertex
    { "POSITION" float-components 3 f }
    { "COLOR"    float-components 3 f } ;

: <collada-buffers> ( models -- buffers )
!    drop
!    float-array{ -0.5 0 0 1 0 0 0 1 0 0 1 0 0.5 0 0 0 0 1 }
!    uint-array{ 0 1 2 }
!    f model boa 1array
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
    "C:/Users/erikc/Downloads/test2.dae"
    #! "/Users/erikc/Documents/mech.dae"
    file>xml "mesh" deep-tags-named [ mesh>models ] map flatten >>models ;

M: collada-world begin-game-world
    init-gpu
    { 0.0 0.0 2.0 } 0 0 set-wasd-view
    <collada-state> [ fill-collada-state drop ] [ >>collada drop ] 2bi ;

: <collada-uniforms> ( world -- uniforms )
    [ wasd-mv-matrix ] [ wasd-p-matrix ] bi
    { -10000.0 10000.0 10000.0 } ! light position
    collada-uniforms boa ;

: draw-line ( world from to color -- )
    [ 3 head ] tri@ dup -rot append -rot append swap append >float-array
    underlying>> stream-upload draw-usage vertex-buffer byte-array>buffer
    debug-program <program-instance> debug-vertex buffer>vertex-array
    
    { 0 1 } >uint-array stream-upload draw-usage index-buffer byte-array>buffer
    2 '[ _ 0 <buffer-ptr> _ uint-indexes <index-elements> ] call
    
    rot <collada-uniforms>

    {
        { "primitive-mode"     [ 3drop lines-mode ] }
        { "uniforms"           [ nip nip ] }
        { "vertex-array"       [ drop drop ] }
        { "indexes"            [ drop nip ] }
    } 3<render-set> render ;

: draw-lines ( world lines -- )
    3 <groups> [ first3 draw-line ] with each ; inline

: draw-axes ( world -- )
    { { 0 0 0 } { 1 0 0 } { 1 0 0 }
      { 0 0 0 } { 0 1 0 } { 0 1 0 }
      { 0 0 0 } { 0 0 1 } { 0 0 1 } } draw-lines ;
          
: draw-collada ( world -- )
    0 0 0 0 glClearColor 
    1 glClearDepth
    HEX: ffffffff glClearStencil
    { GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT GL_STENCIL_BUFFER_BIT } flags glClear

    [
        #! triangle-lines dup t <triangle-state> set-gpu-state
        face-ccw cull-back <triangle-cull-state> set-gpu-state
        cmp-less <depth-state> set-gpu-state
        [ collada>> vertex-arrays>> ]
        [ collada>> index-vectors>> ]
        [ <collada-uniforms> ]
        tri
        [
            {
                { "primitive-mode"     [ 3drop triangles-mode ] }
                { "uniforms"           [ nip nip ] }
                { "vertex-array"       [ drop drop ] }
                { "indexes"            [ drop nip ] }
            } 3<render-set> render
        ] curry 2each
    ]
    [
        cmp-always <depth-state> set-gpu-state
        draw-axes
    ]
    bi ;

M: collada-world draw-world*
    draw-collada ;

M: collada-world wasd-movement-speed drop 1/4. ;
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
