USING: kernel opengl opengl.demo-support opengl.gl opengl.textures
opengl.shaders opengl.framebuffers opengl.capabilities multiline
ui.gadgets accessors sequences ui.render ui math locals arrays
generalizations combinators ui.gadgets.worlds
literals ui.pixel-formats ;
IN: spheres

STRING: plane-vertex-shader
varying vec3 object_position;
void
main()
{
    object_position = gl_Vertex.xyz;
    gl_Position = ftransform();
}
;

STRING: plane-fragment-shader
uniform float checker_size_inv;
uniform vec4 checker_color_1, checker_color_2;
varying vec3 object_position;

bool
checker_color(vec3 p)
{
    vec3 pprime = checker_size_inv * object_position;
    return fract((floor(pprime.x) + floor(pprime.z)) * 0.5) == 0.0;
}

void
main()
{
    float distance_factor = (gl_FragCoord.z * 0.5 + 0.5);
    distance_factor = pow(distance_factor, 500.0)*0.5;
    
    gl_FragColor = checker_color(object_position)
        ? mix(checker_color_1, checker_color_2, distance_factor)
        : mix(checker_color_2, checker_color_1, distance_factor);
}
;

STRING: sphere-vertex-shader
attribute vec3 center;
attribute float radius;
attribute vec4 surface_color;
varying float vradius;
varying vec3 sphere_position;
varying vec4 world_position, vcolor;

void
main()
{
    world_position = gl_ModelViewMatrix * vec4(center, 1);
    sphere_position = gl_Vertex.xyz;
    
    gl_Position = gl_ProjectionMatrix * (world_position + vec4(sphere_position * radius, 0));
    
    vcolor = surface_color;
    vradius = radius;
}
;

STRING: sphere-solid-color-fragment-shader
uniform vec3 light_position;
varying vec4 vcolor;

const vec4 ambient = vec4(0.25, 0.2, 0.25, 1.0);
const vec4 diffuse = vec4(0.75, 0.8, 0.75, 1.0);

vec4
sphere_color(vec3 point, vec3 normal)
{
    vec3 transformed_light_position = (gl_ModelViewMatrix * vec4(light_position, 1)).xyz;
    vec3 direction = normalize(transformed_light_position - point);
    float d = max(0.0, dot(normal, direction));
    
    return ambient * vcolor + diffuse * vec4(d * vcolor.rgb, vcolor.a);
}
;

STRING: sphere-texture-fragment-shader
uniform samplerCube surface_texture;

vec4
sphere_color(vec3 point, vec3 normal)
{
    vec3 reflect = reflect(normalize(point), normal);
    return textureCube(surface_texture, reflect * gl_NormalMatrix);
}
;

STRING: sphere-main-fragment-shader
varying float vradius;
varying vec3 sphere_position;
varying vec4 world_position;

vec4 sphere_color(vec3 point, vec3 normal);

void
main()
{
	float radius = length(sphere_position);
	if(radius > 1.0) discard;
	
	vec3 surface = sphere_position + vec3(0.0, 0.0, sqrt(1.0 - radius*radius));
	vec4 world_surface = world_position + vec4(surface * vradius, 0);
	vec4 transformed_surface = gl_ProjectionMatrix * world_surface;
	
    gl_FragDepth = (transformed_surface.z/transformed_surface.w + 1.0) * 0.5;
	gl_FragColor = sphere_color(world_surface.xyz, surface);
}
;

TUPLE: spheres-world < demo-world
    plane-program solid-sphere-program texture-sphere-program
    reflection-framebuffer reflection-depthbuffer
    reflection-texture ;

M: spheres-world near-plane ( gadget -- z )
    drop 1.0 ;
M: spheres-world far-plane ( gadget -- z )
    drop 512.0 ;
M: spheres-world distance-step ( gadget -- dz )
    drop 0.5 ;

: (reflection-dim) ( -- w h )
    512 512 ;

