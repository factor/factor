! Copyright (C) 2010 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: gpu.render gpu.shaders gpu.util ;
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
