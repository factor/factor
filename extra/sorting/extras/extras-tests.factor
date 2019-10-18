USING: kernel math.order sequences tools.test ;
IN: sorting.extras

{ { 0 2 1 } } [ { 10 30 20 } [ <=> ] argsort ] unit-test
{ { 2 0 1 } } [
    { "hello" "goodbye" "yo" } [ [ length ] bi@ <=> ] argsort
] unit-test
