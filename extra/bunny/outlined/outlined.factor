USING: accessors arrays bunny.cel-shaded bunny.model combinators
destructors kernel literals multiline opengl opengl.capabilities
opengl.demo-support opengl.framebuffers opengl.gl opengl.shaders
opengl.textures sequences ;
FROM: opengl.demo-support => rect-vertices ;
IN: bunny.outlined

STRING: outlined-pass1-fragment-shader-main-source
varying vec3 normal;
vec4 cel_light();

void
main()
{
    gl_FragData[0] = cel_light();
    gl_FragData[1] = vec4(normal, 1);
}

;

STRING: outlined-pass2-vertex-shader-source
varying vec2 coord;

void
main()
{
    gl_Position = ftransform();
    coord = (gl_Vertex * vec4(0.5) + vec4(0.5)).xy;
}

;

STRING: outlined-pass2-fragment-shader-source
uniform sampler2D colormap, normalmap, depthmap;
uniform vec4 line_color;
varying vec2 coord;

const float DEPTH_RATIO_THRESHOLD = 1.001, SAMPLE_SPREAD = 1.0/512.0;

float
depth_sample(vec2 c)
{
    return texture2D(depthmap, c).x;
}
bool
are_depths_border(vec3 depths)
{
    return any(lessThan(depths, vec3(1.0/DEPTH_RATIO_THRESHOLD)))
        || any(greaterThan(depths, vec3(DEPTH_RATIO_THRESHOLD)));
}

vec3
normal_sample(vec2 c)
{
    return texture2D(normalmap, c).xyz;
}

float
min6(float a, float b, float c, float d, float e, float f)
{
    return min(min(min(min(min(a, b), c), d), e), f);
}

float
border_factor(vec2 c)
{
    vec2 coord1 = c + vec2(-SAMPLE_SPREAD, -SAMPLE_SPREAD),
         coord2 = c + vec2( SAMPLE_SPREAD, -SAMPLE_SPREAD),
         coord3 = c + vec2(-SAMPLE_SPREAD,  SAMPLE_SPREAD),
         coord4 = c + vec2( SAMPLE_SPREAD,  SAMPLE_SPREAD);

    vec3 normal1 = normal_sample(coord1),
         normal2 = normal_sample(coord2),
         normal3 = normal_sample(coord3),
         normal4 = normal_sample(coord4);

    if (dot(normal1, normal1) < 0.5
        && dot(normal2, normal2) < 0.5
        && dot(normal3, normal3) < 0.5
        && dot(normal4, normal4) < 0.5) {
        return 0.0;
    } else {
        vec4 depths = vec4(depth_sample(coord1),
                           depth_sample(coord2),
                           depth_sample(coord3),
                           depth_sample(coord4));

        vec3 ratios1 = depths.xxx/depths.yzw, ratios2 = depths.yyz/depths.zww;

        if (are_depths_border(ratios1) || are_depths_border(ratios2)) {
            return 1.0;
        } else {
            float normal_border = 1.0 - min6(
                dot(normal1, normal2),
                dot(normal1, normal3),
                dot(normal1, normal4),
                dot(normal2, normal3),
                dot(normal2, normal4),
                dot(normal3, normal4)
            );

            return normal_border;
        }
    }
}

void
main()
{
    gl_FragColor = mix(texture2D(colormap, coord), line_color, border_factor(coord));
}

;

TUPLE: bunny-outlined
    gadget
    pass1-program pass2-program
    color-texture normal-texture depth-texture
    framebuffer framebuffer-dim ;

: outlining-supported? ( -- ? )
    "3.0" {
        "GL_ARB_shader_objects"
        "GL_ARB_draw_buffers"
        "GL_ARB_multitexture"
        "GL_EXT_framebuffer_object"
        "GL_ARB_texture_float"
    } has-gl-version-or-extensions? ;

: pass1-program ( -- program )
    vertex-shader-source <vertex-shader> check-gl-shader
    cel-shaded-fragment-shader-lib-source <fragment-shader> check-gl-shader
    outlined-pass1-fragment-shader-main-source <fragment-shader> check-gl-shader
    3array <gl-program> check-gl-program ;

: pass2-program ( -- program )
    outlined-pass2-vertex-shader-source
    outlined-pass2-fragment-shader-source <simple-gl-program> ;

: <bunny-outlined> ( gadget -- draw )
    outlining-supported? [
        pass1-program pass2-program f f f f f bunny-outlined boa
    ] [ drop f ] if ;

