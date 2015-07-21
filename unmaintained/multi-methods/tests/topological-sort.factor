USING: kernel multi-methods tools.test math arrays sequences
math.order ;
IN: multi-methods.tests

[ { 1 2 3 4 5 6 } ] [
    { 6 4 5 1 3 2 } [ <=> ] topological-sort
] unit-test

[ +lt+ ] [
    { fixnum array } { number sequence } classes<
] unit-test

[ +eq+ ] [
    { number sequence } { number sequence } classes<
] unit-test

[ +gt+ ] [
    { object object } { number sequence } classes<
] unit-test
