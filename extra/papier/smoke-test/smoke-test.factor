! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays calendar
continuations debugger game.loop game.worlds io kernel locals math
namespaces opengl opengl.capabilities opengl.gl papier sequences
sets system threads ui ui.backend ui.gadgets.worlds ;
IN: papier.smoke-test

: smoke-error ( error -- )
    print-error nl flush 1 exit ;

:: check-papier ( world -- )
    1 seconds sleep
    world active?>> t assert=
    world game-loop>> tick#>> 0 > t assert=
    world set-gl-context
    gl-extensions empty? f assert=
    world draw-world*
    world dim>> first2 :> ( width height )
    width height * 4 * <byte-array> :> pixels
    0 0 width height GL_RGBA GL_UNSIGNED_BYTE pixels glReadPixels
    gl-error
    ! Reject a blank or solid-colored window, even if GL reported no error.
    pixels members length 16 > t assert=
    close-all-windows ;

: papier-smoke-test ( -- )
    [ smoke-error ] ui-error-hook set-global
    [
        papier-game-attributes start-game
        '[ _ [ check-papier ] [ smoke-error ] recover ]
        "Papier smoke test" spawn drop
    ] with-ui
    "Papier smoke test passed" print ;

MAIN: papier-smoke-test
