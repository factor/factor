USING: kernel multi-methods tools.test math arrays sequences
math.order ;
IN: multi-methods.tests

[ { 1 2 3 4 5 6 } ] [
    { 6 4 5 1 3 2 } [ <=> ] topological-sort
] unit-test

[ -1 ] [
    { fixnum array } { number sequence } classes<
] unit-test

[ 0 ] [
    { number sequence } { number sequence } classes<
] unit-test

[ 1 ] [
    { object object } { number sequence } classes<
] unit-test
