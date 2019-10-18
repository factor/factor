USING: gadgets kernel namespaces test ;
[ << rect f { 10 10 0 } { 20 20 0 } >> ]
[
    << rect f { 10 10 0 } { 50 50 0 } >>
    << rect f { -10 -10 0 } { 40 40 0 } >>
    intersect
] unit-test

[ << rect f { 200 200 0 } { 0 0 0 } >> ]
[
    << rect f { 100 100 0 } { 50 50 0 } >>
    << rect f { 200 200 0 } { 40 40 0 } >>
    intersect
] unit-test

[ f ] [
    << rect f { 100 100 0 } { 50 50 0 } >>
    << rect f { 200 200 0 } { 40 40 0 } >>
    intersects?
] unit-test

[ t ] [
    << rect f { 100 100 0 } { 50 50 0 } >>
    << rect f { 120 120 0 } { 40 40 0 } >>
    intersects?
] unit-test

[ f ] [
    << rect f { 1000 100 0 } { 50 50 0 } >>
    << rect f { 120 120 0 } { 40 40 0 } >>
    intersects?
] unit-test
