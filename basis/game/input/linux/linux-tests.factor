USING: accessors arrays combinators destructors game.input game.input.linux kernel
linux.input-events.ffi locals math sequences sequences.generalizations tools.test ;
IN: game.input.linux.tests

:: axis-info ( value min max flat -- info )
    input_absinfo new value >>value min >>minimum max >>maximum flat >>flat ;

{ -1.0 0.0 1.0 1.0 0.0 } [
    0 0 255 15 axis-info normalized-axis
    128 0 255 15 axis-info normalized-axis
    255 0 255 15 axis-info normalized-axis
    999 0 255 15 axis-info normalized-axis
    7 7 7 0 axis-info normalized-axis
] unit-test

! Button positions must stay fixed as buttons are pressed and released.
{ { f 1.0 f } { f f f } } [
    { } { 304 305 308 } { 305 } controller-snapshot buttons>>
    { } { 304 305 308 } { } controller-snapshot buttons>>
] unit-test

{ 0.0 1.0 f 0.5 pov-up-right } [
    [let
        128 0 255 15 axis-info 0 swap 2array
        255 0 255 15 axis-info 1 swap 2array
        50 0 100 0 axis-info 6 swap 2array
        1 -1 1 0 axis-info 16 swap 2array
        -1 -1 1 0 axis-info 17 swap 2array
        5 narray { } { } controller-snapshot
        { [ x>> ] [ y>> ] [ z>> ] [ slider>> ] [ pov>> ] } cleave
    ]
] unit-test

{ f pov-neutral } [
    { } axes>pov
    0 -1 1 0 axis-info 16 swap 2array 1array axes>pov
] unit-test

! Closed controllers are safe to dispose again and read as disconnected.
{ f } [
    linux-controller new dup dispose dup dispose
    M\ linux-game-input-backend read-controller execute
] unit-test
