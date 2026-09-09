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
    "reference/macos-text-shaping-20260909/" prepend binary set-file-contents ;

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
    tile-count previous-tiles - 24 <= t assert=
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


USING: core-foundation core-foundation.attributed-strings core-text.fonts ;
:: shaping-line ( font string mode -- line )
    [
        font cache-font :> open-font
        open-font font foreground>> make-attributes clone :> attrs
        mode kCTLigatureAttributeName attrs set-at
        string dup selection? [ string>> ] when attrs
        <CFAttributedString> &CFRelease CTLineCreateWithAttributedString |CFRelease :> ctline
        line new-disposable font >>font string >>string ctline >>line
        open-font ctline compute-line-metrics
        [ >>metrics ] [ metrics>dim >>dim ] bi
    ] with-destructors ;

:: compare-cluster ( string scale phase -- )
    scale gl-scale-factor set-global
    sans-serif-font "Hoefler Text" >>name 40 >>size COLOR: white >>foreground
    T{ rgba f 0 0 0 0 } >>background :> font
    font string 2 shaping-line &dispose metrics>> width>> :> width
    font 28000 width / >>size string 2 shaping-line &dispose :> line
    line prepare-render
    line render-ext>> first 512 > t assert=
    line render-ext>> second 2048 min capture-height set-global
    line render-ext>> :> ext
    { "cluster" string scale phase ext } emit
    line { 0 0 } phase compare-line-tiles ;

: corpus ( -- )
    { "fi" "ffi" "ffl" "st" "ct" "ạ́" "👩‍💻" "👨‍👩‍👧‍👦" "👍🏽" "🇺🇸" "1️⃣" "لا" "क्षि" "বাংলা" } [
        dup f 0 compare-cluster 2.0 0.25 compare-cluster
    ] each
    2.0 gl-scale-factor set-global
    128 capture-height set-global
    sans-serif-font "Hoefler Text" >>name 32 >>size
    T{ rgba f 0 0 0 0 } >>background
    100 [ "office affinity st ct é 👩‍💻 العربية क्षि ไทย abc אבג def " ] replicate concat
    3 400 COLOR: blue <selection> 2 shaping-line &dispose
    { 1000 0 } 0.25 compare-line-tiles ;

<< { compare-line-tiles compare-cluster corpus } [ t "no-compile" set-word-prop ] each >>

: run-corpus ( -- )
    [
        init-context
        setup-gl3-hooks gl3-init
        T{ world } clone world set-global
        init-target
        corpus
        world get text-handle>> dispose
        delete-framebuffer delete-texture cleanup-gl3-state
        CGLDestroyContext 0 assert=
    ] with-destructors ;
<< \ run-corpus t "no-compile" set-word-prop >>
run-corpus
