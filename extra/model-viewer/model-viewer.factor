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
specialized-vectors literals fry
sequences.deep destructors math.bitwise opengl.gl
game.models game.models.obj game.models.loader game.models.collada
prettyprint images.tga ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
SPECIALIZED-VECTOR: uint
IN: model-viewer

GLSL-SHADER: obj-vertex-shader vertex-shader
uniform mat4 mv_matrix;
uniform mat4 p_matrix;

attribute vec3 POSITION;
attribute vec3 TEXCOORD;
attribute vec3 NORMAL;

varying vec2 texcoord_fs;
varying vec3 normal_fs;
varying vec3 world_pos_fs;

void main()
{
    vec4 position = mv_matrix * vec4(POSITION, 1.0);
    gl_Position   = p_matrix * position;
    world_pos_fs  = POSITION;
    texcoord_fs   = TEXCOORD;
    normal_fs     = NORMAL;
}
;

GLSL-SHADER: obj-fragment-shader fragment-shader
uniform mat4 mv_matrix, p_matrix;
uniform sampler2D map_Ka;
uniform sampler2D map_bump;
uniform vec3 Ka;
uniform vec3 view_pos;
uniform vec3 light;
varying vec2 texcoord_fs;
varying vec3 normal_fs;
varying vec3 world_pos_fs;
void main()
{
    vec4 d = texture2D(map_Ka, texcoord_fs.xy);
    vec3 b = texture2D(map_bump, texcoord_fs.xy).xyz;
    vec3 n = normal_fs;
    vec3 v = normalize(view_pos - world_pos_fs);
    vec3 l = normalize(light);
    vec3 h = normalize(v + l);
    float cosTh = saturate(dot(n, l));
    gl_FragColor = d * cosTh
                 + d * 0.5 * cosTh * pow(saturate(dot(n, h)), 10.0) ;
}
;

GLSL-PROGRAM: obj-program
    obj-vertex-shader obj-fragment-shader ;

UNIFORM-TUPLE: model-uniforms < mvp-uniforms
    { "map_Ka"    texture-uniform   f }
    { "map_bump"  texture-uniform   f }
    { "Ka"        vec3-uniform      f }
    { "light"     vec3-uniform      f }
    { "view_pos"  vec3-uniform      f }
    ;

TUPLE: model-state
    models
    vertex-arrays
    index-vectors
    textures
    bumps
    kas ;

TUPLE: model-world < wasd-world model-path model-state ;

TUPLE: vbo
    vertex-buffer
    index-buffer index-count vertex-format texture bump ka ;

: white-image ( -- image )
    { 1 1 } BGR ubyte-components f
    B{ 255 255 255 } image boa ;

: up-image ( -- image )
    { 1 1 } BGR ubyte-components f
    B{ 0 0 0 } image boa ;
        
: make-texture ( pathname alt -- texture )
    swap [ nip load-image ] [ ] if*
    [
        [ component-order>> ]
        [ component-type>> ] bi
        T{ texture-parameters
           { wrap repeat-texcoord }
           { min-filter filter-linear }
           { min-mipmap-filter f } }
        <texture-2d>
    ]
    [
        0 swap [ allocate-texture-image ] 3keep 2drop
    ] bi ;
        
: <model-buffers> ( models -- buffers )
    [
        {
            [ attribute-buffer>> underlying>> static-upload draw-usage vertex-buffer byte-array>buffer ]
            [ index-buffer>> underlying>> static-upload draw-usage index-buffer byte-array>buffer ]
            [ index-buffer>> length ]
            [ vertex-format>> ]
            [ material>> ambient-map>> white-image make-texture ]
            [ material>> bump-map>> up-image make-texture ]
            [ material>> ambient-reflectivity>> ]
        } cleave vbo boa
    ] map ;

: fill-model-state ( model-state -- )
    dup models>> <model-buffers>
    {
        [
            [
                [ vertex-buffer>> obj-program <program-instance> ]
                [ vertex-format>> ] bi buffer>vertex-array
            ] map >>vertex-arrays drop
        ]
        [
            [
                [ index-buffer>> ] [ index-count>> ] bi
                '[ _ 0 <buffer-ptr> _ uint-indexes <index-elements> ] call
            ] map >>index-vectors drop
        ]
        [ [ texture>> ] map >>textures drop ]
        [ [ bump>> ] map >>bumps drop ]
        [ [ ka>> ] map >>kas drop ]
    } 2cleave ;

: <model-state> ( model-world -- model-state )
    model-path>> 1array model-state new swap
    [ load-models ] [ append ] map-reduce >>models ;

:: <model-uniforms> ( world -- uniforms )
    world model-state>>
    [ textures>> ] [ bumps>> ] [ kas>> ] tri
    [| texture bump ka |
        world wasd-mv-matrix
        world wasd-p-matrix
        texture bump ka
        { 0.5 0.5 0.5 }
        world location>>
        model-uniforms boa
    ] 3map ;

: clear-screen ( -- )
    0 0 0 0 glClearColor 
    1 glClearDepth
    HEX: ffffffff glClearStencil
    { GL_COLOR_BUFFER_BIT
      GL_DEPTH_BUFFER_BIT
      GL_STENCIL_BUFFER_BIT } flags glClear ;
    
: draw-model ( world -- )
    clear-screen
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
    ] 3each ;

TUPLE: model-attributes < game-attributes model-path ;

M: model-world draw-world* draw-model ;
M: model-world wasd-movement-speed drop 1/4. ;
M: model-world wasd-near-plane drop 1/32. ;
M: model-world wasd-far-plane drop 1024.0 ;
M: model-world begin-game-world
    init-gpu
    { 0.0 0.0 2.0 } 0 0 set-wasd-view
    [ <model-state> [ fill-model-state ] keep ] [ (>>model-state) ] bi ;
M: model-world apply-world-attributes
    {
        [ model-path>> >>model-path ]
        [ call-next-method ]
    } cleave ;

:: open-model-viewer ( model-path -- )
    [
        f
        T{ model-attributes
           { world-class model-world }
           { grab-input? t }
           { title "Model Viewer" }
           { pixel-format-attributes
             { windowed double-buffered }
           }
           { pref-dim { 1024 768 } }
           { tick-interval-micros 16666 }
           { use-game-input? t }
           { model-path model-path }
        }
        clone
        open-window
    ] with-ui ;
