USING: accessors byte-arrays cairo cairo.ffi images.normalization
kernel math.rectangles tools.test ;

{ { 10 20 } } [
    { 10 20 } [
        { 0 1 } { 3 4 } <rect> fill-rect
    ] make-bitmap-image dim>>
] unit-test

! Cairo stores ARGB32 in native byte order. Normalization must preserve
! colors and premultiplied alpha on both little- and big-endian machines.
{ B{ 255 0 0 255 } } [
    { 1 1 } [
        dup 1.0 0.0 0.0 1.0 cairo_set_source_rgba
        { 0 0 } { 1 1 } <rect> fill-rect
    ] make-bitmap-image normalize-image bitmap>>
] unit-test

{ B{ 128 0 0 128 } } [
    { 1 1 } [
        dup 1.0 0.0 0.0 0.5 cairo_set_source_rgba
        { 0 0 } { 1 1 } <rect> fill-rect
    ] make-bitmap-image normalize-image bitmap>>
] unit-test
