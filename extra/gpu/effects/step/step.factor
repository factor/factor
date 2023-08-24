! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: destructors gpu.render gpu.shaders gpu.state gpu.util
images kernel math.rectangles ;
IN: gpu.effects.step

GLSL-SHADER: step-fragment-shader fragment-shader
const vec4 luminance = vec4(0.3, 0.59, 0.11, 0.0);
uniform sampler2D texture;
uniform sampler2D ramp;
varying vec2 texcoord;
void main()
{
    vec4 col = texture2D(texture, texcoord);
    float l = dot(col, luminance);
    gl_FragColor = texture2D(ramp, vec2(l, 0.0));
}
;

UNIFORM-TUPLE: step-uniforms
    { "texture" texture-uniform f }
    { "ramp"    texture-uniform f } ;

GLSL-PROGRAM: step-program window-vertex-shader step-fragment-shader window-vertex-format ;

: (step-texture) ( texture ramp texture dim -- )
    { 0 0 } swap <rect> <viewport-state> set-gpu-state
    [ step-uniforms boa ] dip {
        { "primitive-mode" [ 2drop triangle-strip-mode ] }
        { "uniforms"       [ drop ] }
        { "vertex-array"   [ 2drop <window-vertex-buffer> step-program <program-instance> <vertex-array> ] }
        { "indexes"        [ 2drop T{ index-range f 0 4 } ] }
        { "framebuffer"    [ nip ] }
    } 2<render-set> render ;

:: step-texture ( texture ramp dim -- texture )
    dim RGB float-components <2d-render-texture> :> ( target-framebuffer target-texture )
    texture ramp target-framebuffer dim (step-texture)
    target-framebuffer dispose
    target-texture ;
