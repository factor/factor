USING: arrays bunny combinators.lib continuations io io.files kernel
       math math.functions math.vectors multiline
       namespaces
       opengl opengl.gl opengl-demo-support
       prettyprint
       sequences ui ui.gadgets ui.gestures ui.render ;
IN: line-art

TUPLE: line-art-gadget
    model step1-program step2-program
    framebuffer color-texture normal-texture depth-texture framebuffer-dim ;

: <line-art-gadget> ( -- line-art-gadget )
    40.0 -5.0 0.275 <demo-gadget>
    maybe-download read-model
    { set-delegate set-line-art-gadget-model } line-art-gadget construct ;

STRING: line-art-step1-vertex-shader-source
varying vec3 normal;

void
main()
{
    gl_Position = ftransform();
    normal = gl_Normal;
}

;

STRING: line-art-step1-fragment-shader-source
varying vec3 normal;
uniform vec4 color;

void
main()
{
    gl_FragData[0] = color;
    gl_FragData[1] = vec4(normal, 1);
}

;

STRING: line-art-step2-vertex-shader-source
varying vec2 coord;

void
main()
{
    gl_Position = ftransform();
    coord = (gl_Vertex * vec4(0.5) + vec4(0.5)).xy;
}

;

STRING: line-art-step2-fragment-shader-source
uniform sampler2D colormap, normalmap, depthmap;
uniform vec4 line_color;
varying vec2 coord;

const float DEPTH_RATIO_THRESHOLD = 1.001, NORMAL_DOT_THRESHOLD = 1.0, SAMPLE_SPREAD = 1.0/512.0;

bool
is_normal_border(vec3 norm1, vec3 norm2)
{
    return dot(norm1, norm2) < NORMAL_DOT_THRESHOLD;
}

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
    
    vec4 depths = vec4(depth_sample(coord1),
                       depth_sample(coord2),
                       depth_sample(coord3),
                       depth_sample(coord4));
    if (depths == vec4(1, 1, 1, 1))
        return 0.0;
    
    vec3 ratios1 = depths.xxx/depths.yzw, ratios2 = depths.yyz/depths.zww;
    
    if (are_depths_border(ratios1) || are_depths_border(ratios2))
        return 1.0;
    
    vec3 normal1 = normal_sample(coord1),
         normal2 = normal_sample(coord2),
         normal3 = normal_sample(coord3),
         normal4 = normal_sample(coord4);
    
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

void
main()
{
    gl_FragColor = mix(texture2D(colormap, coord), line_color, border_factor(coord));
}

;

: (line-art-step1-program) ( -- step1 )
    line-art-step1-vertex-shader-source line-art-step1-fragment-shader-source
    <simple-gl-program> ;
: (line-art-step2-program) ( -- step2 )
    line-art-step2-vertex-shader-source line-art-step2-fragment-shader-source
    <simple-gl-program> ;

: (line-art-framebuffer-texture) ( dim iformat xformat -- texture )
    swapd >r >r >r
    GL_TEXTURE0 glActiveTexture
    gen-texture GL_TEXTURE_2D over glBindTexture
    GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
    GL_TEXTURE_2D 0 r> r> first2 0 r> GL_UNSIGNED_BYTE f glTexImage2D ;

: (line-art-color-texture) ( dim -- texture )
    GL_RGBA16F_ARB GL_RGBA (line-art-framebuffer-texture) ;

: (line-art-normal-texture) ( dim -- texture )
    GL_RGBA16F_ARB GL_RGBA (line-art-framebuffer-texture) ;

: (line-art-depth-texture) ( dim -- texture )
    GL_DEPTH_COMPONENT32 GL_DEPTH_COMPONENT (line-art-framebuffer-texture) ;

: (attach-framebuffer-texture) ( texture attachment -- )
    swap >r >r GL_FRAMEBUFFER_EXT r> GL_TEXTURE_2D r> 0 glFramebufferTexture2DEXT gl-error ;

