#version 110

uniform mat4 p_matrix;
uniform mat4 mv_matrix;

attribute vec3 vertex;
attribute vec4 color;

varying vec4 frag_color;

void main()
{
    gl_Position = p_matrix * mv_matrix * vec4(vertex, 1.0);
    frag_color = color;
}
