USING: kernel opengl.demo-support opengl.gl opengl.shaders opengl.framebuffers
opengl multiline ui.gadgets accessors sequences ui.render ui math 
arrays.lib combinators ;
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
varying vec3 object_position;
void
main()
{
    float distance_factor = (gl_FragCoord.z * 0.5 + 0.5);
    distance_factor = pow(distance_factor, 500.0)*0.5;
    
    gl_FragColor = fract((floor(0.125*object_position.x)+floor(0.125*object_position.z)) * 0.5) == 0.0
        ? vec4(1.0, 1.0 - distance_factor, 1.0 - distance_factor, 1.0)
        : vec4(1.0, distance_factor, distance_factor, 1.0);
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

STRING: sphere-fragment-shader
uniform vec3 light_position;
varying float vradius;
varying vec3 sphere_position;
varying vec4 world_position, vcolor;

vec4 ambient = vec4(0.3, 0.2, 0.2, 1.0);
vec4 diffuse = vec4(0.7, 0.8, 0.8, 1.0);

vec4
light(vec3 point, vec3 normal)
{
    vec3 transformed_light_position = (gl_ModelViewMatrix * vec4(light_position, 1)).xyz;
    vec3 direction = normalize(transformed_light_position - point);
    float d = max(0.0, dot(normal, direction));
    
    return ambient * vcolor + diffuse * vec4(d * vcolor.rgb, vcolor.a);
}

void
main()
{
	float radius = length(sphere_position);
	if(radius > 1.0) discard;
	
	vec3 surface = sphere_position + vec3(0.0, 0.0, sqrt(1.0 - radius*radius));
	vec4 world_surface = world_position + vec4(surface * vradius, 0);
	vec4 transformed_surface = gl_ProjectionMatrix * world_surface;
	
    gl_FragDepth = (transformed_surface.z/transformed_surface.w + 1.0) * 0.5;
	gl_FragColor = light(world_surface.xyz, surface);
}
;

TUPLE: spheres-gadget
    plane-program sphere-program
    reflection-framebuffer reflection-depthbuffer
    reflection-texture ;

: <spheres-gadget> ( -- gadget )
    0.0 0.0 20.0 <demo-gadget>
    { set-delegate } spheres-gadget construct ;

M: spheres-gadget near-plane ( gadget -- z )
    drop 1.0 ;
M: spheres-gadget far-plane ( gadget -- z )
    drop 512.0 ;
M: spheres-gadget distance-step ( gadget -- dz )
    drop 0.5 ;

: (make-reflection-texture) ( -- texture )
    gen-texture [
        GL_TEXTURE_CUBE_MAP swap glBindTexture
        GL_TEXTURE_CUBE_MAP GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
        GL_TEXTURE_CUBE_MAP GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
        GL_TEXTURE_CUBE_MAP_POSITIVE_X
        GL_TEXTURE_CUBE_MAP_POSITIVE_Y
        GL_TEXTURE_CUBE_MAP_POSITIVE_Z
        GL_TEXTURE_CUBE_MAP_NEGATIVE_X
        GL_TEXTURE_CUBE_MAP_NEGATIVE_Y
        GL_TEXTURE_CUBE_MAP_NEGATIVE_Z 6 narray
        [ 0 GL_RGBA8 1024 1024 0 GL_RGBA GL_UNSIGNED_BYTE f glTexImage2D ]
        each
    ] keep ;

: (make-reflection-depthbuffer) ( -- depthbuffer )
    gen-renderbuffer [
        GL_RENDERBUFFER_EXT swap glBindRenderbufferEXT
        GL_RENDERBUFFER_EXT GL_DEPTH_COMPONENT32 1024 1024 glRenderbufferStorageEXT
    ] keep ;

: (make-reflection-framebuffer) ( depthbuffer -- framebuffer )
    gen-framebuffer dup [
        swap >r
        GL_FRAMEBUFFER_EXT GL_DEPTH_ATTACHMENT_EXT GL_RENDERBUFFER_EXT r>
        glFramebufferRenderbufferEXT
    ] with-framebuffer ;

M: spheres-gadget graft* ( gadget -- )
    plane-vertex-shader plane-fragment-shader
    <simple-gl-program> >>plane-program
    sphere-vertex-shader sphere-fragment-shader
    <simple-gl-program> >>sphere-program
    (make-reflection-texture) >>reflection-texture
    (make-reflection-depthbuffer) [ >>reflection-depthbuffer ] keep
    (make-reflection-framebuffer) >>reflection-framebuffer
    drop ;

M: spheres-gadget ungraft* ( gadget -- )
    {
        [ reflection-framebuffer>> [ delete-framebuffer ] when* ]
        [ reflection-depthbuffer>> [ delete-renderbuffer ] when* ]
        [ reflection-texture>> [ delete-texture ] when* ]
        [ sphere-program>> [ delete-gl-program ] when* ]
        [ plane-program>> [ delete-gl-program ] when* ]
    } cleave ;

M: spheres-gadget pref-dim* ( gadget -- dim )
    drop { 640 480 } ;
    
: (draw-sphere) ( program center radius surfacecolor -- )
    roll
    [ [ "center" glGetAttribLocation swap first3 glVertexAttrib3f ] curry ]
    [ [ "radius" glGetAttribLocation swap glVertexAttrib1f ] curry ]
    [ [ "surface_color" glGetAttribLocation swap first4 glVertexAttrib4f ] curry ]
    tri tri*
    { -1.0 -1.0 } { 1.0 1.0 } rect-vertices ;

: sphere-scene ( gadget -- )
    GL_DEPTH_BUFFER_BIT GL_COLOR_BUFFER_BIT bitor
    glClear
    [
        sphere-program>> dup {
            { "light_position" [ 0.0 0.0 100.0 glUniform3f ] }
        } [
            [ {  0.0 0.0 0.0 } 4.0 { 1.0 1.0 0.0 1.0 } (draw-sphere) ]
            [ {  7.0 0.0 0.0 } 1.0 { 1.0 0.0 0.0 1.0 } (draw-sphere) ]
            [ { -7.0 0.0 0.0 } 1.0 { 0.0 1.0 0.0 1.0 } (draw-sphere) ] tri
        ] with-gl-program
    ] [
        plane-program>> { } [
            GL_QUADS [
                -1000.0 -30.0  1000.0 glVertex3f
                -1000.0 -30.0 -1000.0 glVertex3f
                 1000.0 -30.0 -1000.0 glVertex3f
                 1000.0 -30.0  1000.0 glVertex3f
            ] do-state
        ] with-gl-program
    ] bi ;

: reflection-frustum ( gadget -- -x x -y y near far )
    [ near-plane ] [ far-plane ] bi [
        drop dup [ -+ ] bi@
    ] 2keep ;

: (reflection-face) ( gadget face -- )
    swap reflection-texture>> >r >r
    GL_FRAMEBUFFER_EXT
    GL_COLOR_ATTACHMENT0_EXT
    r> r> 0 glFramebufferTexture2DEXT ;

M: spheres-gadget draw-gadget* ( gadget -- )
    GL_DEPTH_TEST glEnable
    0.15 0.15 1.0 1.0 glClearColor {
        [
            GL_PROJECTION glMatrixMode
            glLoadIdentity
            reflection-frustum glFrustum
            GL_MODELVIEW glMatrixMode
            glLoadIdentity
            glPushMatrix
        ]
        [
            dup reflection-framebuffer>> [ {
                [ GL_TEXTURE_CUBE_MAP_NEGATIVE_Z (reflection-face) ]
                [ sphere-scene ]
                [ GL_TEXTURE_CUBE_MAP_NEGATIVE_X (reflection-face)
                  90.0 0.0 1.0 0.0 glRotatef ]
                [ sphere-scene ]
                [ GL_TEXTURE_CUBE_MAP_POSITIVE_Z (reflection-face)
                  90.0 0.0 1.0 0.0 glRotatef ]
                [ sphere-scene ]
                [ GL_TEXTURE_CUBE_MAP_POSITIVE_X (reflection-face)
                  90.0 0.0 1.0 0.0 glRotatef ]
                [ sphere-scene ]
                [ GL_TEXTURE_CUBE_MAP_POSITIVE_Y (reflection-face)
                  glPopMatrix glPushMatrix
                  90.0 1.0 0.0 0.0 glRotatef ]
                [ sphere-scene ]
                [ GL_TEXTURE_CUBE_MAP_NEGATIVE_Y (reflection-face)
                  glPopMatrix
                  -90.0 1.0 0.0 0.0 glRotatef ]
                [ sphere-scene ]
            } cleave ] with-framebuffer
        ]
        [ demo-gadget-set-matrices ]
        [ sphere-scene ]
    } cleave ;

: spheres-window ( -- )
    [ <spheres-gadget> "Spheres" open-window ] with-ui ;

MAIN: spheres-window
