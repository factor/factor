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
64 capture-height set-global
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

:: compare-line-tiles ( line scroll phase -- )
    world get world-text-handle assoc-size :> previous-tiles
    line prepare-render
    reset-frame
    line loc>> scroll v+ [ neg gl-unscale ] map
    phase 0 2array v+ first2 gl3-translate
    line draw-line-tiles
    pixels "-tiled.rgba" save-capture
    world get text-handle>> assoc-size :> tile-count
    tile-count previous-tiles - 12 <= t assert=
    line draw-line-tiles
    world get text-handle>> assoc-size tile-count assert=
    reset-frame
    scroll { 2 2 } v- { 0 0 } vmax :> offset
    line offset target-dim { 4 4 } v+ line render-ext>> offset v- vmin
    render-region :> reference
    GL_ONE GL_ONE_MINUS_SRC_ALPHA glBlendFunc
    reference make-texture-gl3 :> tex
    offset scroll v- scale-dim phase 0 2array v+
    reference dim>> scale-dim tex f gl3-draw-texture
    pixels "-reference.rgba" save-capture
    tex delete-texture
    gl-scale-factor get-global :> scale
    capture-height get-global :> height
    { "tiles" scale scroll phase tile-count height } emit
    case-number [ 1 + ] change-global ;



SPECIALIZED-ARRAY: alien.c-types:float
SYMBOL: baseline-vertices
:: capture-vertices ( -- )
    H{ } clone baseline-vertices set-global
    world get text-handle>> values [| tile |
        GL_ARRAY_BUFFER tile vbo>> glBindBuffer
        24 <float-array> :> vertices
        GL_ARRAY_BUFFER 0 96 vertices glGetBufferSubData
        vertices tile vao>> baseline-vertices get-global set-at
    ] each
    restore-color-state ;

! The committed path: dynamic upload, attribute setup and uniforms per tile.
:: baseline-texture ( vertices texture -- )
    bind-texture-state
    gl3-state> tex-projection-loc>>
    current-projection-dim get-global first2 make-2d-ortho upload-matrix
    current-modelview get-global gl3-state> tex-modelview-loc>> swap upload-matrix
    GL_TEXTURE0 glActiveTexture
    GL_TEXTURE_2D texture glBindTexture
    gl3-state> tex-sampler-loc>> 0 glUniform1i
    vertices upload-textured-vertices
    GL_TRIANGLES 0 6 glDrawArrays
    GL_TEXTURE_2D 0 glBindTexture restore-color-state ;
:: baseline-line ( line -- )
    line text-clip visible-tile-offsets :> offsets
    GL_ONE GL_ONE_MINUS_SRC_ALPHA glBlendFunc
    [
        offsets [
            line swap cached-text-tile
            [ vao>> baseline-vertices get-global at ] [ texture>> ] bi baseline-texture
        ] each
    ] [ GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc ] finally ;
:: baseline-translate ( x y -- )
    x y make-translation-matrix :> translation
    current-modelview get-global translation mat4-multiply
    [ current-modelview set-global ] [ set-gl3-modelview ] bi ;
:: paired-frame ( font lines old? -- )
    reset-frame
    lines [
        font swap cached-line old? [ baseline-line ] [ draw-line-tiles ] if
        0 18 old? [ baseline-translate ] [ gl3-translate ] if
    ] each ;
:: measure-mode ( font lines count old? -- ns )
    [ count [ font lines old? paired-frame ] times glFinish ] benchmark ;
:: paired-case ( font lines count label -- )
    font lines f paired-frame glFinish capture-vertices
    font lines t paired-frame pixels "-baseline.rgba" save-capture
    font lines f paired-frame pixels "-cached.rgba" save-capture
    5 <iota> [| i |
        i even? [
            font lines count t measure-mode font lines count f measure-mode
        ] [
            font lines count f measure-mode font lines count t measure-mode swap
        ] if 2array
    ] map :> samples
    samples [ first ] map median :> old
    samples [ second ] map median :> new
    { label old new samples } emit
    case-number [ 1 + ] change-global ;
: paired-benchmark ( -- )
    f gl-scale-factor set-global
    sans-serif-font COLOR: white >>foreground T{ rgba f 0 0 0 0 } >>background
    100 <iota> [ number>string "Drawing warm cached text " prepend ] map
    100 "100-lines-100-repaints-ns" paired-case
    world get text-handle>> clear-assoc
    sans-serif-font COLOR: white >>foreground T{ rgba f 0 0 0 0 } >>background
    10000 CHAR: W <string> 1array 1000 "long-line-1000-repaints-ns" paired-case ;
init-context
setup-gl3-hooks gl3-init
T{ world } clone world set-global
init-target
2048 capture-height set-global
paired-benchmark
world get text-handle>> dispose
delete-framebuffer delete-texture cleanup-gl3-state
CGLDestroyContext 0 assert=
