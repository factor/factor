USING: accessors concurrency.futures continuations kernel namespaces
sequences tools.test threads ;
IN: concurrency.futures.tests

SYMBOL: future-scope

! #3156: the inherited scope survives after the parent's binding ends.
{ 42 } [
    42 future-scope [ [ future-scope get ] future ] with-variable ?future
] unit-test

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

! Publishing a result must let its worker stop before starting the next
! future. Otherwise a batch retains one set of native stacks per result.
{ f } [
    128 [ [ self ] future ] replicate
    [ ?future ] map [ thread-registered? ] any?
] unit-test

{ f } [
    128 [ [ self throw ] future ] replicate
    [ [ ?future ] [ nip error>> ] recover ] map
    [ thread-registered? ] any?
] unit-test
