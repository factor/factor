! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
! Run with a GTK4 image and a display: -run=ui.backend.gtk4.smoke-test
USING: accessors alien.c-types alien.data arrays calendar combinators continuations debugger
gtk4.ffi io kernel locals math namespaces opengl opengl.gl sequences system threads
ui ui.backend ui.backend.gtk4 ui.clipboards
ui.gadgets.labels ui.gadgets.worlds ;
IN: ui.backend.gtk4.smoke-test

: smoke-error ( error -- )
    print-error nl "GTK4 smoke test failed" print flush 1 exit ;

ERROR: gtk4-window-not-ready title active? dim native-dim ;
ERROR: gtk4-smoke-check-failed check actual expected ;

:: smoke-assert ( actual expected check -- )
    actual expected = [ check actual expected gtk4-smoke-check-failed ] unless ;

: native-dim ( world -- dim )
    handle>> [
        drawable>> [ gtk_widget_get_width ] [ gtk_widget_get_height ] bi 2array
    ] [ { 0 0 } ] if* ;

: window-ready? ( world -- ? )
    ! Factor's preferred dimensions can be positive before GTK allocates the
    ! GLArea. select-gl-context cannot attach its framebuffer until then.
    ! open-window* queues grafting; the native handle may not exist yet.
    dup draw-world? [
        [ handle>> drawable>> gtk_widget_get_mapped ]
        [ native-dim [ 0 > ] all? ] bi and
    ] [ drop f ] if ;

:: wait-for-window ( world -- )
    nano-count 10,000,000,000 + :> deadline
    [ world window-ready? not nano-count deadline < and ] [
        20 milliseconds sleep
    ] while
    world window-ready? [
        world { [ title>> ] [ active?>> ] [ dim>> ] [ native-dim ] } cleave
        gtk4-window-not-ready
    ] unless ;

:: check-framebuffer ( world -- )
    world set-gl-context
    world handle>> window-framebuffer :> framebuffer
    framebuffer 0 > t "GLArea has a nonzero framebuffer" smoke-assert
    GL_DRAW_FRAMEBUFFER_BINDING { int } [ glGetIntegerv ] with-out-parameters
    framebuffer "GLArea framebuffer is bound" smoke-assert
    GL_FRAMEBUFFER glCheckFramebufferStatus GL_FRAMEBUFFER_COMPLETE
    "GLArea framebuffer is complete" smoke-assert
    gl-error ;

:: exercise-windows ( first-world -- )
    first-world wait-for-window
    first-world check-framebuffer
    first-world set-gl-context current-gl-context :> first-context
    first-context f = f "first window has a GL context" smoke-assert
    "GTK4 clipboard λ ✓" >clipboard
    clipboard> "GTK4 clipboard λ ✓" "clipboard round trip" smoke-assert
    "GTK4 primary λ" selection get set-clipboard-contents
    selection get clipboard-contents "GTK4 primary λ" "primary selection round trip" smoke-assert
    "Independent GL context" <label> "GTK4 second window" open-window* :> second-world
    second-world wait-for-window
    second-world check-framebuffer
    second-world set-gl-context current-gl-context first-context = f
    "windows have independent GL contexts" smoke-assert
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
