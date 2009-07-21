#version 110

uniform mat4 mv_matrix, p_matrix;
uniform vec4 color, ambient, diffuse;
uniform float shininess;

varying vec3 frag_normal;
varying vec3 frag_light_direction;
varying vec3 frag_eye_direction;

float
cel(float d)
{
    return smoothstep(0.25, 0.255, d) * 0.4 + smoothstep(0.695, 0.70, d) * 0.5;
}

vec4
cel_light()
{
    vec3 normal = normalize(frag_normal),
         light = normalize(frag_light_direction),
         eye = normalize(frag_eye_direction),
         reflection = reflect(light, normal);

    float d = dot(light, normal) * 0.5 + 0.5;
    float s = pow(max(dot(reflection, -eye), 0.0), shininess);

    vec4 amb_diff = ambient + diffuse * vec4(vec3(cel(d)), 1.0);
    vec4 spec = vec4(vec3(cel(s)), 0.0);

    return amb_diff * color + spec;
}

void
main()
{
    gl_FragData[0] = cel_light();
    gl_FragData[1] = vec4(frag_normal, 0.0);
}
