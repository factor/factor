! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
! Run with a GTK4 image and a display: -run=ui.backend.gtk4.smoke-test
USING: accessors calendar continuations debugger io kernel locals namespaces
system threads ui ui.backend ui.backend.gtk4 ui.clipboards
ui.gadgets.labels ui.gadgets.worlds ;
IN: ui.backend.gtk4.smoke-test

: smoke-error ( error -- )
    print-error nl "GTK4 smoke test failed" print flush 1 exit ;

:: exercise-windows ( first-world -- )
    500 milliseconds sleep
    first-world active?>> t assert=
    first-world set-gl-context current-gl-context :> first-context
    first-context f = f assert=
    "GTK4 clipboard λ ✓" >clipboard
    clipboard> "GTK4 clipboard λ ✓" assert=
    "GTK4 primary λ" selection get set-clipboard-contents
    selection get clipboard-contents "GTK4 primary λ" assert=
    "Independent GL context" <label> "GTK4 second window" open-window* :> second-world
    500 milliseconds sleep
    second-world active?>> t assert=
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
