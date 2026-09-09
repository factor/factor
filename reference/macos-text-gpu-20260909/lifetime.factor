USING: accessors alien alien.c-types alien.data alien.libraries alien.syntax
arrays byte-arrays colors core-graphics core-text fonts images io io.encodings.binary
io.files json kernel locals math math.vectors namespaces opengl opengl.framebuffers
opengl.gl opengl.textures sequences specialized-arrays strings tools.test ui.render ;
SPECIALIZED-ARRAY: int
IN: macos-text-optimization

"audit-cgl" "/System/Library/Frameworks/OpenGL.framework/OpenGL" cdecl add-library
LIBRARY: audit-cgl
FUNCTION: int CGLChoosePixelFormat ( int* attrs, void** format, int* count )
FUNCTION: int CGLCreateContext ( void* format, void* share, void** context )
FUNCTION: int CGLSetCurrentContext ( void* context )
FUNCTION: int CGLDestroyPixelFormat ( void* format )
FUNCTION: int CGLDestroyContext ( void* context )

: init-context ( -- context )
    int-array{ 99 0x3200 0 } { void* int }
    [ CGLChoosePixelFormat 0 assert= ] with-out-parameters drop
    dup f { void* } [ CGLCreateContext 0 assert= ] with-out-parameters
    swap CGLDestroyPixelFormat 0 assert=
    dup CGLSetCurrentContext 0 assert= ;

USING: assocs cache combinators continuations documents math.order math.parser
math.rectangles math.statistics math.vectors models prettyprint destructors
strings tools.time words ui.gadgets ui.gadgets.editors
ui.gadgets.editors.private ui.gadgets.line-support ui.gadgets.worlds
ui.render ui.text ui.text.private ui.text.core-text
ui.text.core-text.private ;

CONSTANT: target-dim { 1024 2048 }
SYMBOL: capture-height
128 capture-height set-global
SYMBOL: case-number
0 case-number set-global

: emit ( object -- ) >json print flush ;

: save-capture ( bytes suffix -- )
    case-number get-global number>string prepend
    "reference/macos-text-gpu-20260909/" prepend binary set-file-contents ;

:: init-target ( -- texture framebuffer )
    gen-texture :> texture
    GL_TEXTURE_2D texture glBindTexture
    GL_TEXTURE_2D 0 GL_RGBA8 target-dim first2 0 GL_RGBA GL_UNSIGNED_BYTE f glTexImage2D
    gen-framebuffer :> framebuffer
    GL_FRAMEBUFFER framebuffer glBindFramebuffer
    GL_FRAMEBUFFER GL_COLOR_ATTACHMENT0 GL_TEXTURE_2D texture 0 glFramebufferTexture2D
    check-framebuffer
    0 0 target-dim first2 glViewport texture framebuffer ;

: reset-frame ( -- )
    target-dim [ gl-unscale ] map first2 gl3-reshape
    0.0 0.0 0.0 1.0 glClearColor GL_COLOR_BUFFER_BIT glClear
    { 0 0 } target-dim [ gl-unscale ] map <rect> clip set ;

: pixels ( -- bytes )
    target-dim first capture-height get-global * 4 * <byte-array>
    [ 0 target-dim second capture-height get-global -
      target-dim first capture-height get-global GL_RGBA GL_UNSIGNED_BYTE ] dip
    [ glReadPixels ] keep glGetError 0 assert= ;


:: selection-probe ( scale -- )
    scale gl-scale-factor set-global
    reset-frame
    <editor>
    sans-serif-font 20 >>size T{ rgba f 0 0 0 0 } >>background >>font
    T{ rgba f 0 0 1 0.5 } >>selection-color 40 >>line-height :> editor
    "          " { 0 10 } editor draw-selected-line
    pixels :> bitmap
    { 5 10 35 } [| y |
        128 1 - y gl-scale >integer - 1024 * 5 gl-scale >integer + 4 * 2 + bitmap nth
    ] map :> blue
    blue [ 128 = ] all? t assert=
    { "translucent-selection-blue" scale blue } emit ;

USING: sets ;
:: cache-probe ( -- )
    f gl-scale-factor set-global
    T{ world } clone :> a
    T{ world } clone :> b
    sans-serif-font :> font
    a world set-global reset-frame font "cache lifetime" draw-string
    a text-handle>> values [ texture>> ] map :> ids-a
    a text-handle>> values [ vao>> ] map :> vaos-a
    a text-handle>> values [ vbo>> ] map :> vbos-a
    b world set-global reset-frame font "cache lifetime" draw-string
    b text-handle>> values [ texture>> ] map :> ids-b
    b text-handle>> values [ vao>> ] map :> vaos-b
    b text-handle>> values [ vbo>> ] map :> vbos-b
    ids-a ids-b intersect empty? t assert=
    a text-handle>> 1 >>max-age purge-cache
    ids-a [ glIsTexture GL_FALSE = ] all? t assert=
    ids-b [ glIsTexture GL_TRUE = ] all? t assert=
    vaos-a [ glIsVertexArray GL_FALSE = ] all? t assert=
    vbos-a [ glIsBuffer GL_FALSE = ] all? t assert=
    vaos-b [ glIsVertexArray GL_TRUE = ] all? t assert=
    vbos-b [ glIsBuffer GL_TRUE = ] all? t assert=
    a world set-global reset-frame font "cache lifetime" draw-string
    a text-handle>> values [ texture>> glIsTexture GL_TRUE = ] all? t assert=
    a text-handle>> dispose
    b text-handle>> dispose
    vaos-b [ glIsVertexArray GL_FALSE = ] all? t assert=
    vbos-b [ glIsBuffer GL_FALSE = ] all? t assert=
    { "cache-isolation-expiry-recreation" t } emit ;


SPECIALIZED-ARRAY: alien.c-types:float
:: projection-probe ( -- )
    T{ world } clone world set-global
    f gl-scale-factor set-global
    sans-serif-font COLOR: white >>foreground T{ rgba f 0 0 0 0 } >>background :> font
    reset-frame font "projection invalidation" draw-string pixels :> expected
    gl3-state> tex-program>> glUseProgram
    gl3-state> tex-projection-loc>> 16 <float-array> upload-matrix
    restore-color-state
    reset-frame font "projection invalidation" draw-string pixels expected assert=
    512 1024 gl3-reshape font "resized projection" draw-string
    16 <float-array> :> matrix
    gl3-state> [ tex-program>> ] [ tex-projection-loc>> ] bi matrix glGetUniformfv
    matrix first 0.00390625 assert=
    5 matrix nth -0.001953125 assert=
    world get text-handle>> dispose
    { "projection-frame-invalidation-and-resize" t } emit ;

init-context
setup-gl3-hooks gl3-init
T{ world } clone world set-global
init-target
f selection-probe
2.0 selection-probe
world get text-handle>> dispose
cache-probe
projection-probe
delete-framebuffer delete-texture cleanup-gl3-state
CGLDestroyContext 0 assert=
