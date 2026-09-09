! Run with factor.com -no-user-init reference/editor-selection-regression.factor.
! Creates a hidden, independent OpenGL test window and closes it on completion.
USING: vocabs.loader ;
<< "windows.gdi32" reload "windows.offscreen" reload "windows.fonts" reload
   "windows.uniscribe" reload "windows.directwrite" reload "windows.directwrite.render" reload
   "ui.text" reload "ui.text.uniscribe" reload "ui.text.directwrite" reload
   "ui.gadgets.editors" reload >>
USING: accessors arrays byte-arrays calendar colors continuations fonts
io kernel locals math namespaces opengl opengl.gl opengl.textures
prettyprint sequences system threads tools.test ui ui.backend.windows
ui.gadgets ui.gadgets.editors ui.gadgets.editors.private ui.gadgets.worlds
ui.text ui.text.private ui.text.uniscribe ui.text.directwrite ;

! Suppress showing/focusing this test process's own window.
IN: ui.backend.windows
: show-window ( hwnd -- ) drop ;
IN: editor-selection-regression

: legacy-test-context ( -- )
    { gl3-mode? gl-color-hook gl-fill-rect-hook gl-translate-hook
      with-translation-hook with-matrix-hook make-texture-hook draw-texture-hook }
    [ f swap set-global ] each
    1.0 gl-scale-factor set-global
    0 0 128 128 glViewport
    GL_PROJECTION glMatrixMode glLoadIdentity 0 128 128 0 -1 1 glOrtho
    GL_MODELVIEW glMatrixMode glLoadIdentity
    GL_SCISSOR_TEST glDisable GL_DEPTH_TEST glDisable
    GL_BLEND glEnable GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA glBlendFunc
    GL_VERTEX_ARRAY glEnableClientState
    GL_PACK_ALIGNMENT 1 glPixelStorei GL_UNPACK_ALIGNMENT 1 glPixelStorei
    GL_BACK glDrawBuffer GL_BACK glReadBuffer ;

:: selection-sample ( renderer line pair sample-x -- pixel )
    renderer font-renderer [
        COLOR: white gl-clear
        GL_MODELVIEW glMatrixMode glLoadIdentity 10 10 0 glTranslated
        <editor> "Consolas" <font> 20 >>size
        0 0 0 0 <rgba> >>background
        0 0 0 0 <rgba> >>foreground >>font
        1 0 0 0.5 <rgba> >>selection-color :> editor
        line pair editor draw-selected-line
        glFinish
        4 <byte-array> :> pixel
        sample-x 112 1 1 GL_RGBA GL_UNSIGNED_BYTE pixel glReadPixels
        gl-error pixel 3 head
    ] with-variable ;

:: selection-pixel ( renderer pair -- pixel )
    renderer "   " pair 15 selection-sample ;

:: bidi-gap-pixel ( renderer -- pixel )
    renderer font-renderer [
        "abc \u0005d0\u0005d1\u0005d2 xyz" :> text
        "Consolas" <font> 20 >>size :> font
        5 font text offset>x 6 font text offset>x + 2 / >integer 10 + :> x
        renderer text { 1 5 } x selection-sample
    ] with-variable ;

: run-selection-tests ( -- )
    { B{ 255 127 127 } } [ uniscribe-renderer { 0 3 } selection-pixel ] unit-test
    { B{ 255 127 127 } } [ directwrite-renderer { 0 3 } selection-pixel ] unit-test
    ! A collapsed selection still draws the editor's one-pixel caret rectangle.
    { B{ 255 128 128 } } [ uniscribe-renderer "   " { 0 0 } 10 selection-sample ] unit-test
    { B{ 255 128 128 } } [ directwrite-renderer "   " { 0 0 } 10 selection-sample ] unit-test
    ! The visual gap between selected LTR and RTL runs remains unpainted.
    { B{ 255 255 255 } } [ uniscribe-renderer bidi-gap-pixel ] unit-test
    { B{ 255 255 255 } } [ directwrite-renderer bidi-gap-pixel ] unit-test ;

:: run-test-window ( gadget -- )
    1 seconds sleep
    gadget find-world :> test-world
    test-world set-gl-context legacy-test-context
    test-world world [
        [ run-selection-tests ] [ . flush 1 exit ] recover
    ] with-variable
    :test-failures test-failures get length . flush
    gadget close-window test-failures get empty? 0 1 ? exit ;

[
    <gadget> { 128 128 } >>dim dup "Editor selection GPU regression" open-window
    [ run-test-window ] curry "Editor selection GPU regression" spawn drop
] with-ui
