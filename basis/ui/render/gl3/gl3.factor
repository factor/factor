! Copyright (C) 2024 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data arrays
byte-arrays colors combinators combinators.smart continuations
destructors images io kernel locals math math.constants
math.functions math.rectangles math.vectors namespaces opengl
opengl.gl opengl.shaders opengl.textures prettyprint sequences
specialized-arrays
specialized-arrays.instances.alien.c-types.float
specialized-arrays.instances.alien.c-types.uint ui.render ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
SPECIALIZED-ARRAY: uint
IN: ui.render.gl3

! ============================================================
! GL3 2D Rendering - Replaces legacy fixed-function pipeline
! ============================================================

! --- Shader Sources ---

CONSTANT: gl3-vertex-shader-source "
#version 330 core
layout(location = 0) in vec2 position;
layout(location = 1) in vec4 color;

uniform mat4 projection;
uniform mat4 modelview;

out vec4 frag_color;

void main() {
    gl_Position = projection * modelview * vec4(position, 0.0, 1.0);
    frag_color = color;
}
"

CONSTANT: gl3-fragment-shader-source "
#version 330 core
in vec4 frag_color;
out vec4 out_color;

uniform vec4 uniform_color;
uniform int use_uniform_color;

void main() {
    if (use_uniform_color != 0) {
        out_color = uniform_color;
    } else {
        out_color = frag_color;
    }
}
"

! --- Texture Shader Sources ---

CONSTANT: gl3-texture-vertex-shader-source "
#version 330 core
layout(location = 0) in vec2 position;
layout(location = 1) in vec2 texcoord;

uniform mat4 projection;
uniform mat4 modelview;

out vec2 frag_texcoord;

void main() {
    gl_Position = projection * modelview * vec4(position, 0.0, 1.0);
    frag_texcoord = texcoord;
}
"

CONSTANT: gl3-texture-fragment-shader-source "
#version 330 core
in vec2 frag_texcoord;
out vec4 out_color;

uniform sampler2D tex;

void main() {
    out_color = texture(tex, frag_texcoord);
}
"

! --- GL3 Render State ---

SYMBOL: current-modelview
SYMBOL: current-projection-dim

TUPLE: gl3-state
    program
    vao
    vbo
    projection-loc
    modelview-loc
    color-loc
    use-uniform-color-loc
    modelview-stack
    ! Texture rendering state
    tex-program
    tex-vao
    tex-vbo
    tex-projection-loc
    tex-modelview-loc
    tex-sampler-loc ;

SYMBOL: gl3-render-state

: gl3-state> ( -- state ) gl3-render-state get-global ;

! --- Matrix Utilities ---

:: make-ortho-matrix ( left right bottom top near far -- floats )
    right left - :> width
    top bottom - :> height
    far near - :> depth
    2.0 width / :> a1
    2.0 height / :> b2
    -2.0 depth / :> c3
    right left + width / neg :> tx
    top bottom + height / neg :> ty
    far near + depth / neg :> tz
    ! Column-major order for OpenGL
    [
        a1   0.0  0.0  0.0
        0.0  b2   0.0  0.0
        0.0  0.0  c3   0.0
        tx   ty   tz   1.0
    ] float-array{ } output>sequence ;

:: make-2d-ortho ( width height -- floats )
    0.0 width height 0.0 -1.0 1.0 make-ortho-matrix ;

: identity-matrix ( -- floats )
    ! Column-major order for OpenGL
    float-array{
        1.0 0.0 0.0 0.0
        0.0 1.0 0.0 0.0
        0.0 0.0 1.0 0.0
        0.0 0.0 0.0 1.0
    } ;

:: make-translation-matrix ( x y -- floats )
    ! Column-major order for OpenGL
    [
        1.0  0.0  0.0  0.0
        0.0  1.0  0.0  0.0
        0.0  0.0  1.0  0.0
        x    y    0.0  1.0
    ] float-array{ } output>sequence ;

:: make-scale-matrix ( sx sy -- floats )
    ! Column-major order for OpenGL
    [
        sx   0.0  0.0  0.0
        0.0  sy   0.0  0.0
        0.0  0.0  1.0  0.0
        0.0  0.0  0.0  1.0
    ] float-array{ } output>sequence ;

! Matrix multiplication for 4x4 matrices (stored as 16-element arrays, column-major)
:: mat4-multiply ( a b -- c )
    16 <float-array> :> c
    4 <iota> [| row |
        4 <iota> [| col |
            0.0
            4 <iota> [| k |
                k 4 * row + a nth
                col 4 * k + b nth * +
            ] each
            col 4 * row + c set-nth
        ] each
    ] each c ;

