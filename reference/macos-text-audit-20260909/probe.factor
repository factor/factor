USING: accessors alien alien.c-types alien.data alien.libraries alien.syntax
arrays byte-arrays colors core-graphics core-text fonts images io io.encodings.binary
io.files json kernel locals math math.vectors namespaces opengl opengl.framebuffers
opengl.gl opengl.textures sequences specialized-arrays strings tools.test ui.render ;
SPECIALIZED-ARRAY: int
IN: macos-text-audit

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

: emit ( object -- ) >json print ;

: save-bytes ( bytes name -- )
    "reference/macos-text-audit-20260909/" prepend binary set-file-contents ;

:: capture ( image source-factor phase name -- )
    image dim>> first2 :> ( w h )
    gen-texture :> target
    GL_TEXTURE_2D target glBindTexture
    GL_TEXTURE_2D 0 GL_RGBA8 w h 0 GL_RGBA GL_UNSIGNED_BYTE f glTexImage2D
    gen-framebuffer :> fb
    GL_FRAMEBUFFER fb glBindFramebuffer
    GL_FRAMEBUFFER GL_COLOR_ATTACHMENT0 GL_TEXTURE_2D target 0 glFramebufferTexture2D
    check-framebuffer
    0 0 w h glViewport
    w h gl3-reshape
    0.0 0.0 0.0 1.0 glClearColor
    GL_COLOR_BUFFER_BIT glClear
    source-factor GL_ONE_MINUS_SRC_ALPHA glBlendFunc
    image make-texture-gl3 :> source
    phase 0 2array image dim>> source image upside-down?>> gl3-draw-texture
    w h * 4 * <byte-array> :> pixels
    0 0 w h GL_RGBA GL_UNSIGNED_BYTE pixels glReadPixels
    glGetError 0 assert=
    pixels name save-bytes
    source delete-texture
    fb delete-framebuffer
    target delete-texture ;

:: sample-line ( scale label -- )
    scale gl-scale-factor set-global
    sans-serif-font COLOR: white >>foreground T{ rgba f 0 0 0 0 } >>background
    "Hamburgefontsiv AV fi é 日本語" cached-line :> line
    line line>image :> image
    label image dim>> line loc>> line metrics>> ascent>> 4array emit
    image bitmap>> label "-source.bgra" append save-bytes
    image GL_SRC_ALPHA 0 label "-current.rgba" append capture
    image GL_ONE 0 label "-reference.rgba" append capture
    image GL_ONE 0.5 label "-half-pixel.rgba" append capture
    image dim>> [
        dup line render-loc>> { -0.5 0 } v+ set-text-position
        line line>> swap CTLineDraw
    ] core-graphics:make-bitmap-image :> native-phase
    native-phase GL_ONE 0 label "-native-phase.rgba" append capture ;

:: bounds-probe ( string italic? label -- )
    sans-serif-font italic? >>italic?
        COLOR: white >>foreground T{ rgba f 0 0 0 0 } >>background
    string cached-line :> line
    line line>image :> image
    image bitmap>> label "-source.bgra" append save-bytes
    image dim>> { 32 32 } v+ [
        dup line render-loc>> { 16 16 } v- set-text-position
        line line>> swap CTLineDraw
    ] core-graphics:make-bitmap-image :> padded
    padded bitmap>> label "-padded.bgra" append save-bytes
    label image dim>> line dim>> line loc>> 4array emit ;

:: selection-probe ( -- )
    sans-serif-font T{ rgba f 0 0 0 0 } >>background
    "     " 0 5 COLOR: blue <selection> cached-line :> line
    line line>image :> image
    image bitmap>> "spaces-selection.bgra" save-bytes
    "spaces-selection" image dim>> line dim>> 3array emit ;

:: long-line-probe ( -- )
    sans-serif-font T{ rgba f 0 0 0 0 } >>background
    3000 CHAR: W <string> cached-line :> line
    line line>image :> image
    "long-line" image dim>> line dim>> 3array emit ;

init-context gl3-init
f "1x" sample-line
2.0 "2x" sample-line
"jfy Ág é ạ́ 日本語" t "bounds-italic-2x" bounds-probe
"👩‍💻 🇯🇵 🍆" f "bounds-emoji-2x" bounds-probe
selection-probe
long-line-probe
CGLDestroyContext 0 assert=
