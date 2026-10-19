! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Requires a display. Run with -run=ui.gadgets.worlds.smoke-test [--legacy].
USING: accessors alien.c-types alien.data arrays calendar colors
command-line continuations debugger io kernel locals math
math.vectors namespaces opengl opengl.gl sequences
specialized-arrays system threads ui ui.backend ui.gadgets
ui.gadgets.worlds ui.pixel-formats ui.render ;
SPECIALIZED-ARRAY: uchar
IN: ui.gadgets.worlds.smoke-test

SYMBOL: painted-dims

TUPLE: resize-marker < gadget ;

M: resize-marker pref-dim* drop { 128 96 } ;

:: check-pixels ( window -- )
    window dim>> [ gl-scale >fixnum ] map first2 :> ( width height )
    { 13 11 } [ gl-scale >fixnum ] map first2 :> ( marker-width marker-height )
    width height * 4 * uchar <c-array> :> pixels
    0 0 width height GL_RGBA GL_UNSIGNED_BYTE pixels glReadPixels
    gl-error
    width height * <iota> [| i |
        i width /mod :> ( y x )
        x width marker-width - >= y marker-height < and
        [ { 255 0 0 255 } ] [ { 0 0 255 255 } ] if
        i 4 * dup 4 + pixels subseq >array assert=
    ] each ;

M: resize-marker draw-gadget*
    ! Check every frame, including native paint immediately after resize.
    dup dim>> over parent>> dim>> [ [ >float ] map ] bi@ assert=
    dup dim>> { 13 11 } v- { 13 11 }
    COLOR: red gl-color gl-fill-rect
    find-world [ dup check-pixels dim>> painted-dims get-global push ] when* ;

:: check-resizes ( window -- )
    { { 256 192 } { 480 320 } { 320 240 } { 400 280 } } [| dim |
        window dim>> :> previous
        painted-dims get-global delete-all
        window dim resize-window
        nano-count 10,000,000,000 + :> deadline
        [
            painted-dims get-global [ previous = not ] any? not
            nano-count deadline < and
        ] [ 20 milliseconds sleep ] while
        painted-dims get-global [ previous = not ] any? t assert=
        painted-dims get-global last window dim>> assert=
    ] each ;

: smoke-error ( error -- ) print-error nl flush 1 exit ;

:: worlds-smoke-test ( -- )
    [ smoke-error ] ui-error-hook set-global
    V{ } clone painted-dims set-global
    command-line get "--legacy" swap member? :> legacy?
    [
        resize-marker new <world-attributes> "Window resize regression" >>title
        legacy? [
            { windowed double-buffered legacy-context } >>pixel-format-attributes
        ] when
        open-window* :> window
        window COLOR: blue >>background-color drop
        [
            [
                250 milliseconds sleep
                window check-resizes
                "World resize smoke test passed" print flush
                close-all-windows 0 exit
            ] [ smoke-error ] recover
        ] "World resize smoke test" spawn drop
    ] with-ui ;

MAIN: worlds-smoke-test
