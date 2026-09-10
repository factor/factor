! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
! Run with a GTK3 image and a display: -run=ui.backend.gtk3.smoke-test
USING: accessors alien.c-types alien.data calendar continuations debugger
io kernel locals math namespaces opengl opengl.capabilities opengl.gl
sequences system threads ui ui.backend ui.backend.gtk3 ui.clipboards
ui.gadgets.labels ui.gadgets.worlds ui.pixel-formats ;
IN: ui.backend.gtk3.smoke-test

: smoke-error ( error -- ) print-error nl flush 1 exit ;

:: attachment-bits ( attachment parameter -- n )
    GL_FRAMEBUFFER attachment parameter { int }
    [ glGetFramebufferAttachmentParameteriv ] with-out-parameters ;

:: check-framebuffer ( world -- )
    world set-gl-context
    world handle>> window-framebuffer :> framebuffer
    framebuffer 0 > t assert=
    GL_DRAW_FRAMEBUFFER_BINDING { int } [ glGetIntegerv ] with-out-parameters
    framebuffer assert=
    GL_FRAMEBUFFER glCheckFramebufferStatus GL_FRAMEBUFFER_COMPLETE assert=
    GL_DEPTH_ATTACHMENT GL_FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE attachment-bits 24 >= t assert=
    GL_STENCIL_ATTACHMENT GL_FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE attachment-bits 8 >= t assert=
    gl-error ;

:: exercise-windows ( first-world -- )
    500 milliseconds sleep
    first-world check-framebuffer
    current-gl-context :> first-context
    gl-extensions empty? f assert= gl-error
    "GTK3 clipboard λ ✓" >clipboard
    clipboard> "GTK3 clipboard λ ✓" assert=
    "Independent GL context" <label> "GTK3 second window" open-window* :> second-world
    500 milliseconds sleep
    second-world set-gl-context current-gl-context first-context = f assert=
    second-world close-window
    first-world { 640 360 } resize-window
    500 milliseconds sleep
    first-world check-framebuffer
    first-world draw-world
    close-all-windows ;

: gtk3-smoke-test ( -- )
    ui-backend-available? t assert=
    [ smoke-error ] ui-error-hook set-global
    [
        "GTK3 framebuffer and clipboard smoke test" <label>
        <world-attributes> "GTK3 smoke test" >>title { 480 240 } >>pref-dim
        { windowed double-buffered T{ depth-bits { value 24 } } T{ stencil-bits { value 8 } } }
        >>pixel-format-attributes open-window*
        '[ _ [ exercise-windows ] [ smoke-error ] recover ] "GTK3 smoke test" spawn drop
    ] with-ui
    "GTK3 smoke test passed" print ;

MAIN: gtk3-smoke-test
