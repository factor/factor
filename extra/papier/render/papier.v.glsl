#version 150

uniform mat4 p_matrix;
uniform vec3 eye;

in vec3 vertex;
in vec2 texcoord;
in vec4 color;

out vec2 frag_texcoord;
out vec4 frag_color;

void
main()
{
    gl_Position = p_matrix * vec4(vertex - eye, 1.0);
    frag_texcoord = texcoord;
    frag_color = color;
}
