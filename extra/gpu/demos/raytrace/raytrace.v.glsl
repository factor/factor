#version 110

uniform mat4 mv_inv_matrix;
uniform vec2 fov;

attribute vec2 vertex;

varying vec3 ray_origin, ray_direction;

void
main()
{
    gl_Position = vec4(vertex, 0.0, 1.0);
    ray_direction = (mv_inv_matrix * vec4(fov * vertex, -1.0, 0.0)).xyz;
    ray_origin = (mv_inv_matrix * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
}

