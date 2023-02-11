! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test math.rectangles math.rectangles.positioning ;
IN: math.rectangles.positioning.tests

{ T{ rect f { 0 1 } { 30 30 } } } [
    T{ rect f { 0 0 } { 1 1 } }
    { 30 30 }
    { 100 100 }
    popup-rect
] unit-test

{ T{ rect f { 10 21 } { 30 30 } } } [
    T{ rect f { 10 20 } { 1 1 } }
    { 30 30 }
    { 100 100 }
    popup-rect
] unit-test

{ T{ rect f { 10 30 } { 30 30 } } } [
    T{ rect f { 10 20 } { 1 10 } }
    { 30 30 }
    { 100 100 }
    popup-rect
] unit-test

{ T{ rect f { 20 20 } { 80 30 } } } [
    T{ rect f { 40 10 } { 1 10 } }
    { 80 30 }
    { 100 100 }
    popup-rect
] unit-test

{ T{ rect f { 50 20 } { 50 50 } } } [
    T{ rect f { 50 70 } { 0 0 } }
    { 50 50 }
    { 100 100 }
    popup-rect
] unit-test

{ T{ rect f { 0 20 } { 50 50 } } } [
    T{ rect f { -50 70 } { 0 0 } }
    { 50 50 }
    { 100 100 }
    popup-rect
] unit-test

{ T{ rect f { 0 0 } { 50 60 } } } [
    T{ rect f { 0 50 } { 0 0 } }
    { 50 60 }
    { 100 100 }
    popup-rect
] unit-test

{ T{ rect f { 0 90 } { 10 10 } } } [
    T{ rect f { 0 1000 } { 0 0 } }
    { 10 10 }
    { 100 100 }
    popup-rect
] unit-test
