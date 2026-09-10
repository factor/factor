#version 150

uniform sampler2D atlas;

in vec2 frag_texcoord;
in vec4 frag_color;

out vec4 fragment_color;

void main()
{
    fragment_color = frag_color * texture(atlas, frag_texcoord);
}