:: (framebuffer-texture) ( dim iformat xformat -- texture )
    GL_TEXTURE0 glActiveTexture
    gen-texture GL_TEXTURE_2D over glBindTexture
    GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
    GL_TEXTURE_2D 0 iformat dim first2 0 xformat GL_UNSIGNED_BYTE f glTexImage2D ;

:: (attach-framebuffer-texture) ( texture attachment -- )
    GL_DRAW_FRAMEBUFFER attachment GL_TEXTURE_2D texture 0 glFramebufferTexture2D
    gl-error ;

: (make-framebuffer) ( color-texture normal-texture depth-texture -- framebuffer )
    3array gen-framebuffer dup [
        swap GL_COLOR_ATTACHMENT0
             GL_COLOR_ATTACHMENT1
             GL_DEPTH_ATTACHMENT 3array [ (attach-framebuffer-texture) ] 2each
        check-framebuffer
    ] with-framebuffer ;

: dispose-framebuffer ( draw -- )
    dup framebuffer-dim>> [
        {
            [ framebuffer>>    [ delete-framebuffer ] when* ]
            [ color-texture>>  [ delete-texture ] when* ]
            [ normal-texture>> [ delete-texture ] when* ]
            [ depth-texture>>  [ delete-texture ] when* ]
            [ f >>framebuffer-dim drop ]
        } cleave
    ] [ drop ] if ;

MACRO: (framebuffer-texture>>draw) ( iformat xformat setter -- quot )
    '[ _ _ (framebuffer-texture) [ @ drop ] keep ] ;

: (make-framebuffer-textures) ( draw dim -- draw color normal depth )
    {
        [ drop ]
        [ GL_RGBA16F GL_RGBA [ >>color-texture  ] (framebuffer-texture>>draw) ]
        [ GL_RGBA16F GL_RGBA [ >>normal-texture ] (framebuffer-texture>>draw) ]
        [
            GL_DEPTH_COMPONENT32 GL_DEPTH_COMPONENT
            [ >>depth-texture ] (framebuffer-texture>>draw)
        ]
    } 2cleave ;

: remake-framebuffer ( draw -- )
    [ dispose-framebuffer ]
    [ dup gadget>> dim>>
        [ (make-framebuffer-textures) (make-framebuffer) >>framebuffer ]
        [ >>framebuffer-dim drop ] bi
    ] bi ;

: remake-framebuffer-if-needed ( draw -- )
    dup [ gadget>> dim>> ] [ framebuffer-dim>> ] bi =
    [ drop ] [ remake-framebuffer ] if ;

: clear-framebuffer ( -- )
    GL_COLOR_ATTACHMENT0 glDrawBuffer
    0.15 0.15 0.15 1.0 glClearColor
    flags{ GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT } glClear
    GL_COLOR_ATTACHMENT1 glDrawBuffer
    0.0 0.0 0.0 0.0 glClearColor
    GL_COLOR_BUFFER_BIT glClear ;

: (pass1) ( geom draw -- )
    dup framebuffer>> [
        clear-framebuffer
        { GL_COLOR_ATTACHMENT0 GL_COLOR_ATTACHMENT1 } set-draw-buffers
        pass1-program>> (draw-cel-shaded-bunny)
    ] with-framebuffer ;

: (pass2) ( draw -- )
    GL_PROJECTION glMatrixMode
    glPushMatrix glLoadIdentity
    GL_MODELVIEW glMatrixMode
    glLoadIdentity
    {
        [ color-texture>>  GL_TEXTURE_2D GL_TEXTURE0 bind-texture-unit ]
        [ normal-texture>> GL_TEXTURE_2D GL_TEXTURE1 bind-texture-unit ]
        [ depth-texture>>  GL_TEXTURE_2D GL_TEXTURE2 bind-texture-unit ]
        [
            pass2-program>> [
                {
                    [ "colormap"   glGetUniformLocation 0 glUniform1i ]
                    [ "normalmap"  glGetUniformLocation 1 glUniform1i ]
                    [ "depthmap"   glGetUniformLocation 2 glUniform1i ]
                    [ "line_color" glGetUniformLocation 0.1 0.0 0.1 1.0 glUniform4f ]
                } cleave { -1.0 -1.0 } { 1.0 1.0 } rect-vertices
            ] with-gl-program
        ]
    } cleave
    GL_PROJECTION glMatrixMode
    glPopMatrix ;

M: bunny-outlined draw-bunny
    [ remake-framebuffer-if-needed ]
    [ (pass1) ]
    [ (pass2) ] tri ;

M: bunny-outlined dispose
    [ pass1-program>> [ delete-gl-program ] when* ]
    [ pass2-program>> [ delete-gl-program ] when* ]
    [ dispose-framebuffer ] tri ;
