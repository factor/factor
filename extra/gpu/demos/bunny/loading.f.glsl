#version 110

uniform sampler2D loading_texture;

varying vec2 texcoord;

void
main()
{
    gl_FragColor = texture2D(loading_texture, texcoord);
}
