USING: arrays assocs classes compiler.test compiler.tree.debugger
compiler.tree.propagation.transforms continuations kernel
kernel.private layouts math math.private sequences tools.test words ;
IN: compiler.tree.propagation.transforms.tests

! #786: known right shifts use the intrinsic, including saturated counts.
{ t } [
    [ { fixnum fixnum } declare dup 0 <= [ shift ] [ drop ] if ]
    \ fixnum-shift inlined?
] unit-test

{ f } [
    [ { fixnum fixnum } declare dup 0 <= [ shift ] [ drop ] if ]
    \ fixnum-shift-fast inlined?
] unit-test

! #2141: malformed literal alists must not crash the optimizer itself.
{ f f f f } [
    "phones" at-quot
    { 1 2 3 4 5 } at-quot
    { { 0 0 } { 1 1 } { 2 2 } { 3 3 } { 4 } } at-quot
    { { 0 0 } { 1 1 } { 2 2 } { 3 3 } { } } at-quot
] unit-test

{ t } [
    { { 0 1 } { 1 2 } { 2 3 } { 3 4 } { 4 5 } }
    at-quot >boolean
] unit-test

: malformed-join-phones ( seq -- seq' )
    [ "phone" over at [ "phones" swap [ ] curry change-at ] when* ] map ;

{ t } [ \ malformed-join-phones word-optimized? ] unit-test
{ { } } [ { } malformed-join-phones ] unit-test

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
