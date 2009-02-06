USING: tools.test math.rectangles ;
IN: math.rectangles.tests

[ T{ rect f { 10 10 } { 20 20 } } ]
[
    T{ rect f { 10 10 } { 50 50 } }
    T{ rect f { -10 -10 } { 40 40 } }
    rect-intersect
] unit-test

[ T{ rect f { 200 200 } { 0 0 } } ]
[
    T{ rect f { 100 100 } { 50 50 } }
    T{ rect f { 200 200 } { 40 40 } }
    rect-intersect
] unit-test

[ f ] [
    T{ rect f { 100 100 } { 50 50 } }
    T{ rect f { 200 200 } { 40 40 } }
    contains-rect?
] unit-test

[ t ] [
    T{ rect f { 100 100 } { 50 50 } }
    T{ rect f { 120 120 } { 40 40 } }
    contains-rect?
] unit-test

[ f ] [
    T{ rect f { 1000 100 } { 50 50 } }
    T{ rect f { 120 120 } { 40 40 } }
    contains-rect?
] unit-test

[ T{ rect f { 10 20 } { 20 20 } } ] [
    {
        { 20 20 }
        { 10 40 }
        { 30 30 }
    } rect-containing
] unit-test