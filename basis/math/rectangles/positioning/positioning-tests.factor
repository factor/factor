! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test math.rectangles math.rectangles.positioning ;
IN: math.rectangles.positioning.tests

[ T{ rect f { 0 1 } { 30 30 } } ] [
    { 0 0 } { 1 1 } <rect>
    { 30 30 }
    { 100 100 }
    popup-rect
] unit-test

[ T{ rect f { 10 21 } { 30 30 } } ] [
    { 10 20 } { 1 1 } <rect>
    { 30 30 }
    { 100 100 }
    popup-rect
] unit-test

[ T{ rect f { 10 30 } { 30 30 } } ] [
    { 10 20 } { 1 10 } <rect>
    { 30 30 }
    { 100 100 }
    popup-rect
] unit-test

[ T{ rect f { 20 20 } { 80 30 } } ] [
    { 40 10 } { 1 10 } <rect>
    { 80 30 }
    { 100 100 }
    popup-rect
] unit-test

[ T{ rect f { 50 20 } { 50 50 } } ] [
    { 50 70 } { 0 0 } <rect>
    { 50 50 }
    { 100 100 }
    popup-rect
] unit-test

[ T{ rect f { 0 20 } { 50 50 } } ] [
    { -50 70 } { 0 0 } <rect>
    { 50 50 }
    { 100 100 }
    popup-rect
] unit-test

[ T{ rect f { 0 50 } { 50 50 } } ] [
    { 0 50 } { 0 0 } <rect>
    { 50 60 }
    { 100 100 }
    popup-rect
] unit-test