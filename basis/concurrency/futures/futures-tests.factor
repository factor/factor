USING: concurrency.futures kernel tools.test threads ;
IN: concurrency.futures.tests

{ 50 } [
    [ 50 ] future ?future
] unit-test

[
    [ "this should propogate" throw ] future ?future
] must-fail

{ } [
    [ "this should not propogate" throw ] future drop
] unit-test

! Race condition with futures
{ 3 3 } [
    [ 3 ] future
    dup ?future swap ?future
] unit-test

! Another race
{ 3 } [
    [ 3 yield ] future ?future
] unit-test
