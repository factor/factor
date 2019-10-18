#version 110

uniform mat4 mv_matrix, p_matrix;
uniform vec3 light_position;

attribute vec3 vertex, normal;

varying vec3 frag_normal;
varying vec3 frag_light_direction;
varying vec3 frag_eye_direction;

void
main()
{
    vec4 position = mv_matrix * vec4(vertex, 1.0);

    gl_Position = p_matrix * position;
    frag_normal = (mv_matrix * vec4(normal, 0.0)).xyz;
    frag_light_direction = (mv_matrix * vec4(light_position, 1.0)).xyz - position.xyz;
    frag_eye_direction = position.xyz;

}