! --- Shader Setup ---

: create-gl3-program ( -- program )
    gl3-vertex-shader-source gl3-fragment-shader-source
    <simple-gl-program> ;

: get-uniform-locations ( program -- proj-loc mv-loc color-loc use-color-loc )
    {
        [ "projection" glGetUniformLocation ]
        [ "modelview" glGetUniformLocation ]
        [ "uniform_color" glGetUniformLocation ]
        [ "use_uniform_color" glGetUniformLocation ]
    } cleave ;

! --- VAO/VBO Setup ---

: create-gl3-vao ( -- vao )
    1 0 uint <ref> [ glGenVertexArrays ] keep uint deref ;

: create-gl3-vbo ( -- vbo )
    1 0 uint <ref> [ glGenBuffers ] keep uint deref ;

: setup-vertex-attributes ( -- )
    ! Vertex format: x y r g b a (6 floats per vertex)
    ! Position attribute (location 0): 2 floats at offset 0
    0 glEnableVertexAttribArray
    0 2 GL_FLOAT GL_FALSE 6 4 * 0 <alien> glVertexAttribPointer
    ! Color attribute (location 1): 4 floats at offset 8 bytes
    1 glEnableVertexAttribArray
    1 4 GL_FLOAT GL_FALSE 6 4 * 2 4 * <alien> glVertexAttribPointer ;

! --- GL3 State Management ---

: create-gl3-texture-program ( -- program )
    gl3-texture-vertex-shader-source gl3-texture-fragment-shader-source
    <simple-gl-program> ;

: get-texture-uniform-locations ( program -- proj-loc mv-loc sampler-loc )
    {
        [ "projection" glGetUniformLocation ]
        [ "modelview" glGetUniformLocation ]
        [ "tex" glGetUniformLocation ]
    } cleave ;

: setup-texture-vertex-attributes ( -- )
    ! Vertex format: x y u v (4 floats per vertex)
    ! Position attribute (location 0): 2 floats at offset 0
    0 glEnableVertexAttribArray
    0 2 GL_FLOAT GL_FALSE 4 4 * 0 <alien> glVertexAttribPointer
    ! Texcoord attribute (location 1): 2 floats at offset 8 bytes
    1 glEnableVertexAttribArray
    1 2 GL_FLOAT GL_FALSE 4 4 * 2 4 * <alien> glVertexAttribPointer ;

: init-gl3-state ( -- state )
    gl3-state new
    create-gl3-program >>program
    create-gl3-vao >>vao
    create-gl3-vbo >>vbo
    V{ } clone >>modelview-stack
    dup program>> get-uniform-locations
    {
        [ >>projection-loc ]
        [ >>modelview-loc ]
        [ >>color-loc ]
        [ >>use-uniform-color-loc ]
    } spread
    ! Initialize texture rendering state
    create-gl3-texture-program >>tex-program
    create-gl3-vao >>tex-vao
    create-gl3-vbo >>tex-vbo
    dup tex-program>> get-texture-uniform-locations
    {
        [ >>tex-projection-loc ]
        [ >>tex-modelview-loc ]
        [ >>tex-sampler-loc ]
    } spread ;

: bind-gl3-state ( state -- )
    [ vao>> glBindVertexArray ]
    [ vbo>> GL_ARRAY_BUFFER swap glBindBuffer ]
    [ program>> glUseProgram ] tri
    setup-vertex-attributes ;

: upload-matrix ( loc matrix -- )
    [ 1 GL_FALSE ] dip glUniformMatrix4fv ;

: set-gl3-projection ( width height -- )
    make-2d-ortho
    gl3-state> projection-loc>> swap upload-matrix ;

: set-texture-projection ( width height -- )
    make-2d-ortho
    gl3-state> tex-projection-loc>> swap upload-matrix ;

: set-gl3-modelview ( matrix -- )
    gl3-state> modelview-loc>> swap upload-matrix ;

: reset-gl3-modelview ( -- )
    identity-matrix [ current-modelview set-global ] [ set-gl3-modelview ] bi ;

: set-gl3-uniform-color ( color -- )
    gl3-state>
    [ color-loc>> swap >rgba-components glUniform4f ]
    [ use-uniform-color-loc>> 1 glUniform1i ] bi ;

: use-vertex-colors ( -- )
    gl3-state> use-uniform-color-loc>> 0 glUniform1i ;

! --- Drawing Primitives ---

