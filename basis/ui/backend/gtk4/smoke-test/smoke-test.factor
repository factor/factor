! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
! Run with a GTK4 image and a display: -run=ui.backend.gtk4.smoke-test
USING: accessors alien.c-types alien.data calendar continuations debugger io
kernel locals math namespaces opengl opengl.gl system threads
ui ui.backend ui.backend.gtk4 ui.clipboards
ui.gadgets.labels ui.gadgets.worlds ;
IN: ui.backend.gtk4.smoke-test

: smoke-error ( error -- )
    print-error nl "GTK4 smoke test failed" print flush 1 exit ;

ERROR: gtk4-window-not-ready title active? dim ;

:: wait-for-window ( world -- )
    nano-count 10,000,000,000 + :> deadline
    [ world draw-world? not nano-count deadline < and ] [
        20 milliseconds sleep
    ] while
    world draw-world? [
        world [ title>> ] [ active?>> ] [ dim>> ] tri gtk4-window-not-ready
    ] unless ;

:: check-framebuffer ( world -- )
    world set-gl-context
    world handle>> window-framebuffer :> framebuffer
    framebuffer 0 > t assert=
    GL_DRAW_FRAMEBUFFER_BINDING { int } [ glGetIntegerv ] with-out-parameters
    framebuffer assert=
    GL_FRAMEBUFFER glCheckFramebufferStatus GL_FRAMEBUFFER_COMPLETE assert=
    gl-error ;

:: exercise-windows ( first-world -- )
    first-world wait-for-window
    first-world check-framebuffer
    first-world set-gl-context current-gl-context :> first-context
    first-context f = f assert=
    "GTK4 clipboard λ ✓" >clipboard
    clipboard> "GTK4 clipboard λ ✓" assert=
    "GTK4 primary λ" selection get set-clipboard-contents
    selection get clipboard-contents "GTK4 primary λ" assert=
    "Independent GL context" <label> "GTK4 second window" open-window* :> second-world
    second-world wait-for-window
    second-world check-framebuffer
    second-world set-gl-context current-gl-context first-context = f assert=
    second-world close-window
    first-world { 640 360 } resize-window
    500 milliseconds sleep
    first-world draw-world
    close-all-windows ;

: gtk4-smoke-test ( -- )
    [ smoke-error ] ui-error-hook set-global
    [
        "GTK4 rendering and clipboard smoke test" <label>
        "GTK4 smoke test" open-window*
        '[ _ [ exercise-windows ] [ smoke-error ] recover ]
        "GTK4 smoke test" spawn drop
    ] with-ui
    "GTK4 smoke test passed" print ;

MAIN: gtk4-smoke-test
