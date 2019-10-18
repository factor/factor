USING: gadgets kernel namespaces test ;

[ T{ rect f { 10 10 0 } { 20 20 0 } } ]
[
    T{ rect f { 10 10 0 } { 50 50 0 } }
    T{ rect f { -10 -10 0 } { 40 40 0 } }
    rect-intersect
] unit-test

[ T{ rect f { 200 200 0 } { 0 0 0 } } ]
[
    T{ rect f { 100 100 0 } { 50 50 0 } }
    T{ rect f { 200 200 0 } { 40 40 0 } }
    rect-intersect
] unit-test

[ T{ rect f { -10 -10 0 } { 70 70 0 } } ]
[
    T{ rect f { 10 10 0 } { 50 50 0 } }
    T{ rect f { -10 -10 0 } { 40 40 0 } }
    rect-union
] unit-test

[ T{ rect f { 100 100 0 } { 140 140 0 } } ]
[
    T{ rect f { 100 100 0 } { 50 50 0 } }
    T{ rect f { 200 200 0 } { 40 40 0 } }
    rect-union
] unit-test

[ f ] [
    T{ rect f { 100 100 0 } { 50 50 0 } }
    T{ rect f { 200 200 0 } { 40 40 0 } }
    intersects?
] unit-test

[ t ] [
    T{ rect f { 100 100 0 } { 50 50 0 } }
    T{ rect f { 120 120 0 } { 40 40 0 } }
    intersects?
] unit-test

[ f ] [
    T{ rect f { 1000 100 0 } { 50 50 0 } }
    T{ rect f { 120 120 0 } { 40 40 0 } }
    intersects?
] unit-test
