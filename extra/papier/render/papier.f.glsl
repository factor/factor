#version 110

uniform sampler2D atlas;

varying vec2 frag_texcoord;
varying vec4 frag_color;

void main()
{
    gl_FragColor = frag_color * texture2D(atlas, frag_texcoord);
}
