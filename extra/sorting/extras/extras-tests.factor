USING: kernel math math.order sequences tools.test ;
IN: sorting.extras

{ { 0 2 1 } } [ { 10 30 20 } [ <=> ] argsort ] unit-test
{ { 2 0 1 } } [
    { "hello" "goodbye" "yo" } [ [ length ] bi@ <=> ] argsort
] unit-test

{ { "blue" "green" "purple" } } [
    { "green" "blue" "purple" } [ length ] map-sort
] unit-test
{ 1 { 1 2 3 4 } } [ 1 { 4 2 1 3 } [ dupd + ] map-sort ] unit-test
