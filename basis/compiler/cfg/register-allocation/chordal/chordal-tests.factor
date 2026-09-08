USING: accessors arrays assocs combinators compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals compiler.cfg.linear-scan.numbering
compiler.cfg.metrics compiler.cfg.register-allocation
compiler.cfg.register-allocation.chordal compiler.cfg.registers
compiler.test cpu.architecture generalizations kernel locals math
math.functions math.libm math.private memory namespaces sequences sequences.generalizations tools.test ;
IN: compiler.cfg.register-allocation.chordal.tests

CONSTANT: tree-graph H{ { 0 { 1 2 } } { 1 { 0 3 } } { 2 { 0 } } { 3 { 1 } } }
CONSTANT: cycle-graph H{ { 0 { 1 3 } } { 1 { 0 2 } } { 2 { 1 3 } } { 3 { 0 2 } } }

{ t 2 } [
    tree-graph dup maximum-cardinality-order
    [ perfect-order? ] [ greedy-colors values supremum 1 + ] 2bi
] unit-test

{ f } [ cycle-graph dup maximum-cardinality-order perfect-order? ] unit-test

! Disjoint live-range holes must not become interference via a hull.
{ H{ { 0 V{ } } { 1 V{ } } } } [
    H{ { 0 int-rep } { 1 int-rep } } representations [
        {
            T{ live-interval-state { vreg 0 } { ranges V{ { 0 2 } { 8 10 } } } }
            T{ live-interval-state { vreg 1 } { ranges V{ { 4 6 } } } }
        } interference-graph
    ] with-variable
] unit-test

: with-chordal-test ( quot -- )
    [
        t check-allocation? set
        t check-numbering? set
        chordal-allocator register-allocator set
        call
    ] with-scope ; inline

! Executed optimized machine code: branch joins and cyclic phi copies.
{ 13 6 } [ [
    5 [ dup 0 > [ 2 * ] [ 3 + ] if 3 + ] compile-call
    0 [ dup 0 > [ 2 * ] [ 3 + ] if 3 + ] compile-call
] with-chordal-test ] unit-test

{ 55 } [ [
    10 [ 0 swap [ dup 0 > ] [ [ + ] keep 1 - ] while drop ] compile-call
] with-chordal-test ] unit-test

{ 2 1 } [ [ [ 1 2 5 [ swap ] times ] compile-call ] with-chordal-test ] unit-test

! Tagged roots remain valid across collection.
{ { 1 2 3 } } [ [ [ 1 2 3 3array gc ] compile-call ] with-chordal-test ] unit-test

! FFI argument-only fragments before their phi definition in layout need
! spill slots even when the sync point removes their sole local use.
{ t } [ [
    [ 1.0 100 [ fsin ] times 1.0 float+ ] compile-call
    1.168852488727981 1.e-9 ~
] with-chordal-test ] unit-test

{ 65537.0 } [ [
    [ 2.0 4 [ 2.0 fpow ] times 1.0 float+ ] compile-call
] with-chordal-test ] unit-test

:: pressure-quotation ( -- quot )
    40 <iota> [ '[ _ swap nth >float 0.5 float+ ] ] map :> loads
    '[ loads cleave 40 narray ] ;

{ t } [ [
    40 <iota> >array pressure-quotation compile-call
    40 <iota> [ >float 0.5 float+ ] map =
] with-chordal-test ] unit-test

{ t t } [ [
    pressure-quotation measure-compilation "procedures" of first
    [ "allocation" of "repair-assignments" of 0 > ]
    [ "passes" of last "spills" of 0 > ] bi
] with-chordal-test ] unit-test

! Allocation diagnostics make the theorem's certificate and the actual
! graph-policy work visible to the comparison harness.
{ t t } [ [
    [ 1.0 100 [ fsin ] times 1.0 float+ ] measure-compilation
    "procedures" of first "allocation" of
    [ "chordal?" of ] [ "color-assignments" of 0 > ] bi
] with-chordal-test ] unit-test
