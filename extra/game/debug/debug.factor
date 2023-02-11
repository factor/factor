! Copyright (C) 2010 Erik Charlebois
! See https://factorcode.org/license.txt for BSD license.

USING: accessors alien.c-types alien.data arrays circular colors
columns destructors fonts gpu.buffers gpu.render gpu.shaders
gpu.state gpu.textures images kernel literals locals make math
math.constants math.functions math.vectors sequences
specialized-arrays typed ui.text ;

FROM: alien.c-types => float ;
SPECIALIZED-ARRAYS: float uint ;
IN: game.debug

<PRIVATE
! Vertex shader for debug shapes
GLSL-SHADER: debug-shapes-vertex-shader vertex-shader
uniform   mat4 u_mvp_matrix;
attribute vec3 a_position;
attribute vec3 a_color;
varying   vec3 v_color;
void main()
{
    gl_Position = u_mvp_matrix * vec4(a_position, 1.0);
    gl_PointSize = 5.0;
    v_color = a_color;
}
;

GLSL-SHADER: debug-shapes-fragment-shader fragment-shader
varying vec3 v_color;
void main()
{
    gl_FragColor = vec4(v_color, 1.0);
}
;

VERTEX-FORMAT: debug-shapes-vertex-format
    { "a_position" float-components 3 f }
    { "a_color"    float-components 3 f } ;

UNIFORM-TUPLE: debug-shapes-uniforms
    { "u_mvp_matrix" mat4-uniform f } ;

GLSL-PROGRAM: debug-shapes-program debug-shapes-vertex-shader
debug-shapes-fragment-shader debug-shapes-vertex-format ;

! Vertex shader for debug text
GLSL-SHADER: debug-text-vertex-shader vertex-shader
attribute vec2 a_position;
attribute vec2 a_texcoord;
varying   vec2 v_texcoord;
void main()
{
    gl_Position = vec4(a_position, 0.0, 1.0);
    v_texcoord  = a_texcoord;
}
;

GLSL-SHADER: debug-text-fragment-shader fragment-shader
uniform sampler2D u_text_map;
uniform vec3 u_background_color;
varying vec2 v_texcoord;
void main()
{
    vec4 c = texture2D(u_text_map, v_texcoord);
    if (c.xyz == u_background_color)
        discard;
    else
        gl_FragColor = c;
}
;

VERTEX-FORMAT: debug-text-vertex-format
    { "a_position" float-components 2 f }
    { "a_texcoord" float-components 2 f } ;

UNIFORM-TUPLE: debug-text-uniforms
    { "u_text_map"         texture-uniform f }
    { "u_background_color" vec3-uniform    f } ;

GLSL-PROGRAM: debug-text-program debug-text-vertex-shader
debug-text-fragment-shader debug-text-vertex-format ;

CONSTANT: debug-text-font
    T{ font
        { name       "monospace"  }
        { size       16           }
        { bold?      f            }
        { italic?    f            }
        { foreground COLOR: white }
        { background COLOR: black } }

CONSTANT: debug-text-texture-parameters
    T{ texture-parameters
        { wrap              repeat-texcoord }
        { min-filter        filter-linear   }
        { min-mipmap-filter f               } }

: text>image ( string color -- image )
    debug-text-font clone swap >>foreground swap string>image drop ;

:: image>texture ( image -- texture )
    image [ component-order>> ] [ component-type>> ] bi
    debug-text-texture-parameters <texture-2d> &dispose
    [ 0 image allocate-texture-image ] keep ;

:: screen-quad ( image pt dim -- float-array )
    pt dim v/ 2.0 v*n 1.0 v-n
    dup image dim>> dim v/ 2.0 v*n v+
    [ first2 ] bi@ :> ( x0 y0 x1 y1 )
    image upside-down?>>
    [ { x0 y0 0 0 x1 y0 1 0 x1 y1 1 1 x0 y1 0 1 } ]
    [ { x0 y0 0 1 x1 y0 1 1 x1 y1 1 0 x0 y1 0 0 } ]
    if float >c-array ;

: debug-text-uniform-variables ( string color -- image uniforms )
    text>image dup image>texture
    float-array{ 0.0 0.0 0.0 }
    debug-text-uniforms boa swap ;