: upload-vertices ( float-array -- )
    ! glBufferData signature: target size data usage
    GL_ARRAY_BUFFER swap [ byte-length ] keep GL_DYNAMIC_DRAW glBufferData ;

! Note: vertices are created inline in make-colored-vertices

:: make-colored-vertices ( points color -- float-array )
    color >rgba-components :> ( r g b a )
    points length 6 * <float-array> :> arr
    points [| pt i |
        pt first  i 6 * 0 + arr set-nth
        pt second i 6 * 1 + arr set-nth
        r         i 6 * 2 + arr set-nth
        g         i 6 * 3 + arr set-nth
        b         i 6 * 4 + arr set-nth
        a         i 6 * 5 + arr set-nth
    ] each-index
    arr ;

! --- High-level Drawing Functions ---

! Create position-only vertices (no color)
:: make-position-vertices ( points -- float-array )
    points length 6 * <float-array> :> arr
    points [| pt i |
        pt first  i 6 * 0 + arr set-nth
        pt second i 6 * 1 + arr set-nth
        ! Fill in dummy color values (uniform color will be used)
        1.0       i 6 * 2 + arr set-nth
        1.0       i 6 * 3 + arr set-nth
        1.0       i 6 * 4 + arr set-nth
        1.0       i 6 * 5 + arr set-nth
    ] each-index
    arr ;

! Version using uniform color (set by gl3-color)
! Note: coordinates are in logical pixels, projection handles scaling
:: gl3-fill-rect* ( loc dim -- )
    loc first :> x1
    loc second :> y1
    x1 dim first + :> x2
    y1 dim second + :> y2
    ! Two triangles for a quad
    {
        { x1 y1 }
        { x2 y1 }
        { x2 y2 }
        { x1 y1 }
        { x2 y2 }
        { x1 y2 }
    } make-position-vertices
    upload-vertices
    GL_TRIANGLES 0 6 glDrawArrays ;

! Version using per-vertex color
:: gl3-fill-rect ( loc dim color -- )
    loc first :> x1
    loc second :> y1
    x1 dim first + :> x2
    y1 dim second + :> y2
    ! Two triangles for a quad
    {
        { x1 y1 }
        { x2 y1 }
        { x2 y2 }
        { x1 y1 }
        { x2 y2 }
        { x1 y2 }
    } color make-colored-vertices
    upload-vertices
    GL_TRIANGLES 0 6 glDrawArrays ;

:: gl3-rect ( loc dim color -- )
    loc first :> x1
    loc second :> y1
    x1 dim first + :> x2
    y1 dim second + :> y2
    ! Line loop as line strip with repeated first point
    {
        { x1 y1 }
        { x2 y1 }
        { x2 y2 }
        { x1 y2 }
        { x1 y1 }
    } color make-colored-vertices
    upload-vertices
    GL_LINE_STRIP 0 5 glDrawArrays ;

! Version using uniform color (set by gl3-color)
:: gl3-rect* ( loc dim -- )
    loc first :> x1
    loc second :> y1
    x1 dim first + :> x2
    y1 dim second + :> y2
    ! Line loop as line strip with repeated first point
    {
        { x1 y1 }
        { x2 y1 }
        { x2 y2 }
        { x1 y2 }
        { x1 y1 }
    } make-position-vertices
    upload-vertices
    GL_LINE_STRIP 0 5 glDrawArrays ;

:: gl3-line ( p1 p2 color -- )
    p1 p2 2array color make-colored-vertices
    upload-vertices
    GL_LINES 0 2 glDrawArrays ;

! Version using uniform color (set by gl3-color)
:: gl3-line* ( p1 p2 -- )
    p1 p2 2array make-position-vertices
    upload-vertices
    GL_LINES 0 2 glDrawArrays ;

! Draw multiple lines from flat vertex array (x1 y1 x2 y2 ...)
! Uses uniform color (set by gl3-color)
:: gl3-draw-lines* ( vertices n -- )
    ! Convert flat vertex array to position vertices with dummy colors
    n 6 * <float-array> :> arr
    n <iota> [| i |
        i 2 * vertices nth     i 6 * 0 + arr set-nth  ! x
        i 2 * 1 + vertices nth i 6 * 1 + arr set-nth  ! y
        1.0                    i 6 * 2 + arr set-nth  ! r
        1.0                    i 6 * 3 + arr set-nth  ! g
        1.0                    i 6 * 4 + arr set-nth  ! b
        1.0                    i 6 * 5 + arr set-nth  ! a
    ] each
    arr upload-vertices
    GL_LINES 0 n glDrawArrays ;

