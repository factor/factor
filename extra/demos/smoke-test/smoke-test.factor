! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Requires a display. Run with -run=demos.smoke-test [vocab ...].
USING: accessors arrays assocs byte-arrays calendar command-line
combinators compiler.errors concurrency.promises continuations debugger demos game.input
 game.loop game.worlds gpu.demos.bunny gpu.util.wasd grouping io
io.streams.string kernel literals locals math models namespaces opengl
opengl.gl sequences sets sorting system terrain terrain.smoke-test threads timers circular tools.errors
ui ui.backend ui.backend.input-state ui.gadgets ui.gadgets.books
ui.gadgets.labels ui.gadgets.worlds ui.private ui.theme ui.theme.switching ui-demo vocabs vocabs.loader words ;
QUALIFIED: bunny
QUALIFIED: trails
IN: demos.smoke-test

CONSTANT: graphical-demos {
    "boids" "bubble-chamber" "bunny" "color-picker"
    "color-picker-game" "color-table" "game-of-life"
    "game.input.demos.key-caps" "gesture-logger" "golden-section"
    "gpu.demos.bunny" "gpu.demos.raytrace" "hello-ui" "hello-unicode"
    "jamshred" "lcd" "maze" "minesweeper" "nehe" "papier"
    "periodic-table" "pong" "snake-game" "spheres" "terrain" "tetris"
    "trails" "ui-demo" "ui.gadgets.charts.demos" "window-controls-demo"
}

CONSTANT: console-demos H{
    { "24-game" "q\n" } { "contributors" "" }
    { "hello-world" "" } { "numbers-game" "bad\n50\n" }
    { "quiz" "a\na\na\na\na\n" } { "rot13" "Hello, Factor!\n" }
    { "rpn" "1 2 +\n" } { "sudoku" "" }
}

! These entries need external resources or do not open Factor UI windows.
! Keep them explicit so adding a demo cannot silently omit it from the audit.
CONSTANT: external-demos H{
    { "game.input.demos.joysticks" "physical joystick/controller required" }
    { "raylib.demo" "raylib native library required" }
    { "raylib.demo.gui" "raylib and raygui native libraries required" }
    { "raylib.demo.mesh-picking" "raylib native library required" }
    { "roms.balloon-bomber" "user-supplied arcade ROM files required" }
    { "roms.lunar-rescue" "user-supplied arcade ROM files required" }
    { "roms.space-invaders" "user-supplied arcade ROM files required" }
    { "tty-server" "interactive network listener; checked by loading" }
    { "tty-server.shared" "interactive network listener; checked by loading" }
}

CONSTANT: blank-window-titles {
    "Gesture log" "Gesture input" "No controls" "Normal title bar" "Small title bar"
    "Close button" "Close and minimize buttons" "Minimize button"
    "Close, minimize, and maximize buttons" "Resizable"
    "Textured background"
}

: check-demo-coverage ( -- )
    graphical-demos console-demos keys append external-demos keys append
    sort demo-vocabs sort assert= ;

: smoke-error ( error -- ) print-error nl flush 1 exit ;

! Libraries unrelated to a demo may already have optional linkage errors.
! Fail on errors introduced while loading or running this demo.
: demo-errors ( -- seq )
    compiler-errors get-global values
    linkage-errors get-global values append ;

: demo-error-assets ( -- seq ) demo-errors [ asset>> ] map ;

:: check-demo-errors ( baseline -- )
    demo-errors [ asset>> baseline member-eq? not ] filter
    dup empty? [ drop ] [ errors. "Demo compilation or linkage failed" throw ] if ;

: open-worlds ( -- seq ) worlds get-global values ;

:: demo-frame ( window -- pixels )
    window active?>> t assert=
    window set-gl-context
    window draw-world*
    window dim>> [ gl-scale >fixnum ] map first2 :> ( width height )
    width 0 > height 0 > and t assert=
    width height * 4 * <byte-array> :> pixels
    0 0 width height GL_RGBA GL_UNSIGNED_BYTE pixels glReadPixels
    gl-error
    window title>> blank-window-titles member? [
        pixels 4 <groups> dup first '[ _ = ] all? f assert=
    ] unless
    pixels ;

:: check-native-wasd ( window -- )
    clear-input-state
    window location>> clone :> before
    13 t record-key
    window wasd-keyboard-input
    window location>> before = f assert=
    13 f record-key
    window yaw>> :> yaw
    current-input-state get-global { 12 -5 } >>motion drop
    window wasd-mouse-input
    window yaw>> yaw = f assert=
    reset-mouse
    read-mouse [ dx>> 0 assert= ] [ dy>> 0 assert= ] bi
    clear-input-state ;

:: wait-for-bunny ( window -- )
    300 [
        drop
        window bunny>> bunny-loaded? [ window bunny>> bunny-state-filled? ] [ f ] if
        [ t ] [ 100 milliseconds sleep f ] if
    ] find-integer [ drop ] [ "Bunny model did not finish loading" throw ] if* ;

