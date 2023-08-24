USING: accessors arrays bunny.model combinators destructors
kernel multiline opengl.capabilities opengl.gl opengl.shaders ;
IN: bunny.cel-shaded

STRING: vertex-shader-source
varying vec3 position, normal, viewer;

void
main()
{
    gl_Position = ftransform();

    position = gl_Vertex.xyz;
    normal = gl_Normal;
    viewer = vec3(0, 0, 1) * gl_NormalMatrix;
}

;

STRING: cel-shaded-fragment-shader-lib-source
varying vec3 position, normal, viewer;
uniform vec3 light_direction;
uniform vec4 color;
uniform vec4 ambient, diffuse;
uniform float shininess;

float
modulate(vec3 direction, vec3 normal)
{
    return dot(direction, normal) * 0.5 + 0.5;
}

float
cel(float m)
{
    return smoothstep(0.25, 0.255, m) * 0.4 + smoothstep(0.695, 0.70, m) * 0.5;
}

vec4
cel_light()
{
    vec3 direction = normalize(light_direction - position);
    vec3 reflection = reflect(direction, normal);
    vec4 ad = (ambient + diffuse * vec4(vec3(cel(modulate(direction, normal))), 1));
    float s = cel(pow(max(dot(-reflection, viewer), 0.0), shininess));
    return ad * color + vec4(vec3(s), 0);
}

;

STRING: cel-shaded-fragment-shader-main-source
vec4 cel_light();

void
main()
{
    gl_FragColor = cel_light();
}

;

TUPLE: bunny-cel-shaded program ;

: cel-shading-supported? ( -- ? )
    "2.0" { "GL_ARB_shader_objects" }
    has-gl-version-or-extensions? ;

: <bunny-cel-shaded> ( gadget -- draw )
    drop
    cel-shading-supported? [
        bunny-cel-shaded new
        vertex-shader-source <vertex-shader> check-gl-shader
        cel-shaded-fragment-shader-lib-source <fragment-shader> check-gl-shader
        cel-shaded-fragment-shader-main-source <fragment-shader> check-gl-shader
        3array <gl-program> check-gl-program
        >>program
    ] [ f ] if ;

: (draw-cel-shaded-bunny) ( geom program -- )
    [
        {
            [ "light_direction" glGetUniformLocation 1.0 -1.0 1.0 glUniform3f ]
            [ "color"           glGetUniformLocation 0.6 0.5 0.5 1.0 glUniform4f ]
            [ "ambient"         glGetUniformLocation 0.2 0.2 0.2 0.2 glUniform4f ]
            [ "diffuse"         glGetUniformLocation 0.8 0.8 0.8 0.8 glUniform4f ]
            [ "shininess"       glGetUniformLocation 100.0 glUniform1f ]
        } cleave bunny-geom
    ] with-gl-program ;

M: bunny-cel-shaded draw-bunny
    program>> (draw-cel-shaded-bunny) ;

M: bunny-cel-shaded dispose
    program>> delete-gl-program ;
