USING: gadgets kernel namespaces test ;

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
    intersects?
] unit-test

[ t ] [
    T{ rect f { 100 100 } { 50 50 } }
    T{ rect f { 120 120 } { 40 40 } }
    intersects?
] unit-test

[ f ] [
    T{ rect f { 1000 100 } { 50 50 } }
    T{ rect f { 120 120 } { 40 40 } }
    intersects?
] unit-test
