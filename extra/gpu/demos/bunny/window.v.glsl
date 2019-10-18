#version 110

uniform vec2 texcoord_scale;

attribute vec2 vertex;

varying vec2 texcoord;

void
main()
{
    texcoord = (vertex * texcoord_scale) * vec2(0.5) + vec2(0.5);
    gl_Position = vec4(vertex, 0.0, 1.0); 
}
