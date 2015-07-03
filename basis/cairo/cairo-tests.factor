USING: cairo tools.test math.rectangles accessors ;
IN: cairo.tests

{ { 10 20 } } [
    { 10 20 } [
        { 0 1 } { 3 4 } <rect> fill-rect
    ] make-bitmap-image dim>>
] unit-test
