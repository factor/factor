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
    "reference/macos-text-optimization-20260909/" prepend binary set-file-contents ;

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

:: test-tiles ( scale scroll phase -- )
    scale gl-scale-factor set-global
    sans-serif-font COLOR: white >>foreground T{ rgba f 0 0 0 0 } >>background
    500 [ "fi é 👩‍💻 العربية W " ] replicate concat cached-line
    scroll 0 2array phase compare-line-tiles ;

: test-tall-and-selection ( -- )
    1024 capture-height set-global
    2.0 gl-scale-factor set-global
    sans-serif-font 300 >>size COLOR: white >>foreground
    T{ rgba f 0 0 0 0 } >>background
    "jfy Ág é 日本語 🍆" cached-line { 1000 200 } 0.25 compare-line-tiles
    64 capture-height set-global
    sans-serif-font T{ rgba f 0 0 0 0 } >>background
    300 [ "a     " ] replicate concat 10 1700 COLOR: blue <selection>
    cached-line { 1000 0 } 0.25 compare-line-tiles ;

! These fixtures are orchestration; keep production rendering and benchmark
! loops optimized while avoiding specialization of the large capture fixture.
<< { compare-line-tiles test-tiles test-tall-and-selection }
   [ t "no-compile" set-word-prop ] each >>

:: repaint-benchmark ( -- )
    f gl-scale-factor set-global
    world get text-handle>> clear-assoc
    sans-serif-font :> font
    100 <iota> [ number>string "Many lines: text sample " prepend ] map :> lines
    lines [ font swap cached-line line>image drop ] each
    3 [
        [
            20 [
                reset-frame
                lines [ font swap draw-string-default 0 18 gl3-translate ] each
            ] times glFinish
        ] benchmark
    ] replicate median :> old
    reset-frame lines [ font swap draw-string 0 18 gl3-translate ] each
    world get text-handle>> assoc-size :> entries
    3 [
        [
            20 [
                reset-frame
                lines [ font swap draw-string 0 18 gl3-translate ] each
            ] times glFinish
        ] benchmark
    ] replicate median :> new
    world get text-handle>> assoc-size entries assert=
    { "100-lines-20-repaints-ns" old new entries } emit ;

:: measurement-benchmark ( -- )
    <editor> :> editor
    sans-serif-font :> font
    10000 <iota> [ number>string "Document line " prepend ] map :> lines
    font lines editor editor-text-dim :> expected
    3 [
        cached-lines get-global clear-assoc
        [ font lines text-dim expected assert= ] benchmark
    ] replicate median :> old
    3 [
        cached-lines get-global clear-assoc
        [ font lines editor editor-text-dim expected assert= ] benchmark
    ] replicate median :> new
    cached-lines get-global assoc-size :> layouts
    { "10000-line-reflow-ns" old new layouts } emit
    lines editor model>> set-model
    { 0 0 } editor mark>> set-model
    { 9999 0 } editor caret>> set-model
    { 0 0 } origin set
    { 0 1000 } { 800 400 } <rect> clip set
    editor compute-selection assoc-size :> selected
    { "selected-visible-rows" selected } emit
    selected 100 < t assert= ;

init-context
setup-gl3-hooks gl3-init
{ "gl-ready" } emit
T{ world } clone world set-global
init-target
f 20000 0 test-tiles
2.0 20000 0 test-tiles
2.0 20000 0.25 test-tiles
test-tall-and-selection
repaint-benchmark
measurement-benchmark
world get text-handle>> values [ texture>> ] map
world get text-handle>> dispose
[ glIsTexture GL_FALSE = ] all? t assert=
delete-framebuffer delete-texture
cleanup-gl3-state
CGLDestroyContext 0 assert=
