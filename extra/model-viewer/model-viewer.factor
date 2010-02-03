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
specialized-vectors literals fry xml
xml.traversal sequences.deep destructors math.bitwise opengl.gl
game.models.obj game.models.loader game.models.collada ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
SPECIALIZED-VECTOR: uint
IN: model-viewer

GLSL-SHADER: model-vertex-shader vertex-shader
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

GLSL-SHADER: model-fragment-shader fragment-shader
varying vec2 texit;
varying vec3 norm;
void main()
{
    gl_FragColor = vec4(texit, 0, 1) + vec4(norm, 1);
}
;

GLSL-PROGRAM: model-program
    model-vertex-shader model-fragment-shader ;

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

UNIFORM-TUPLE: model-uniforms < mvp-uniforms
    { "light-position" vec3-uniform  f } ;

TUPLE: model-state
    models
    vertex-arrays
    index-vectors ;

TUPLE: model-world < wasd-world
    { model-state model-state } ;

VERTEX-FORMAT: model-vertex
    { "POSITION"   float-components 3 f }
    { "NORMAL" float-components 3 f }
    { "TEXCOORD" float-components 2 f } ;

VERTEX-FORMAT: debug-vertex
    { "POSITION" float-components 3 f }
    { "COLOR"    float-components 3 f } ;

TUPLE: vbo vertex-buffer index-buffer index-count vertex-format ;

: <model-buffers> ( models -- buffers )
    [
        {
            [ attribute-buffer>> underlying>> static-upload draw-usage vertex-buffer byte-array>buffer ]
            [ index-buffer>> underlying>> static-upload draw-usage index-buffer byte-array>buffer ]
            [ index-buffer>> length ]
            [ vertex-format>> ]
        } cleave vbo boa
    ] map ;

: fill-model-state ( model-state -- )
    dup models>> <model-buffers>
    [
        [
            [ vertex-buffer>> model-program <program-instance> ]
            [ vertex-format>> ] bi buffer>vertex-array
        ] map >>vertex-arrays drop
    ]
    [
        [
            [ index-buffer>> ] [ index-count>> ] bi
            '[ _ 0 <buffer-ptr> _ uint-indexes <index-elements> ] call
        ] map >>index-vectors drop
    ] 2bi ;

: model-files ( -- files )
    { "C:/Users/erikc/Downloads/test2.dae"
      "C:/Users/erikc/Downloads/Sponza.obj" } ;

: <model-state> ( -- model-state )
    model-state new
    model-files [ load-models ] [ append ] map-reduce >>models ;

M: model-world begin-game-world
    init-gpu
    { 0.0 0.0 2.0 } 0 0 set-wasd-view
    <model-state> [ fill-model-state drop ] [ >>model-state drop ] 2bi ;

: <model-uniforms> ( world -- uniforms )
    [ wasd-mv-matrix ] [ wasd-p-matrix ] bi
    { -10000.0 10000.0 10000.0 } ! light position
    model-uniforms boa ;

: draw-line ( world from to color -- )
    [ 3 head ] tri@ dup -rot append -rot append swap append >float-array
    underlying>> stream-upload draw-usage vertex-buffer byte-array>buffer
    debug-program <program-instance> debug-vertex buffer>vertex-array
    
    { 0 1 } >uint-array stream-upload draw-usage index-buffer byte-array>buffer
    2 '[ _ 0 <buffer-ptr> _ uint-indexes <index-elements> ] call
    
    rot <model-uniforms>

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
          
: draw-model ( world -- )
    0 0 0 0 glClearColor 
    1 glClearDepth
    HEX: ffffffff glClearStencil
    { GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT GL_STENCIL_BUFFER_BIT } flags glClear

    [
        triangle-fill dup t <triangle-state> set-gpu-state
        face-ccw cull-back <triangle-cull-state> set-gpu-state
        
        cmp-less <depth-state> set-gpu-state
        [ model-state>> vertex-arrays>> ]
        [ model-state>> index-vectors>> ]
        [ <model-uniforms> ]
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

M: model-world draw-world*
    draw-model ;

M: model-world wasd-movement-speed drop 1/4. ;
M: model-world wasd-near-plane drop 1/32. ;
M: model-world wasd-far-plane drop 1024.0 ;

GAME: model-viewer {
        { world-class model-world }
        { title "Model Viewer" }
        { pixel-format-attributes { windowed double-buffered } }
        { grab-input? t }
        { use-game-input? t }
        { pref-dim { 1024 768 } }
        { tick-interval-micros $[ 60 fps ] }
    } ;
