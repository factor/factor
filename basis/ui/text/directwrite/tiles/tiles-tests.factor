USING: accessors arrays continuations kernel locals math.rectangles namespaces opengl
tools.test ui.render ui.text.directwrite.tiles windows.directwrite ;
IN: ui.text.directwrite.tiles.tests

: test-layout ( -- layout )
    directwrite-layout new { 66000 20 } >>size { 0 0 } >>origin ;

:: with-test-scale ( ..a scale quot: ( ..a -- ..b ) -- ..b )
    gl-scale-factor get-global :> previous
    [ scale gl-scale-factor set-global quot call ]
    [ previous gl-scale-factor set-global ] finally ; inline

! A viewport deep into a long line should only request the intersecting tile.
{ { { 512 0 } } } [
    1 [
        test-layout { 600 0 } { 100 20 } <rect> directwrite-tile-offsets
    ] with-test-scale
] unit-test

! The legacy UI stores its projection in MODELVIEW. Convert the clip to NDC
! before inversion, so a scrolled line does not disappear or request all tiles.
{ { { 0 0 } { 256 0 } { 512 0 } } } [
    1 [
        test-layout
        { 0 0 } { 628 468 } <rect> { 640 480 } directwrite-viewport-clip
        640 480 make-2d-ortho directwrite-modelview-clip
        directwrite-tile-offsets
    ] with-test-scale
] unit-test

{ { } } [
    test-layout { -500 -500 } { 100 100 } <rect> directwrite-tile-offsets
] unit-test

{ { { 1280 0 } { 1536 0 } { 1792 0 } } } [
    1.5 [
        test-layout { 1000 0 } { 200 20 } <rect> directwrite-tile-offsets
    ] with-test-scale
] unit-test

! Clip inversion includes editor translations and mirrored/scaled text.
{ { 10000 0 } { 800 100 } } [
    { 0 0 } { 800 100 } <rect>
    { 1 0 0 0 0 1 0 0 0 0 1 0 -10000 0 0 1 }
    directwrite-modelview-clip [ loc>> ] [ dim>> ] bi
] unit-test

{ { 50 0 } { 50 100 } } [
    { 0 0 } { 100 100 } <rect>
    { -2 0 0 0 0 1 0 0 0 0 1 0 200 0 0 1 }
    directwrite-modelview-clip [ loc>> ] [ dim>> ] bi
] unit-test

! Rotation cannot be culled using an axis-aligned scale/translation inverse.
{ f } [
    { 0 0 } { 100 100 } <rect>
    { 0 1 0 0 -1 0 0 0 0 0 1 0 0 0 0 1 }
    directwrite-modelview-clip
] unit-test