: (make-reflection-texture) ( -- texture )
    gen-texture [
        GL_TEXTURE_CUBE_MAP swap glBindTexture
        GL_TEXTURE_CUBE_MAP GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
        GL_TEXTURE_CUBE_MAP GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
        GL_TEXTURE_CUBE_MAP GL_TEXTURE_WRAP_S GL_CLAMP glTexParameteri
        GL_TEXTURE_CUBE_MAP GL_TEXTURE_WRAP_T GL_CLAMP glTexParameteri
        GL_TEXTURE_CUBE_MAP GL_TEXTURE_WRAP_R GL_CLAMP glTexParameteri
        ${
            GL_TEXTURE_CUBE_MAP_POSITIVE_X
            GL_TEXTURE_CUBE_MAP_POSITIVE_Y
            GL_TEXTURE_CUBE_MAP_POSITIVE_Z
            GL_TEXTURE_CUBE_MAP_NEGATIVE_X
            GL_TEXTURE_CUBE_MAP_NEGATIVE_Y
            GL_TEXTURE_CUBE_MAP_NEGATIVE_Z
        }
        [ 0 GL_RGBA8 (reflection-dim) 0 GL_RGBA GL_UNSIGNED_BYTE f glTexImage2D ]
        each
    ] keep ;

: (make-reflection-depthbuffer) ( -- depthbuffer )
    gen-renderbuffer [
        GL_RENDERBUFFER_EXT swap glBindRenderbufferEXT
        GL_RENDERBUFFER_EXT GL_DEPTH_COMPONENT32 (reflection-dim) glRenderbufferStorageEXT
    ] keep ;

: (make-reflection-framebuffer) ( depthbuffer -- framebuffer )
    gen-framebuffer dup [
        swap [ GL_FRAMEBUFFER_EXT GL_DEPTH_ATTACHMENT_EXT GL_RENDERBUFFER_EXT ] dip
        glFramebufferRenderbufferEXT
    ] with-framebuffer ;

: (plane-program) ( -- program )
    plane-vertex-shader plane-fragment-shader <simple-gl-program> ;
: (solid-sphere-program) ( -- program )
    sphere-vertex-shader <vertex-shader> check-gl-shader
    sphere-solid-color-fragment-shader <fragment-shader> check-gl-shader
    sphere-main-fragment-shader <fragment-shader> check-gl-shader
    3array <gl-program> check-gl-program ;
: (texture-sphere-program) ( -- program )
    sphere-vertex-shader <vertex-shader> check-gl-shader
    sphere-texture-fragment-shader <fragment-shader> check-gl-shader
    sphere-main-fragment-shader <fragment-shader> check-gl-shader
    3array <gl-program> check-gl-program ;

M: spheres-world begin-world
    "2.0" { "GL_ARB_shader_objects" } require-gl-version-or-extensions
    { "GL_EXT_framebuffer_object" } require-gl-extensions
    20.0 10.0 20.0 set-demo-orientation
    (plane-program) >>plane-program
    (solid-sphere-program) >>solid-sphere-program
    (texture-sphere-program) >>texture-sphere-program
    (make-reflection-texture) >>reflection-texture
    (make-reflection-depthbuffer) [ >>reflection-depthbuffer ] keep
    (make-reflection-framebuffer) >>reflection-framebuffer
    drop ;

M: spheres-world end-world
    {
        [ reflection-framebuffer>> [ delete-framebuffer ] when* ]
        [ reflection-depthbuffer>> [ delete-renderbuffer ] when* ]
        [ reflection-texture>> [ delete-texture ] when* ]
        [ solid-sphere-program>> [ delete-gl-program ] when* ]
        [ texture-sphere-program>> [ delete-gl-program ] when* ]
        [ plane-program>> [ delete-gl-program ] when* ]
    } cleave ;

M: spheres-world pref-dim* ( gadget -- dim )
    drop { 640 480 } ;

:: (draw-sphere) ( program center radius -- )
    program "center" glGetAttribLocation center first3 glVertexAttrib3f
    program "radius" glGetAttribLocation radius glVertexAttrib1f
    { -1.0 -1.0 } { 1.0 1.0 } rect-vertices ;
    
:: (draw-colored-sphere) ( program center radius surfacecolor -- )
    program "surface_color" glGetAttribLocation surfacecolor first4 glVertexAttrib4f
    program center radius (draw-sphere) ;

