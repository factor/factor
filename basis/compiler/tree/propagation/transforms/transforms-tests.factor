USING: arrays classes compiler.test continuations kernel
kernel.private layouts math sequences tools.test ;
IN: compiler.tree.propagation.transforms.tests

: unit-remainder ( n -- r ) { integer } declare 1 swap mod ;
: reference-remainder ( a b -- r ) mod ;

{ { 1 1 0 0 1 1 1 1 } } [
    { -100 -2 -1 1 2 100 -100000000000000000000000 100000000000000000000000 }
    [ unit-remainder ] map
] unit-test

{ t } [
    200 <iota> [
        100 - dup zero?
        [ drop t ]
        [ [ unit-remainder ] [ 1 swap reference-remainder ] bi = ] if
    ] map
    [ ] all?
] unit-test

{ 0.25 } [ 1 0.75 [ mod ] compile-call ] unit-test

: result-or-error ( stack quot -- result )
    [ with-datastack ] [ 2nip class-of ] recover ;

{ t } [
    { 0 } [ unit-remainder ] result-or-error
    { 1 0 } [ reference-remainder ] result-or-error =
] unit-test

{ t } [
    0 >bignum 1array [ unit-remainder ] result-or-error
    1 0 >bignum 2array [ reference-remainder ] result-or-error =
] unit-test

{ 1 1 } [
    most-negative-fixnum unit-remainder
    most-positive-fixnum unit-remainder
] unit-test