:: check-demo-window ( window -- )
    window raise-window
    200 milliseconds sleep
    os macos? window grab-input?>> and [
        window handle>> input-grabbed?>> t assert=
    ] when
    window game-world? [
        window game-loop>> tick#>> 0 > t assert=
        window game-loop>> stop-loop
    ] when
    os macos? [
        window wasd-world? [ window check-native-wasd ] when
        window terrain-world? [ window check-cocoa-controls ] when
    ] when
    window children>> ?first dup trails:trails-gadget? [
        dup timer>> stop-timer
        points>> { 200 200 } swap circular-push
    ] [ drop ] if
    window bunny:bunny-world? [
        window draw-seq>> length [| n |
            window n >>draw-n demo-frame drop
        ] each-integer
    ] when
    window demo-frame drop
    window { 640 400 } resize-window
    300 milliseconds sleep
    window demo-frame drop ;

:: check-ui-quotation ( name quot -- )
    name print flush
    demo-error-assets :> baseline-errors
    open-worlds :> baseline
    quot call( -- )
    baseline-errors check-demo-errors
    500 milliseconds sleep
    open-worlds [ baseline member-eq? not ] filter :> windows
    windows [ handle>> ] map :> handles
    windows empty? f assert=
    windows [| window |
        window gpu.demos.bunny:bunny-world? [ window wait-for-bunny ] when
        window check-demo-window
        ! Draw an existing core-profile window between compatibility draws.
        baseline [ demo-frame drop ] each
        window demo-frame drop
    ] each
    windows [| window |
        window close-window
        window promise>> ?promise drop
        window handle>> f assert=
    ] each
    os macos? [ handles [ input-grabbed?>> f assert= ] each ] when
    baseline-errors check-demo-errors
    name "PASS: " prepend print flush ;

: check-ui-demo ( name -- ) dup '[ _ run ] check-ui-quotation ;

:: check-ui-pages ( -- )
    ui-demo:sections [| section |
        section first "UI Demo: " prepend
        [ section second call( -- gadget ) "UI Demo section" open-window ]
        check-ui-quotation
    ] each ;

: check-submenus ( -- )
    { "nehe.2" "nehe.3" "nehe.4" "nehe.5" }
    [ check-ui-demo ] each
    "bubble-chamber" require
    {
        "original" "small" "medium" "large" "hadron-chamber"
        "quark-chamber" "muon-chamber" "ten-hadrons"
        "original-big-bang" "original-big-bang-variant"
    } [
        dup "Bubble Chamber: " prepend swap
        '[ _ "bubble-chamber" lookup-word execute( -- ) ] check-ui-quotation
    ] each
    ! Render controller indicators without requiring a connected controller.
    "Joystick indicators" [ "game.input.demos.joysticks" require
        "<axis-gadget>" "game.input.demos.joysticks" lookup-word
        execute( -- gadget ) "Joystick indicators" open-window ]
    check-ui-quotation
    "OpenGL triangle" [ "opengl.demos.gl4" require
        "gl4demo" "opengl.demos.gl4" lookup-word execute( -- ) ]
    check-ui-quotation ;

:: check-console-demo ( name input -- )
    demo-error-assets :> baseline-errors
    [ input [ name run ] with-string-reader ] with-string-writer drop
    baseline-errors check-demo-errors
    name "PASS: " prepend print flush ;

: check-external-demos ( -- )
    external-demos [| name reason |
        name require
        name "LOADED (runtime untested): " prepend print
        reason print flush
    ] assoc-each ;

! Construct fresh windows after switching, so styles and fonts agree.
: check-graphical-demos ( names -- )
    dup empty? [
        drop graphical-demos [ check-ui-demo ] each
        check-ui-pages check-submenus
    ] [ [ check-ui-demo ] each ] if ;

:: check-themed-demos ( names -- )
    { light-theme dark-theme } [| selected-theme |
        close-all-windows
        selected-theme switch-theme
        selected-theme name>> print flush
        "Checking theme..." <label> "Demo smoke tests" open-window
        names check-graphical-demos
    ] each ;

: check-demos ( -- )
    command-line get dup "--themes" swap member? [
        "--themes" swap remove dup check-themed-demos
    ] [ dup check-graphical-demos ] if
    empty? [
        console-demos [ check-console-demo ] assoc-each
        check-external-demos
    ] when
    close-all-windows
    "Demo smoke tests passed" print flush 0 exit ;

: demo-smoke-test ( -- )
    check-demo-coverage
    [ smoke-error ] ui-error-hook set-global
    [
        "Checking demos..." <label> "Demo smoke tests" open-window
        [ [ check-demos ] [ smoke-error ] recover ] "Demo smoke tests" spawn drop
    ] with-ui ;

MAIN: demo-smoke-test
