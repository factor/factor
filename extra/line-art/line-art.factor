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
    0.0 0.0 0.375 <demo-gadget>
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

const float DEPTH_RATIO_THRESHOLD = 2.0, NORMAL_DOT_THRESHOLD = 0.95, SAMPLE_SPREAD = 1.0/1024.0;

bool
is_normal_border(vec3 norm1, vec3 norm2)
{
    return dot(norm1, norm2) < NORMAL_DOT_THRESHOLD;
}
bool
is_depth_border(float depth1, float depth2)
{
    float ratio = depth1/depth2;
    return 1.0/DEPTH_RATIO_THRESHOLD > ratio || ratio > DEPTH_RATIO_THRESHOLD;
}

bool
is_border(vec2 coord)
{
    vec2 coord1 = coord + vec2(-SAMPLE_SPREAD, -SAMPLE_SPREAD),
         coord2 = coord + vec2( SAMPLE_SPREAD, -SAMPLE_SPREAD),
         coord3 = coord + vec2(-SAMPLE_SPREAD,  SAMPLE_SPREAD),
         coord4 = coord + vec2( SAMPLE_SPREAD,  SAMPLE_SPREAD);
    
    /* This border checking code is meant to be easy to follow rather than blazingly fast.
     * The normal/depth checks could be easily parallelized into matrix or vector operations to
     * improve performance. */
    vec3 normal1 = texture2D(normalmap, coord1).xyz,
         normal2 = texture2D(normalmap, coord2).xyz,
         normal3 = texture2D(normalmap, coord3).xyz,
         normal4 = texture2D(normalmap, coord4).xyz;
    float depth1 = texture2D(depthmap, coord1).x,
          depth2 = texture2D(depthmap, coord2).x,
          depth3 = texture2D(depthmap, coord3).x,
          depth4 = texture2D(depthmap, coord4).x;
    
    return (depth1 < 1.0 || depth2 < 1.0 || depth3 < 1.0 || depth4 < 1.0)
        && (is_normal_border(normal1, normal2)
            || is_normal_border(normal1, normal3)
            || is_normal_border(normal1, normal4)
            || is_normal_border(normal2, normal3)
            || is_normal_border(normal2, normal4)
            || is_normal_border(normal3, normal4)
            /* || is_depth_border(depth1, depth2)
            || is_depth_border(depth1, depth3)
            || is_depth_border(depth1, depth4)
            || is_depth_border(depth2, depth3)
            || is_depth_border(depth2, depth4)
            || is_depth_border(depth3, depth4) */
        );
}

void
main()
{
    gl_FragColor = is_border(coord)
        ? line_color
        : texture2D(colormap, coord);
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
    dup line-art-remake-framebuffer-if-needed gl-error ;

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
        GL_COLOR_ATTACHMENT0_EXT GL_COLOR_ATTACHMENT1_EXT 2array set-draw-buffers
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
          [ "depthmap"  glGetUniformLocation 2 glUniform1i ] } call-with
        { -1.0 -1.0 } { 1.0 1.0 } draw-rectangle
    ] with-gl-program ;

: line-art-window ( -- )
    [ <line-art-gadget> "Line Art" open-window ] with-ui ;
    
MAIN: line-art-window
