USING: accessors arrays assocs combinators compiler.cfg.linear-scan.allocation.state
compiler.cfg compiler.cfg.instructions compiler.cfg.linear-scan.resolve
compiler.cfg.linear-scan.live-intervals compiler.cfg.linear-scan.numbering
compiler.cfg.metrics compiler.cfg.register-allocation
compiler.cfg.register-allocation.chordal compiler.cfg.registers
compiler.cfg.ssa.destruction.leaders
compiler.cfg.utilities compiler.test cpu.architecture generalizations kernel kernel.private locals make math
math.bitwise math.functions math.libm math.private memory namespaces quotations
sequences sequences.generalizations tools.test ;
IN: compiler.cfg.register-allocation.chordal.tests

CONSTANT: tree-graph H{ { 0 { 1 2 } } { 1 { 0 3 } } { 2 { 0 } } { 3 { 1 } } }
CONSTANT: cycle-graph H{ { 0 { 1 3 } } { 1 { 0 2 } } { 2 { 1 3 } } { 3 { 0 2 } } }

{ t 2 } [
    tree-graph dup maximum-cardinality-order
    [ perfect-order? ] [ greedy-colors values supremum 1 + ] 2bi
] unit-test

{ f } [ cycle-graph dup maximum-cardinality-order perfect-order? ] unit-test

! Compare both optimized graph algorithms to simple independent oracles on
! every undirected graph with four vertices, including non-chordal graphs.
:: scan-cardinality-order ( graph -- order )
    graph keys sort :> remaining!
    H{ } clone :> weights
    V{ } clone :> order
    [ remaining empty? not ] [
        remaining first :> best!
        remaining [| vertex |
            vertex weights at 0 or best weights at 0 or >
            [ vertex best! ] when
        ] each
        best order push
        best remaining remove remaining!
        best graph at [ weights inc-at ] each
    ] while
    order ;

:: oracle-earlier-neighbors ( vertex graph seen -- neighbors )
    vertex graph at [ seen key? ] filter ;

:: oracle-clique? ( vertices graph -- ? )
    vertices [| a |
        vertices [| b | a b = b a graph at member? or ] all?
    ] all? ;

:: clique-perfect-order? ( graph order -- ? )
    H{ } clone :> seen
    order [| vertex |
        vertex graph seen oracle-earlier-neighbors graph oracle-clique?
        vertex seen conjoin
    ] all? ;

:: four-vertex-graph ( mask -- graph )
    4 <iota> [ V{ } clone ] H{ } map>assoc :> graph
    { { 0 1 } { 0 2 } { 0 3 } { 1 2 } { 1 3 } { 2 3 } }
    [| pair index |
        mask 1 index shift bitand 0 > [
            pair first2 graph at push
            pair reverse first2 graph at push
        ] when
    ] each-index
    graph ;

{ t } [
    64 <iota> [ [let
        four-vertex-graph :> graph
        graph maximum-cardinality-order :> order
        graph scan-cardinality-order order =
        graph order perfect-order? graph order clique-perfect-order? = and
    ] ] all?
] unit-test

! Disjoint live-range holes must not become interference via a hull.
{ H{ { 0 V{ } } { 1 V{ } } } } [
    H{ { 0 int-rep } { 1 int-rep } } representations [
        {
            T{ live-interval-state { vreg 0 } { ranges V{ { 0 2 } { 8 10 } } } }
            T{ live-interval-state { vreg 1 } { ranges V{ { 4 6 } } } }
        } interference-graph
    ] with-variable
] unit-test

! A phi affinity can be blocked by a neighbor using the desired color.
! Exchanging the whole two-color component preserves both interference edges.
CONSTANT: exchange-graph H{
    { 0 { 1 } } { 1 { 0 } } { 2 { 3 } } { 3 { 2 } }
}

{ t t 0 } [ [let
    H{ { 0 0 } { 1 1 } { 2 1 } { 3 0 } } clone :> colors
    H{ { 0 { 2 } } { 2 { 0 } } } :> affinities
    exchange-graph { 0 1 2 3 } affinities colors exchange-affinity-colors
    0 colors at 1 colors at = not
    2 colors at 3 colors at = not
    affinities colors affinity-misses
] ] unit-test

! A superficially attractive exchange must account for every affected edge:
! gaining one affinity while losing two has negative benefit.
{ -1 } [
    H{ { 0 t } { 1 t } } 0 1
    H{ { 0 { 2 } } { 1 { 4 4 } } }
    H{ { 0 0 } { 1 1 } { 2 1 } { 4 1 } }
    exchange-benefit
] unit-test

! Recoloring preserves every original edge, including graphs for which the
! chordality certificate fails and affinities that directly conflict.
{ t } [
    64 <iota> [ [let
        four-vertex-graph :> graph
        graph maximum-cardinality-order :> order
        graph order greedy-colors :> colors
        graph keys [| vertex | vertex 4 <iota> [ vertex = not ] filter ]
        H{ } map>assoc :> affinities
        graph order affinities colors improve-affinity-colors
        graph order affinities colors exchange-affinity-colors
        graph >alist [| pair |
            pair second [ colors at pair first colors at = not ] all?
        ] all?
    ] ] all?
] unit-test

! Exact copies may alias even when their original intervals overlap. A
! representation-changing copy must keep its own root/derived-root identity.
{ 0 0 3 } [
    [
        H{ { 0 int-rep } { 1 int-rep } { 2 int-rep } { 3 tagged-rep } }
        representations set
        {
            T{ ##copy { dst 2 } { src 1 } { rep int-rep } }
            T{ ##copy { dst 1 } { src 0 } { rep int-rep } }
            T{ ##copy { dst 3 } { src 0 } { rep tagged-rep } }
        } insns>cfg copy-leaders
        1 leader 2 leader 3 leader
    ] with-scope
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

! A scalar stack copy may borrow a register holding a live vector. Its
! save/restore must preserve the widest representation in that class.
{ { double-2-rep double-rep double-rep double-2-rep } } [
    [
        H{ { 0 double-rep } { 1 double-2-rep } } representations set
        machine-registers registers set
        H{ } clone scratch-spills set
        { } insns>cfg dup stack-frame>> 32 >>spill-area-size drop cfg set
        [
            0 <spill-slot> double-rep <location>
            8 <spill-slot> double-rep <location> memory>memory
        ] { } make [ rep>> ] map
    ] with-scope
] unit-test

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

:: phi-pressure-quotation ( -- quot )
    40 <iota> [ 1 + >float '[ _ float+ ] ] map :> positive
    40 <iota> [ 1 + >float '[ _ float- ] ] map :> negative
    '[ positive cleave ] :> positive-branch
    '[ negative cleave ] :> negative-branch
    39 [ \ float+ ] replicate >quotation :> reduction
    '[ [ { float } declare ] dip
        positive-branch negative-branch if reduction call ] ;

! Forty simultaneous phi results must permit stack destinations. The
! resulting edges also exercise stack-to-stack moves under full pressure.
{ 920.0 -720.0 } [ [
    2.5 t phi-pressure-quotation compile-call
    2.5 f phi-pressure-quotation compile-call
] with-chordal-test ] unit-test

! Allocation diagnostics make the theorem's certificate and the actual
! graph-policy work visible to the comparison harness.
{ t t } [ [
    [ 1.0 100 [ fsin ] times 1.0 float+ ] measure-compilation
    "procedures" of first "allocation" of
    [ "chordal?" of ] [ "color-assignments" of 0 > ] bi
] with-chordal-test ] unit-test
