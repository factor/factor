! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: destructors gpu.render gpu.shaders gpu.state gpu.textures
gpu.util images kernel math math.rectangles sequences ;
IN: gpu.effects.blur

GLSL-SHADER: blur-fragment-shader fragment-shader
uniform sampler2D texture;
uniform bool horizontal;
uniform float blurSize;
varying vec2 texcoord;
void main()
{
    vec4 col = 0.16 * texture2D(texture, texcoord);
    if (horizontal)
    {
        vec2 blurX1 = vec2(blurSize, 0.0);
        vec2 blurX2 = vec2(blurSize * 2.0, 0.0);
        vec2 blurX3 = vec2(blurSize * 3.0, 0.0);
        vec2 blurX4 = vec2(blurSize * 4.0, 0.0);
        col += 0.15 * (  texture2D(texture, texcoord - blurX1)
                       + texture2D(texture, texcoord + blurX1));
        col += 0.12 * (  texture2D(texture, texcoord - blurX2)
                       + texture2D(texture, texcoord + blurX2));
        col += 0.09 * (  texture2D(texture, texcoord - blurX3)
                       + texture2D(texture, texcoord + blurX3));
        col += 0.05 * (  texture2D(texture, texcoord - blurX4)
                       + texture2D(texture, texcoord + blurX4));
    }
    else
    {
        vec2 blurY1 = vec2(0.0, blurSize);
        vec2 blurY2 = vec2(0.0, blurSize * 2.0);
        vec2 blurY3 = vec2(0.0, blurSize * 3.0);
        vec2 blurY4 = vec2(0.0, blurSize * 4.0);
        col += 0.15 * (  texture2D(texture, texcoord - blurY1)
                       + texture2D(texture, texcoord + blurY1));
        col += 0.12 * (  texture2D(texture, texcoord - blurY2)
                       + texture2D(texture, texcoord + blurY2));
        col += 0.09 * (  texture2D(texture, texcoord - blurY3)
                       + texture2D(texture, texcoord + blurY3));
        col += 0.05 * (  texture2D(texture, texcoord - blurY4)
                       + texture2D(texture, texcoord + blurY4));
    }
    gl_FragColor = col;
}
;

UNIFORM-TUPLE: blur-uniforms
    { "texture"    texture-uniform f }
    { "horizontal" bool-uniform    f }
    { "blurSize"   float-uniform   f } ;

GLSL-PROGRAM: blur-program window-vertex-shader blur-fragment-shader window-vertex-format ;

:: (blur) ( texture horizontal? framebuffer dim -- )
    { 0 0 } dim <rect> <viewport-state> set-gpu-state
    texture horizontal? 1.0 dim horizontal? [ first ] [ second ] if / blur-uniforms boa framebuffer {
        { "primitive-mode" [ 2drop triangle-strip-mode ] }
        { "uniforms"       [ drop ] }
        { "vertex-array"   [ 2drop blur-program <program-instance> <window-vertex-array> &dispose ] }
        { "indexes"        [ 2drop T{ index-range f 0 4 } ] }
        { "framebuffer"    [ nip ] }
    } 2<render-set> render ;

:: blur ( texture horizontal? -- texture )
    texture 0 texture-dim :> dim
    dim RGB float-components <2d-render-texture> :> ( target-framebuffer target-texture )
    texture horizontal? target-framebuffer dim (blur)
    target-framebuffer dispose
    target-texture ;

: horizontal-blur ( texture -- texture ) t blur ; inline

: vertical-blur ( texture -- texture ) f blur ; inline

: discompose ( quot1 quot2 -- compose )
    '[ @ &dispose @ ] with-destructors ; inline

: gaussian-blur ( texture -- texture )
    [ horizontal-blur ] [ vertical-blur ] discompose ;
