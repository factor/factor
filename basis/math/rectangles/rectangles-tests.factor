USING: tools.test math.rectangles ;
IN: math.rectangles.tests

[ RECT: { 10 10 } { 20 20 } ]
[
    RECT: { 10 10 } { 50 50 }
    RECT: { -10 -10 } { 40 40 }
    rect-intersect
] unit-test

[ RECT: { 200 200 } { 0 0 } ]
[
    RECT: { 100 100 } { 50 50 }
    RECT: { 200 200 } { 40 40 }
    rect-intersect
] unit-test

[ f ] [
    RECT: { 100 100 } { 50 50 }
    RECT: { 200 200 } { 40 40 }
    contains-rect?
] unit-test

[ t ] [
    RECT: { 100 100 } { 50 50 }
    RECT: { 120 120 } { 40 40 }
    contains-rect?
] unit-test

[ f ] [
    RECT: { 1000 100 } { 50 50 }
    RECT: { 120 120 } { 40 40 }
    contains-rect?
] unit-test

[ RECT: { 10 20 } { 20 20 } ] [
    {
        { 20 20 }
        { 10 40 }
        { 30 30 }
    } rect-containing
] unit-test