: (line-art-framebuffer) ( color-texture normal-texture depth-texture -- framebuffer )
    3array gen-framebuffer dup [
        swap GL_COLOR_ATTACHMENT0_EXT
             GL_COLOR_ATTACHMENT1_EXT
             GL_DEPTH_ATTACHMENT_EXT 3array [ (attach-framebuffer-texture) ] 2each
        check-framebuffer
    ] with-framebuffer ;
    
: line-art-remake-framebuffer-if-needed ( gadget -- )
    dup { rect-dim rect-dim line-art-gadget-framebuffer-dim } get-slots = [ 2drop ] [
        swap >r
        dup (line-art-color-texture) gl-error
        swap dup (line-art-normal-texture) gl-error
        swap dup (line-art-depth-texture) gl-error
        swap >r
        [ (line-art-framebuffer) ] 3keep
        r> r> { set-line-art-gadget-framebuffer
                set-line-art-gadget-color-texture
                set-line-art-gadget-normal-texture
                set-line-art-gadget-depth-texture
                set-line-art-gadget-framebuffer-dim } set-slots
    ] if ;
    
M: line-art-gadget graft* ( gadget -- )
    GL_CULL_FACE glEnable
    GL_DEPTH_TEST glEnable
    (line-art-step1-program) over set-line-art-gadget-step1-program
    (line-art-step2-program) swap set-line-art-gadget-step2-program ;

M: line-art-gadget ungraft* ( gadget -- )
    dup line-art-gadget-framebuffer [
        { [ line-art-gadget-step1-program delete-gl-program ]
          [ line-art-gadget-step2-program delete-gl-program ]
          [ line-art-gadget-framebuffer delete-framebuffer ]
          [ line-art-gadget-color-texture delete-texture ]
          [ line-art-gadget-normal-texture delete-texture ]
          [ line-art-gadget-depth-texture delete-texture ]
          [ f swap set-line-art-gadget-framebuffer-dim ]
          [ f swap set-line-art-gadget-framebuffer ] } call-with
    ] [ drop ] if ;

: line-art-draw-setup ( gadget -- gadget )
    0.0 0.0 0.0 1.0 glClearColor
    GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
    dup demo-gadget-set-matrices
    dup line-art-remake-framebuffer-if-needed
    gl-error ;

: line-art-clear-framebuffer ( -- )
    GL_COLOR_ATTACHMENT0_EXT glDrawBuffer
    0.2 0.2 0.2 1.0 glClearColor
    GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
    GL_COLOR_ATTACHMENT1_EXT glDrawBuffer
    0.0 0.0 0.0 0.0 glClearColor
    GL_COLOR_BUFFER_BIT glClear ;

M: line-art-gadget draw-gadget* ( gadget -- )
    line-art-draw-setup
    dup line-art-gadget-framebuffer [
        line-art-clear-framebuffer
        { GL_COLOR_ATTACHMENT0_EXT GL_COLOR_ATTACHMENT1_EXT } set-draw-buffers
        dup line-art-gadget-step1-program dup [
            "color" glGetUniformLocation 0.6 0.5 0.5 1.0 glUniform4f
            0.0 -0.12 0.0 glTranslatef
            dup line-art-gadget-model first3 draw-bunny
        ] with-gl-program
    ] with-framebuffer
    init-matrices
    dup line-art-gadget-color-texture GL_TEXTURE_2D GL_TEXTURE0 bind-texture-unit
    dup line-art-gadget-normal-texture GL_TEXTURE_2D GL_TEXTURE1 bind-texture-unit
    dup line-art-gadget-depth-texture GL_TEXTURE_2D GL_TEXTURE2 bind-texture-unit
    line-art-gadget-step2-program dup [
        { [ "colormap"  glGetUniformLocation 0 glUniform1i ]
          [ "normalmap" glGetUniformLocation 1 glUniform1i ]
          [ "depthmap"  glGetUniformLocation 2 glUniform1i ]
          [ "line_color" glGetUniformLocation 0.2 0.0 0.0 1.0 glUniform4f ] } call-with
        { -1.0 -1.0 } { 1.0 1.0 } rect-vertices
    ] with-gl-program ;

: line-art-window ( -- )
    [ <line-art-gadget> "Line Art" open-window ] with-ui ;
    
MAIN: line-art-window
