! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Run with a display: -run=terrain.smoke-test
USING: accessors byte-arrays calendar concurrency.promises continuations debugger
game.loop game.worlds grid-meshes io kernel locals math math.vectors.simd namespaces opengl
opengl.gl sequences sets system terrain threads ui ui.backend ui.backend.input-state
ui.gadgets.worlds ;
IN: terrain.smoke-test

SLOT: input-grabbed?

: smoke-error ( error -- )
    print-error nl flush 1 exit ;

:: terrain-frame ( world -- pixels )
    world active?>> t assert=
    world set-gl-context
    world draw-world*
    world dim>> first2 :> ( width height )
    width height * 4 * <byte-array> :> pixels
    0 0 width height GL_RGBA GL_UNSIGNED_BYTE pixels glReadPixels
    gl-error
    ! A successful draw must also produce a nonblank image.
    pixels members length 16 > t assert=
    pixels ;

:: check-terrain-frame ( world -- )
    world terrain-frame :> ground
    world terrain-mesh>> :> mesh
    mesh dim>> :> dim
    [
        mesh { 512 0 } >>dim drop
        world terrain-frame ground = f assert=
    ] [ mesh dim >>dim drop ] finally ;

:: check-cocoa-controls ( world -- )
    clear-input-state
    world player>> :> player
    player float-4{ 0.0 0.0 0.0 1.0 } >>velocity drop
    13 t record-key
    world handle-input
    player velocity>> third 0.0 < t assert=
    13 f record-key
    world handle-input
    terrain-keys [ not ] all? t assert=
    56 t record-key
    world handle-input
    player velocity-modifier>> VELOCITY-MODIFIER-FAST assert=
    56 f record-key
    player pitch>> :> pitch
    current-input-state get-global { 10 10 } >>motion drop
    world handle-input
    player pitch>> pitch > t assert=
    current-input-state get-global motion>> { 0 0 } assert=
    clear-input-state ;

:: check-terrain ( world -- )
    1 seconds sleep
    world raise-window
    100 milliseconds sleep
    world handle>> :> handle
    os macos? [
        handle input-grabbed?>> t assert=
        handle (grab-input)
        handle (ungrab-input)
        handle (ungrab-input)
        handle input-grabbed?>> f assert=
        handle (grab-input)
        handle (grab-input)
    ] when
    world game-loop>> tick#>> 0 > t assert=
    world game-loop>> stop-loop
    world player>> 45.0 >>pitch drop
    os macos? [ world check-cocoa-controls ] when
    world check-terrain-frame
    world { 640 360 } resize-window
    500 milliseconds sleep
    world check-terrain-frame
    world close-window
    world promise>> ?promise drop
    os macos? [ handle input-grabbed?>> f assert= ] when
    world terrain-mesh>> [ buffer>> ] [ vertex-array>> ] bi [ f assert= ] bi@
    "Terrain smoke test passed (ground, sky, resize, controls, capture, cleanup)" print flush
    0 exit ;

: terrain-smoke-test ( -- )
    [ smoke-error ] ui-error-hook set-global
    [
        terrain-game-attributes start-game
        '[ _ [ check-terrain ] [ smoke-error ] recover ]
        "Terrain smoke test" spawn drop
    ] with-ui ;

MAIN: terrain-smoke-test