! Draw a single point using uniform color
:: gl3-point* ( pos -- )
    pos 1array make-position-vertices
    upload-vertices
    GL_POINTS 0 1 glDrawArrays ;

! Draw multiple points using uniform color
:: gl3-points* ( points -- )
    points make-position-vertices
    upload-vertices
    GL_POINTS 0 points length glDrawArrays ;

! Draw a filled circle using triangles (triangle fan approximation)
:: gl3-fill-circle* ( center radius segments -- )
    center first :> cx
    center second :> cy
    ! Generate triangle fan vertices: center + (segments+1) rim points
    segments 1 + <iota> [| i |
        i segments / 2 * pi *
        [ cos radius * cx + ]
        [ sin radius * cy + ] bi 2array
    ] map
    ! Add center at the beginning
    cx cy 2array prefix
    make-position-vertices
    upload-vertices
    GL_TRIANGLE_FAN 0 segments 2 + glDrawArrays ;

! Draw a circle outline
:: gl3-circle* ( center radius segments -- )
    center first :> cx
    center second :> cy
    ! Generate line loop vertices
    segments <iota> [| i |
        i segments / 2 * pi *
        [ cos radius * cx + ]
        [ sin radius * cy + ] bi 2array
    ] map
    make-position-vertices
    upload-vertices
    GL_LINE_LOOP 0 segments glDrawArrays ;

! Fill rect without gl-scale (for use after gl3-scale transformations)
:: gl3-fill-rect-raw ( loc dim -- )
    loc first :> x1
    loc second :> y1
    x1 dim first + :> x2
    y1 dim second + :> y2
    ! Two triangles for a quad
    {
        { x1 y1 }
        { x2 y1 }
        { x2 y2 }
        { x1 y1 }
        { x2 y2 }
        { x1 y2 }
    } make-position-vertices
    upload-vertices
    GL_TRIANGLES 0 6 glDrawArrays ;

! glRectf replacement - draws filled rectangle from (x1,y1) to (x2,y2)
:: gl3-rectf ( x1 y1 x2 y2 -- )
    ! Two triangles for a quad
    {
        { x1 y1 }
        { x2 y1 }
        { x2 y2 }
        { x1 y1 }
        { x2 y2 }
        { x1 y2 }
    } make-position-vertices
    upload-vertices
    GL_TRIANGLES 0 6 glDrawArrays ;

! --- Translation Support ---

: gl3-push-matrix ( -- )
    current-modelview get-global clone
    gl3-state> modelview-stack>> push ;

: gl3-pop-matrix ( -- )
    gl3-state> modelview-stack>> pop
    [ current-modelview set-global ]
    [ set-gl3-modelview ] bi ;

:: gl3-translate ( x y -- )
    x y make-translation-matrix :> trans
    current-modelview get-global trans mat4-multiply
    [ current-modelview set-global ]
    [ set-gl3-modelview ] bi ;

:: gl3-scale ( sx sy -- )
    sx sy make-scale-matrix :> scale-mat
    current-modelview get-global scale-mat mat4-multiply
    [ current-modelview set-global ]
    [ set-gl3-modelview ] bi ;

: with-gl3-matrix ( quot -- )
    gl3-push-matrix
    [ call ] [ gl3-pop-matrix ] finally ; inline

: with-gl3-translation ( loc quot -- )
    gl3-push-matrix
    [ first2 gl3-translate ] dip
    [ call ] [ gl3-pop-matrix ] finally ; inline

! --- Public Interface (drop-in replacements) ---

: gl3-color ( color -- )
    set-gl3-uniform-color ;

: gl3-clear ( color -- )
    >rgba-components glClearColor
    GL_COLOR_BUFFER_BIT glClear ;

! --- Initialization ---

: gl3-init ( -- )
    init-gl3-state gl3-render-state set-global
    gl3-state> bind-gl3-state
    identity-matrix [ current-modelview set-global ] [ set-gl3-modelview ] bi
    GL_BLEND glEnable
    GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
    GL_PACK_ALIGNMENT 1 glPixelStorei
    GL_UNPACK_ALIGNMENT 1 glPixelStorei ;

: gl3-reshape ( width height -- )
    2dup 2array current-projection-dim set-global
    set-gl3-projection
    reset-gl3-modelview ;

! --- GL3 Draw Init (per-frame) ---

