#version 110

uniform mat4 p_matrix;
uniform vec3 eye;

attribute vec3 vertex;
attribute vec2 texcoord;
attribute vec4 color;

varying vec2 frag_texcoord;
varying vec4 frag_color;

void
main()
{
    gl_Position = p_matrix * vec4(vertex - eye, 1.0);
    frag_texcoord = texcoord;
    frag_color = color;
}
