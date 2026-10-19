USING: accessors arrays continuations kernel locals math namespaces opengl
sequences tools.test ui.gadgets ui.gadgets.frame-buffer ;
IN: ui.gadgets.frame-buffer.tests

! Growing a row must leave its new columns clear, without spilling the next row.
{ { 1 2 3 4 5 6 7 8 0 0 0 0 9 10 11 12 13 14 15 16 0 0 0 0 } } [
    24 0 <array>
    [ { 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 } 2 rot 3 copy-pixels ] keep
] unit-test

! Shrinking crops each row independently and also handles a shorter buffer.
{ { 1 2 3 4 5 6 7 8 13 14 15 16 17 18 19 20 } } [
    16 0 <array>
    [ 36 <iota> [ 1 + ] map 3 rot 2 copy-pixels ] keep
] unit-test

{ { 0 0 0 0 } } [
    4 0 <array> [ { } 0 rot 1 copy-pixels ] keep
] unit-test

{ } [ { 1 2 3 4 } 1 { } 0 copy-pixels ] unit-test

:: check-device-resize ( -- )
    gl-scale-factor get-global :> original-scale
    [
        f gl-scale-factor set-global
        <frame-buffer> { 3 2 } >>dim :> buffer
        buffer layout*
        buffer pixels>> [ nip 1 + ] map-index buffer pixels<<
        buffer pixels>> :> original-pixels
        buffer resize-frame-buffer
        buffer pixels>> original-pixels eq? t assert=
        2.0 gl-scale-factor set-global
        buffer layout*
        buffer pixel-dim>> { 6 4 } assert=
        buffer pixels>> length 96 assert=
        buffer pixels>> 48 head >array {
            1 2 3 4 5 6 7 8 9 10 11 12 0 0 0 0 0 0 0 0 0 0 0 0
            13 14 15 16 17 18 19 20 21 22 23 24 0 0 0 0 0 0 0 0 0 0 0 0
        } assert=
        f gl-scale-factor set-global
        buffer resize-frame-buffer
        buffer pixels>> >array 24 <iota> [ 1 + ] map assert=
        1.5 gl-scale-factor set-global
        buffer { 3.5 2.5 } >>dim layout*
        buffer pixel-dim>> { 5 3 } assert=
        buffer pixels>> length 60 assert=
    ] [ original-scale gl-scale-factor set-global ] finally ;

{ } [ check-device-resize ] unit-test
