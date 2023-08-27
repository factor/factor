! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays destructors gpu.buffers gpu.framebuffers gpu.render
gpu.shaders gpu.state gpu.textures images kernel math
math.rectangles opengl.gl sequences specialized-arrays ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
IN: gpu.util

CONSTANT: environment-cube-map-mv-matrices
    H{
        { +X {
            {  0.0  0.0 -1.0  0.0 }
            {  0.0 -1.0  0.0  0.0 }
            { -1.0  0.0  0.0  0.0 }
            {  0.0  0.0  0.0  1.0 }
        } }
        { +Y {
            {  1.0  0.0  0.0  0.0 }
            {  0.0  0.0  1.0  0.0 }
            {  0.0 -1.0  0.0  0.0 }
            {  0.0  0.0  0.0  1.0 }
        } }
        { +Z {
            {  1.0  0.0  0.0  0.0 }
            {  0.0 -1.0  0.0  0.0 }
            {  0.0  0.0 -1.0  0.0 }
            {  0.0  0.0  0.0  1.0 }
        } }
        { -X {
            {  0.0  0.0  1.0  0.0 }
            {  0.0 -1.0  0.0  0.0 }
            {  1.0  0.0  0.0  0.0 }
            {  0.0  0.0  0.0  1.0 }
        } }
        { -Y {
            {  1.0  0.0  0.0  0.0 }
            {  0.0  0.0 -1.0  0.0 }
            {  0.0  1.0  0.0  0.0 }
            {  0.0  0.0  0.0  1.0 }
        } }
        { -Z {
            { -1.0  0.0  0.0  0.0 }
            {  0.0 -1.0  0.0  0.0 }
            {  0.0  0.0  1.0  0.0 }
            {  0.0  0.0  0.0  1.0 }
        } }
    }

GLSL-SHADER: window-vertex-shader vertex-shader
attribute vec2 vertex;
varying vec2 texcoord;
void main()
{
    texcoord = vertex * vec2(0.5) + vec2(0.5);
    gl_Position = vec4(vertex, 0.0, 1.0);
}
;

GLSL-SHADER: window-fragment-shader fragment-shader
uniform sampler2D texture;
varying vec2 texcoord;
void main()
{
    gl_FragColor = texture2D(texture, texcoord);
}
;

VERTEX-FORMAT: window-vertex-format
    { "vertex" float-components 2 f } ;

UNIFORM-TUPLE: window-uniforms
    { "texture" texture-uniform f } ;

GLSL-PROGRAM: window-program window-vertex-shader window-fragment-shader window-vertex-format ;

GLSL-SHADER: window-point-vertex-shader vertex-shader
uniform float point_size;
attribute vec2 vertex;
void main()
{
    gl_Position  = vec4(vertex, 0.0, 1.0);
    gl_PointSize = point_size;
}
;

GLSL-SHADER: window-point-fragment-shader fragment-shader
#version 120
uniform sampler2D texture;
void main()
{
    gl_FragColor = texture2D(texture, gl_PointCoord);
}
;

UNIFORM-TUPLE: window-point-uniforms
    { "texture"    texture-uniform f }
    { "point_size" float-uniform   f } ;

GLSL-PROGRAM: window-point-program window-point-vertex-shader window-point-fragment-shader window-vertex-format ;

CONSTANT: window-vertexes
    float-array{
        -1.0 -1.0
        -1.0  1.0
         1.0 -1.0
         1.0  1.0
    }

: <window-vertex-buffer> ( -- buffer )
    window-vertexes
    static-upload draw-usage vertex-buffer
    byte-array>buffer ; inline

: <window-vertex-array> ( program-instance -- vertex-array )
    [ <window-vertex-buffer> ] dip window-vertex-format <vertex-array*> ; inline

:: <2d-render-texture> ( dim order type -- renderbuffer texture )
    order type
    T{ texture-parameters
        { wrap clamp-texcoord-to-edge }
        { min-filter filter-linear }
        { min-mipmap-filter f } }
    <texture-2d> [
        0 <texture-2d-attachment> 1array f f dim <framebuffer>
        dup { { default-attachment { 0 0 0 } } } clear-framebuffer
    ] keep ;

: draw-texture ( texture dim -- )
    { 0 0 } swap <rect> <viewport-state> set-gpu-state
    {
        { "primitive-mode" [ drop triangle-strip-mode ] }
        { "uniforms"       [ window-uniforms boa ] }
        { "vertex-array"   [ drop window-program <program-instance> <window-vertex-array> &dispose ] }
        { "indexes"        [ drop T{ index-range f 0 4 } ] }
    } <render-set> render ;

:: <streamed-vertex-array> ( verts program-instance -- vertex-array )
    verts stream-upload draw-usage vertex-buffer byte-array>buffer &dispose
    program-instance <vertex-array> &dispose ;

: (blended-point-sprite-batch) ( verts framebuffer texture point-size dim -- )
    f eq-add func-one func-one <blend-mode> dup <blend-state> set-gpu-state
    f origin-upper-left 1.0 <point-state> set-gpu-state
    GL_POINT_SPRITE glEnable
    { 0 0 } swap <rect> <viewport-state> set-gpu-state
    window-point-uniforms boa {
        { "primitive-mode" [ 3drop points-mode ] }
        { "uniforms"       [ 2nip ] }
        { "vertex-array"   [ 2drop window-point-program <program-instance> <streamed-vertex-array> ] }
        { "indexes"        [ 2drop length 2 / 0 swap <index-range> ] }
        { "framebuffer"    [ drop nip ] }
    } 3<render-set> render ;

:: blended-point-sprite-batch ( verts texture point-size dim -- texture )
    dim RGB float-components <2d-render-texture> :> ( target-framebuffer target-texture )
    verts target-framebuffer texture point-size dim (blended-point-sprite-batch)
    target-framebuffer dispose
    target-texture ;
