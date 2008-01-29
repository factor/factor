USING: arrays bunny combinators.lib io io.files kernel
       math math.functions multiline
       opengl opengl.gl opengl-demo-support
       sequences ui ui.gadgets ui.render ;
IN: cel-shading

TUPLE: cel-shading-gadget model program ;

: <cel-shading-gadget> ( -- cel-shading-gadget )
    0.0 0.0 0.375 <demo-gadget>
    maybe-download read-model
    { set-delegate set-cel-shading-gadget-model } cel-shading-gadget construct ;

STRING: cel-shading-vertex-shader-source
varying vec3 position, normal;

void
main()
{
    gl_Position = ftransform();
    
    position = gl_Vertex.xyz;
    normal = gl_Normal;
}

;

STRING: cel-shading-fragment-shader-source
varying vec3 position, normal;
uniform vec3 light_direction;
uniform vec4 color;
uniform vec4 ambient, diffuse;

float
smooth_modulate(vec3 direction, vec3 normal)
{
    return clamp(dot(direction, normal), 0.0, 1.0);
}

float
modulate(vec3 direction, vec3 normal)
{
    float m = smooth_modulate(direction, normal);
    return smoothstep(0.0, 0.01, m) * 0.4 + smoothstep(0.49, 0.5, m) * 0.5;
}

void
main()
{
    vec3 direction = normalize(light_direction - position);
    gl_FragColor = ambient + diffuse * color * vec4(vec3(modulate(direction, normal)), 1); 
}

;

: cel-shading-program ( -- program )
    cel-shading-vertex-shader-source cel-shading-fragment-shader-source
    <simple-gl-program> ;

M: cel-shading-gadget graft* ( gadget -- )
    "2.0" { "GL_ARB_shader_objects" } require-gl-version-or-extensions
    0.0 0.0 0.0 1.0 glClearColor
    GL_CULL_FACE glEnable
    GL_DEPTH_TEST glEnable
    cel-shading-program swap set-cel-shading-gadget-program ;

M: cel-shading-gadget ungraft* ( gadget -- )
    cel-shading-gadget-program delete-gl-program ;

: cel-shading-draw-setup ( gadget -- gadget )
    [ demo-gadget-set-matrices ] keep
    [ cel-shading-gadget-program
        { [ "light_direction" glGetUniformLocation -25.0 45.0 80.0 glUniform3f ]
          [ "color" glGetUniformLocation 0.6 0.5 0.5 1.0 glUniform4f ]
          [ "ambient" glGetUniformLocation 0.2 0.2 0.2 0.2 glUniform4f ]
          [ "diffuse" glGetUniformLocation 0.8 0.8 0.8 0.8 glUniform4f ] } call-with
    ] keep ;

M: cel-shading-gadget draw-gadget* ( gadget -- )
    dup cel-shading-gadget-program [
        cel-shading-draw-setup
        0.0 -0.12 0.0 glTranslatef
        cel-shading-gadget-model first3 draw-bunny
    ] with-gl-program ;

: cel-shading-window ( -- )
    [ <cel-shading-gadget> "Cel Shading" open-window ] with-ui ;
    
MAIN: cel-shading-window
