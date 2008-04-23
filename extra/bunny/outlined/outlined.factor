USING: arrays bunny.model bunny.cel-shaded continuations kernel
math multiline opengl opengl.shaders opengl.framebuffers
opengl.gl opengl.capabilities sequences ui.gadgets combinators ;
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
    "2.0" {
        "GL_ARB_shading_objects"
        "GL_ARB_draw_buffers"
        "GL_ARB_multitexture"
    } has-gl-version-or-extensions? {
        "GL_EXT_framebuffer_object"
        "GL_ARB_texture_float"
    } has-gl-extensions? and ;

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
        pass1-program pass2-program {
            set-bunny-outlined-gadget
            set-bunny-outlined-pass1-program
            set-bunny-outlined-pass2-program
        } bunny-outlined construct
    ] [ drop f ] if ;

: (framebuffer-texture) ( dim iformat xformat -- texture )
    swapd >r >r >r
    GL_TEXTURE0 glActiveTexture
    gen-texture GL_TEXTURE_2D over glBindTexture
    GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
    GL_TEXTURE_2D 0 r> r> first2 0 r> GL_UNSIGNED_BYTE f glTexImage2D ;

: (attach-framebuffer-texture) ( texture attachment -- )
    swap >r >r
    GL_FRAMEBUFFER_EXT r> GL_TEXTURE_2D r> 0 glFramebufferTexture2DEXT
    gl-error ;

: (make-framebuffer) ( color-texture normal-texture depth-texture -- framebuffer )
    3array gen-framebuffer dup [
        swap GL_COLOR_ATTACHMENT0_EXT
             GL_COLOR_ATTACHMENT1_EXT
             GL_DEPTH_ATTACHMENT_EXT 3array [ (attach-framebuffer-texture) ] 2each
        check-framebuffer
    ] with-framebuffer ;

: dispose-framebuffer ( draw -- )
    dup bunny-outlined-framebuffer-dim [
        {
            [ bunny-outlined-framebuffer    [ delete-framebuffer ] when* ]
            [ bunny-outlined-color-texture  [ delete-texture ] when* ]
            [ bunny-outlined-normal-texture [ delete-texture ] when* ]
            [ bunny-outlined-depth-texture  [ delete-texture ] when* ]
            [ f swap set-bunny-outlined-framebuffer-dim ]
        } cleave
    ] [ drop ] if ;

: remake-framebuffer-if-needed ( draw -- )
    dup bunny-outlined-gadget rect-dim
    over bunny-outlined-framebuffer-dim
    over =
    [ 2drop ]
    [
        swap dup dispose-framebuffer >r
        dup GL_RGBA16F_ARB GL_RGBA (framebuffer-texture)
        swap dup GL_RGBA16F_ARB GL_RGBA (framebuffer-texture)
        swap dup GL_DEPTH_COMPONENT32 GL_DEPTH_COMPONENT (framebuffer-texture)
        swap >r
        [ (make-framebuffer) ] 3keep
        r> r> {
            set-bunny-outlined-framebuffer
            set-bunny-outlined-color-texture
            set-bunny-outlined-normal-texture
            set-bunny-outlined-depth-texture
            set-bunny-outlined-framebuffer-dim
        } set-slots
    ] if ;

: clear-framebuffer ( -- )
    GL_COLOR_ATTACHMENT0_EXT glDrawBuffer
    0.15 0.15 0.15 1.0 glClearColor
    GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
    GL_COLOR_ATTACHMENT1_EXT glDrawBuffer
    0.0 0.0 0.0 0.0 glClearColor
    GL_COLOR_BUFFER_BIT glClear ;

: (pass1) ( geom draw -- )
    dup bunny-outlined-framebuffer [
        clear-framebuffer
        { GL_COLOR_ATTACHMENT0_EXT GL_COLOR_ATTACHMENT1_EXT } set-draw-buffers
        bunny-outlined-pass1-program (draw-cel-shaded-bunny)
    ] with-framebuffer ;

: (pass2) ( draw -- )
    init-matrices
    dup bunny-outlined-color-texture GL_TEXTURE_2D GL_TEXTURE0 bind-texture-unit
    dup bunny-outlined-normal-texture GL_TEXTURE_2D GL_TEXTURE1 bind-texture-unit
    dup bunny-outlined-depth-texture GL_TEXTURE_2D GL_TEXTURE2 bind-texture-unit
    bunny-outlined-pass2-program {
        { "colormap"   [ 0 glUniform1i ] }
        { "normalmap"  [ 1 glUniform1i ] }
        { "depthmap"   [ 2 glUniform1i ] }
        { "line_color" [ 0.1 0.0 0.1 1.0 glUniform4f ] }
    } [ { -1.0 -1.0 } { 1.0 1.0 } rect-vertices ] with-gl-program ;

M: bunny-outlined draw-bunny
    dup remake-framebuffer-if-needed
    [ (pass1) ] keep (pass2) ;

M: bunny-outlined dispose
    {
        [ bunny-outlined-pass1-program [ delete-gl-program ] when* ]
        [ bunny-outlined-pass2-program [ delete-gl-program ] when* ]
        [ dispose-framebuffer ]
    } cleave ;