: sphere-scene ( gadget -- )
    GL_DEPTH_BUFFER_BIT GL_COLOR_BUFFER_BIT bitor glClear
    [
        solid-sphere-program>> [
            {
                [ "light_position" glGetUniformLocation 0.0 0.0 100.0 glUniform3f ]
                [ {  7.0  0.0  0.0 } 1.0 { 1.0 0.0 0.0 1.0 } (draw-colored-sphere) ]
                [ { -7.0  0.0  0.0 } 1.0 { 0.0 1.0 0.0 1.0 } (draw-colored-sphere) ]
                [ {  0.0  0.0  7.0 } 1.0 { 0.0 0.0 1.0 1.0 } (draw-colored-sphere) ]
                [ {  0.0  0.0 -7.0 } 1.0 { 1.0 1.0 0.0 1.0 } (draw-colored-sphere) ]
                [ {  0.0  7.0  0.0 } 1.0 { 1.0 0.0 1.0 1.0 } (draw-colored-sphere) ]
                [ {  0.0 -7.0  0.0 } 1.0 { 0.0 1.0 1.0 1.0 } (draw-colored-sphere) ]
            } cleave
        ] with-gl-program
    ] [
        plane-program>> [
            {
                [ "checker_size_inv" glGetUniformLocation 0.125 glUniform1f ]
                [ "checker_color_1"  glGetUniformLocation 1.0 0.0 0.0 1.0 glUniform4f ]
                [ "checker_color_2"  glGetUniformLocation 1.0 1.0 1.0 1.0 glUniform4f ]
            } cleave
            GL_QUADS [
                -1000.0 -30.0  1000.0 glVertex3f
                -1000.0 -30.0 -1000.0 glVertex3f
                 1000.0 -30.0 -1000.0 glVertex3f
                 1000.0 -30.0  1000.0 glVertex3f
            ] do-state
        ] with-gl-program
    ] bi ;

: reflection-frustum ( gadget -- -x x -y y near far )
    [ near-plane ] [ far-plane ] bi
    [ drop dup [ -+ ] bi@ ] 2keep ;

: (reflection-face) ( gadget face -- )
    swap reflection-texture>> [
        GL_FRAMEBUFFER_EXT
        GL_COLOR_ATTACHMENT0_EXT
    ] 2dip 0 glFramebufferTexture2DEXT
    check-framebuffer ;

: (draw-reflection-texture) ( gadget -- )
    dup reflection-framebuffer>> [ {
        [ drop 0 0 (reflection-dim) glViewport ]
        [
            GL_PROJECTION glMatrixMode
            glPushMatrix glLoadIdentity
            reflection-frustum glFrustum
            GL_MODELVIEW glMatrixMode
            glLoadIdentity
            180.0 0.0 0.0 1.0 glRotatef
        ]
        [ GL_TEXTURE_CUBE_MAP_NEGATIVE_Z (reflection-face) ]
        [ sphere-scene ]
        [ GL_TEXTURE_CUBE_MAP_POSITIVE_X (reflection-face)
          90.0 0.0 1.0 0.0 glRotatef ]
        [ sphere-scene ]
        [ GL_TEXTURE_CUBE_MAP_POSITIVE_Z (reflection-face)
          90.0 0.0 1.0 0.0 glRotatef glPushMatrix ]
        [ sphere-scene ]
        [ GL_TEXTURE_CUBE_MAP_NEGATIVE_X (reflection-face)
          90.0 0.0 1.0 0.0 glRotatef ]
        [ sphere-scene ]
        [ GL_TEXTURE_CUBE_MAP_NEGATIVE_Y (reflection-face)
          glPopMatrix glPushMatrix -90.0 1.0 0.0 0.0 glRotatef ]
        [ sphere-scene ]
        [ GL_TEXTURE_CUBE_MAP_POSITIVE_Y (reflection-face)
          glPopMatrix 90.0 1.0 0.0 0.0 glRotatef ]
        [ sphere-scene ]
        [
            [ 0 0 ] dip dim>> first2 glViewport
            GL_PROJECTION glMatrixMode
            glPopMatrix
        ]
    } cleave ] with-framebuffer ;

M: spheres-world draw-world*
    GL_DEPTH_TEST glEnable
    GL_SCISSOR_TEST glDisable
    0.15 0.15 1.0 1.0 glClearColor {
        [ (draw-reflection-texture) ]
        [ demo-world-set-matrix ]
        [ sphere-scene ]
        [ reflection-texture>> GL_TEXTURE_CUBE_MAP GL_TEXTURE0 bind-texture-unit ]
        [
            texture-sphere-program>> [
                [ "surface_texture" glGetUniformLocation 0 glUniform1i ]
                [ { 0.0 0.0 0.0 } 4.0 (draw-sphere) ]
                bi
            ] with-gl-program
        ]
    } cleave ;

: spheres-window ( -- )
    [
        f T{ world-attributes
            { world-class spheres-world }
            { title "Spheres" }
            { pixel-format-attributes {
                windowed
                double-buffered
                T{ depth-bits { value 16 } }
            } }
        } open-window
    ] with-ui ;

MAIN: spheres-window