! GL3 version of init-clip - same as legacy but without glOrtho
! Note: gl-viewport and gl-set-clip already handle gl-scale internally via fix-coordinates
: gl3-init-clip ( gadget -- )
    [
        dim>>
        [ { 0 1 } v* viewport-translation namespaces:set ]
        [ [ { 0 0 } ] dip gl-viewport ] bi
        ! Note: glOrtho is replaced by shader-based projection in gl3-reshape
    ]
    [ clip namespaces:set ] bi
    do-clip ;

: gl3-draw-init ( dim background-color -- )
    GL_SCISSOR_TEST glEnable
    GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
    [ first2 gl3-reshape ] [ gl3-clear ] bi* ;

! --- GL3 Texture Rendering ---

! GL3-compatible texture creation (no deprecated glPushAttrib/glPopAttrib)
:: make-texture-gl3 ( image -- id )
    image image-format :> ( internal-format format type )
    gen-texture :> tex-id
    GL_TEXTURE_2D tex-id glBindTexture
    ! Set texture parameters
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP_TO_EDGE glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP_TO_EDGE glTexParameteri
    ! Upload texture data
    GL_TEXTURE_2D 0 internal-format
    image dim>> first2 0
    format type image bitmap>> glTexImage2D
    ! Unbind
    GL_TEXTURE_2D 0 glBindTexture
    tex-id ;

: bind-texture-state ( -- )
    gl3-state>
    [ tex-vao>> glBindVertexArray ]
    [ tex-vbo>> GL_ARRAY_BUFFER swap glBindBuffer ]
    [ tex-program>> glUseProgram ] tri
    setup-texture-vertex-attributes ;

: restore-color-state ( -- )
    gl3-state> bind-gl3-state ;

:: make-textured-quad-vertices ( loc dim -- float-array )
    ! Both loc and dim are in logical pixels
    ! Projection handles scaling to device pixels
    loc first :> x1
    loc second :> y1
    x1 dim first + :> x2
    y1 dim second + :> y2
    ! Vertices: x y u v (two triangles)
    [
        x1 y1 0.0 0.0
        x2 y1 1.0 0.0
        x2 y2 1.0 1.0
        x1 y1 0.0 0.0
        x2 y2 1.0 1.0
        x1 y2 0.0 1.0
    ] float-array{ } output>sequence ;

:: make-textured-quad-vertices-flipped ( loc dim -- float-array )
    ! Both loc and dim are in logical pixels
    ! Projection handles scaling to device pixels
    loc first :> x1
    loc second :> y1
    x1 dim first + :> x2
    y1 dim second + :> y2
    ! Vertices: x y u v (two triangles) - V flipped for upside-down textures
    [
        x1 y1 0.0 1.0
        x2 y1 1.0 1.0
        x2 y2 1.0 0.0
        x1 y1 0.0 1.0
        x2 y2 1.0 0.0
        x1 y2 0.0 0.0
    ] float-array{ } output>sequence ;

: upload-textured-vertices ( float-array -- )
    ! glBufferData signature: target size data usage
    GL_ARRAY_BUFFER swap [ byte-length ] keep GL_DYNAMIC_DRAW glBufferData ;

:: gl3-draw-texture ( loc dim texture-id flipped? -- )
    bind-texture-state
    ! Use stored projection dimensions for consistency with color shader
    current-projection-dim get-global first2 set-texture-projection
    current-modelview get-global gl3-state> tex-modelview-loc>> swap upload-matrix
    ! Bind texture
    GL_TEXTURE0 glActiveTexture
    GL_TEXTURE_2D texture-id glBindTexture
    gl3-state> tex-sampler-loc>> 0 glUniform1i
    ! Upload vertices and draw
    flipped? [ loc dim make-textured-quad-vertices-flipped ]
             [ loc dim make-textured-quad-vertices ] if
    upload-textured-vertices
    GL_TRIANGLES 0 6 glDrawArrays
    ! Unbind texture
    GL_TEXTURE_2D 0 glBindTexture
    ! Restore color rendering state
    restore-color-state ;

! --- Cleanup ---

: cleanup-gl3-state ( -- )
    gl3-state> [
        {
            [ program>> glDeleteProgram ]
            [ vao>> 1 swap uint <ref> glDeleteVertexArrays ]
            [ vbo>> 1 swap uint <ref> glDeleteBuffers ]
            [ tex-program>> [ glDeleteProgram ] when* ]
            [ tex-vao>> [ 1 swap uint <ref> glDeleteVertexArrays ] when* ]
            [ tex-vbo>> [ 1 swap uint <ref> glDeleteBuffers ] when* ]
        } cleave
    ] when*
    f gl3-render-state set-global ;
