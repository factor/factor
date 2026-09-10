! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors continuations destructors fonts images kernel
locals math math.rectangles namespaces opengl sequences strings tools.test
ui.render ui.text ui.text.pango ui.text.pango.indexed ui.text.pango.private ;
IN: ui.text.pango.tests

:: with-text-scale ( scale quot -- )
    gl-scale-factor get-global :> previous
    [ scale gl-scale-factor set-global quot call ]
    [ previous gl-scale-factor set-global ] finally ; inline

: test-layout ( -- layout )
    layout new
        { 0 0 } { 100000 30 } <rect> >>ink-rect
        { 0 0 } { 100000 30 } <rect> >>logical-rect ;

{ { { 19968 0 } { 20480 0 } { 20992 0 } } } [
    f [ test-layout { 20000 0 } { 1100 30 } <rect> pango-tile-offsets ] with-text-scale
] unit-test

! A selection has its own disposable registration and native reference.
{ t } [
    [let
        monospace-font "selection ownership" cached-layout :> plain
        monospace-font "selection ownership" 0 4 COLOR: blue <selection> <layout>
        dispose
        plain { 0 0 } { 32 8 } draw-layout-region bitmap>> empty? not
    ]
] unit-test

! Selection changes reuse shaping and the glyph index, including native
! font ownership, rather than building another copy of the large layout.
{ t t } [
    [let
        monospace-font :> font
        10000 CHAR: a <string> :> text
        font text cached-layout :> plain
        font text 9000 9010 COLOR: blue <selection> cached-layout :> selected
        plain layout>> selected layout>> =
        plain glyph-index>> selected glyph-index>> eq?
    ]
] unit-test

! Variable advances and ligatures must match Pango's complete native line.
{ t } [
    [let
        sans-serif-font :> font
        600 [ "AVATAR office ffi fi fl " ] replicate concat :> text
        font text cached-layout :> indexed
        indexed clone f >>glyph-index :> native
        { 0 1000 7000 } [| x |
            indexed x 0 2array { 512 20 } draw-layout-region bitmap>>
            native x 0 2array { 512 20 } draw-layout-region bitmap>> =
        ] all?
    ]
] unit-test

{ { { 19968 0 } { 20480 0 } { 20992 0 } } } [
    2.0 [ test-layout { 10000 0 } { 550 15 } <rect> pango-tile-offsets ] with-text-scale
] unit-test

{ { } } [
    f [ test-layout { 0 40 } { 1100 30 } <rect> pango-tile-offsets ] with-text-scale
] unit-test

{ { 20000.0 20.0 } { 1000.0 100.0 } } [
    { 0 0 } { 1000 100 } <rect>
    -20000 -20 make-translation-matrix pango-modelview-clip rect-bounds
] unit-test

{ f } [
    { 0 0 } { 100 20 } <rect>
    { 1 0.5 0 0 0 1 0 0 0 0 1 0 0 0 0 1 } pango-modelview-clip
] unit-test

! Compare a far-away region with the same glyphs near the beginning. This
! exceeds both the former 16384-pixel clamp and Cairo's surface-size limit.
{ t } [
    f [ [let
        monospace-font 20000 CHAR: X <string> cached-layout :> line
        10000 monospace-font line string>> offset>x :> x
        line { 0 0 } { 64 8 } draw-layout-region bitmap>>
        line x 0 2array { 64 8 } draw-layout-region bitmap>> =
    ] ] with-text-scale
] unit-test

! Hit testing must still use the full shaped line, not a tile-local index.
{ 19000 } [
    f [ [let
        20000 CHAR: X <string> :> text
        19000 monospace-font text offset>x monospace-font text x>offset
    ] ] with-text-scale
] unit-test

! Selected pixels beyond the old cutoff must be present in the region.
{ t } [
    f [ [let
        20000 CHAR: X <string> :> text
        monospace-font text 10000 10020 COLOR: blue <selection> cached-layout :> selected
        10000 monospace-font text offset>x 0 2array :> offset
        selected offset { 64 8 } draw-layout-region bitmap>>
        monospace-font text cached-layout offset { 64 8 } draw-layout-region bitmap>> = not
    ] ] with-text-scale
] unit-test

! Dragging a selection backwards must paint the same clipped background.
{ t } [
    f [ [let
        20000 CHAR: X <string> :> text
        monospace-font text 10000 10020 COLOR: blue <selection> cached-layout :> forward
        monospace-font text 10020 10000 COLOR: blue <selection> cached-layout :> backward
        10000 monospace-font text offset>x 0 2array :> offset
        forward offset { 64 8 } draw-layout-region bitmap>>
        backward offset { 64 8 } draw-layout-region bitmap>> =
    ] ] with-text-scale
] unit-test
