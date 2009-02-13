! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test math.rectangles math.rectangles.positioning ;
IN: math.rectangles.positioning.tests

[ { 0 1 } ] [
    { 0 0 } { 1 1 } <rect>
    { 30 30 }
    { 100 100 }
    popup-loc
] unit-test

[ { 10 21 } ] [
    { 10 20 } { 1 1 } <rect>
    { 30 30 }
    { 100 100 }
    popup-loc
] unit-test

[ { 10 30 } ] [
    { 10 20 } { 1 10 } <rect>
    { 30 30 }
    { 100 100 }
    popup-loc
] unit-test

[ { 20 20 } ] [
    { 40 10 } { 1 10 } <rect>
    { 80 30 }
    { 100 100 }
    popup-loc
] unit-test

[ { 50 20 } ] [
    { 50 70 } { 0 0 } <rect>
    { 50 50 }
    { 100 100 }
    popup-loc
] unit-test