: debug-text-vertex-array ( image pt dim -- vertex-array )
    screen-quad stream-upload draw-usage vertex-buffer byte-array>buffer &dispose
    debug-text-program <program-instance> <vertex-array> &dispose ;

: debug-text-index-buffer ( -- index-buffer )
    uint-array{ 0 1 2 2 3 0 } stream-upload draw-usage index-buffer
    byte-array>buffer &dispose 0 <buffer-ptr> 6 uint-indexes <index-elements> ;

: debug-text-render ( uniforms vertex-array index-buffer -- )
    [
        {
            { "primitive-mode" [ 3drop triangles-mode ] }
            { "uniforms"       [ 2drop ] }
            { "vertex-array"   [ drop nip ] }
            { "indexes"        [ 2nip ] }
        } 3<render-set> render
    ] with-destructors ;

: debug-shapes-vertex-array ( sequence -- vertex-array )
    stream-upload draw-usage vertex-buffer byte-array>buffer &dispose
    debug-shapes-program <program-instance> &dispose <vertex-array> &dispose ;

: draw-debug-primitives ( mode primitives mvp-matrix -- )
    f origin-upper-left 1.0 <point-state> set-gpu-state
    {
        { "primitive-mode"     [ 2drop ] }
        { "uniforms"           [ 2nip debug-shapes-uniforms boa ] }
        { "vertex-array"       [ drop nip debug-shapes-vertex-array ] }
        { "indexes"            [ drop nip length 0 swap <index-range> ] }
    } 3<render-set> render ;

CONSTANT: box-vertices
    { { {  1  1  1 } {  1  1 -1 } }
      { {  1  1  1 } {  1 -1  1 } }
      { {  1  1  1 } { -1  1  1 } }
      { { -1 -1 -1 } { -1 -1  1 } }
      { { -1 -1 -1 } { -1  1 -1 } }
      { { -1 -1 -1 } {  1 -1 -1 } }
      { { -1 -1  1 } { -1  1  1 } }
      { { -1 -1  1 } {  1 -1  1 } }
      { { -1  1 -1 } { -1  1  1 } }
      { { -1  1 -1 } {  1  1 -1 } }
      { {  1 -1 -1 } {  1 -1  1 } }
      { {  1 -1 -1 } {  1  1 -1 } } }

CONSTANT: cylinder-vertices
    $[ 12 <iota> [ 2pi 12 / * [ cos ] [ drop 0.0 ] [ sin ] tri 3array ] map ]

:: scale-cylinder-vertices ( radius half-height verts -- bot-verts top-verts )
    verts
    [ [ radius v*n { 0 half-height 0 } v- ] map ]
    [ [ radius v*n { 0 half-height 0 } v+ ] map ] bi ;
PRIVATE>

: debug-point ( pt color -- )
    [ first3 [ , ] tri@ ]
    [ [ red>> , ] [ green>> , ] [ blue>> , ] tri ]
    bi* ; inline

: debug-line ( from to color -- )
    dup swapd [ debug-point ] 2bi@ ; inline

: debug-axes ( pt mat -- )
    [ 0 <column> normalize over v+ COLOR: red debug-line ]
    [ 1 <column> normalize over v+ COLOR: green debug-line ]
    [ 2 <column> normalize over v+ COLOR: blue debug-line ]
    2tri ; inline

:: debug-box ( pt half-widths color -- )
    box-vertices [
        first2 [ half-widths v* pt v+ ] bi@ color debug-line
    ] each ; inline

:: debug-circle ( points color -- )
    points dup <circular> [ 1 swap change-circular-start ] keep
    [ color debug-line ] 2each ; inline

:: debug-cylinder ( pt half-height radius color -- )
    radius half-height cylinder-vertices scale-cylinder-vertices
    [ [ color debug-circle ] bi@ ]
    [ color '[ _ debug-line ] 2each ] 2bi ; inline

TYPED: draw-debug-lines ( lines: float-array mvp-matrix -- )
    [ lines-mode -rot draw-debug-primitives ] with-destructors ; inline

TYPED: draw-debug-points ( points: float-array mvp-matrix -- )
    [ points-mode -rot draw-debug-primitives ] with-destructors ; inline

TYPED: draw-text ( string color: rgba pt dim -- )
    [
        [ debug-text-uniform-variables ] 2dip
        debug-text-vertex-array
        debug-text-index-buffer
        debug-text-render
    ] with-destructors ; inline
