! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Run with a GTK2 image and a display: -run=ui.backend.gtk2.smoke-test
USING: accessors alien.c-types alien.data calendar continuations debugger
gtk2.gl.ffi
io kernel locals math namespaces opengl opengl.capabilities opengl.gl
sequences system threads ui ui.backend ui.backend.gtk2 ui.clipboards
ui.gadgets.labels ui.gadgets.worlds ui.pixel-formats ;
IN: ui.backend.gtk2.smoke-test

: smoke-error ( error -- ) print-error nl flush 1 exit ;

:: check-framebuffer ( world -- )
    world set-gl-context
    world handle>> window-framebuffer 0 assert=
    GL_FRAMEBUFFER glCheckFramebufferStatus GL_FRAMEBUFFER_COMPLETE assert=
    GL_DEPTH_BITS { int } [ glGetIntegerv ] with-out-parameters 24 >= t assert=
    GL_STENCIL_BITS { int } [ glGetIntegerv ] with-out-parameters 8 >= t assert=
    gl-error ;

: widget-gl-context ( world -- context )
    handle>> drawable>> gtk_widget_get_gl_context ;

:: exercise-windows ( first-world -- )
    500 milliseconds sleep
    first-world check-framebuffer
    first-world widget-gl-context :> first-context
    first-context f = f assert=
    gl-extensions empty? f assert= gl-error
    "GTK2 clipboard λ ✓" >clipboard
    clipboard> "GTK2 clipboard λ ✓" assert=
    "Independent GL context" <label> "GTK2 second window" open-window* :> second-world
    500 milliseconds sleep
    second-world set-gl-context
    second-world widget-gl-context :> second-context
    second-context f = f assert=
    second-context first-context = f assert=
    second-world close-window
    first-world { 640 360 } resize-window
    500 milliseconds sleep
    first-world check-framebuffer
    first-world draw-world
    close-all-windows ;

: gtk2-smoke-test ( -- )
    ui-backend-available? t assert=
    [ smoke-error ] ui-error-hook set-global
    [
        "GTK2 framebuffer and clipboard smoke test" <label>
        <world-attributes> "GTK2 smoke test" >>title { 480 240 } >>pref-dim
        { windowed double-buffered T{ depth-bits { value 24 } } T{ stencil-bits { value 8 } } }
        >>pixel-format-attributes open-window*
        '[ _ [ exercise-windows ] [ smoke-error ] recover ] "GTK2 smoke test" spawn drop
    ] with-ui
    "GTK2 smoke test passed" print ;

MAIN: gtk2-smoke-test
