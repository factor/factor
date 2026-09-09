USING: accessors arrays assocs compiler.cfg compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.linearization
compiler.cfg.loop-detection compiler.cfg.optimizer compiler.cfg.registers
compiler.cfg.representations compiler.cfg.representations.coalescing
compiler.cfg.representations.selection compiler.cfg.utilities compiler.test
cpu.architecture disjoint-sets kernel kernel.private locals make math math.libm
math.private memory namespaces quotations sequences sequences.generalizations
sets tools.test ;
FROM: namespaces => set ;
IN: compiler.cfg.representations.selection.tests

{ t t f } [
    T{ ##load-integer } peephole-optimizable?
    T{ ##shr-imm } peephole-optimizable?
    T{ ##call } peephole-optimizable?
] unit-test

:: repeated-use-cost ( enabled? -- n )
    [
        enabled? conversion-aware-representation-costs? set
        {
            T{ ##load-double { dst 0 } { val 1.0 } }
            T{ ##replace { src 0 } { loc D: 0 } }
            T{ ##replace { src 0 } { loc D: 1 } }
            T{ ##replace { src 0 } { loc D: 2 } }
            T{ ##replace { src 0 } { loc D: 3 } }
            T{ ##branch }
        } insns>cfg dup cfg set
        { needs-loops compute-components compute-possibilities compute-costs }
        apply-passes
        0 vreg>scc costs get at double-rep swap at
    ] with-scope ;

! Four uses share the same actual double-to-tagged conversion in rewrite.
{ 20 5 } [ f repeated-use-cost t repeated-use-cost ] unit-test

! Cache keys must retain original value identity even within a component;
! each block starts a new cache. These are costs of emitted conversions,
! not a claim that two phi inputs carry the same bits.
{ 10 15 } [ [ [let
    <disjoint-set> :> group
    0 group add-atom 1 group add-atom 0 1 group equate
    group components set
    H{ } clone :> possible
    { tagged-rep double-rep } 0 vreg>scc possible set-at
    possible possibilities set init-costs
    HS{ } clone costed-use-conversions set
    [ ##branch, ] { } make insns>cfg dup needs-loops
    entry>> basic-block set
    0 double-rep compute-shared-use-cost
    0 double-rep compute-shared-use-cost
    1 double-rep compute-shared-use-cost
    0 vreg>scc costs get at tagged-rep swap at
    costed-use-conversions get clear-set
    0 double-rep compute-shared-use-cost
    0 vreg>scc costs get at tagged-rep swap at
] ] with-scope ] unit-test

: repeated-loop-quot ( -- quot )
    [ { fixnum } declare 0.0 swap [ 1.0 float+ ] times ]
    31 [ \ dup ] replicate append [ 32 narray ] append >quotation ;

:: loop-box-counts ( enabled? -- hot cold )
    [
        enabled? conversion-aware-representation-costs? set
        0 :> hot! 0 :> cold!
        repeated-loop-quot test-builder [| graph |
            graph cfg set graph optimize-cfg graph select-representations
            graph linearization-order [| block |
                block instructions>> [ ##allot? ] count :> boxes
                block loop-nesting-at 0 >
                [ hot boxes + hot! ] [ cold boxes + cold! ] if
            ] each
        ] each hot cold
    ] with-scope ;

! The repeated cold uses must not force the float loop phi to stay boxed.
! Verify lowering's actual allocation placement, independently of costs.
{ 1 0 0 1 } [ f loop-box-counts t loop-box-counts ] unit-test

{ t } [
    { f t } [| enabled? |
        [
            enabled? conversion-aware-representation-costs? set
            { 0 1 100 } [| n |
                n repeated-loop-quot compile-call
                32 [ n >float ] replicate =
            ] all?
        ] with-scope
    ] all?
] unit-test

:: bit-preserving-loop-quot ( initial -- quot )
    [ { fixnum } declare ] initial 1array append
    [ swap [ 1.0 float* ] times dup fcos drop gc ] append
    31 [ \ dup ] replicate append [ 32 narray ] append >quotation ;

! Exercise exact float bits, a foreign call and collection after the loop. The policy
! changes only costs; single/double possibilities and conversions remain
! the existing ones. NaN payload propagation is compared OFF versus ON.
{ t } [
    { -0.0 0.0 1.0000000000000002 1/0. -1/0. } [| initial |
        { f t } [| enabled? |
            [
                enabled? conversion-aware-representation-costs? set
                3 initial bit-preserving-loop-quot compile-call
                [ double>bits ] map
            ] with-scope
        ] map first2 =
    ] all?
] unit-test

! A runtime NaN avoids asking constant propagation to solve a NaN-valued
! loop fixed point; still exercise the selected representation, FFI and GC.
: runtime-bit-loop-quot ( -- quot )
    [ { float fixnum } declare [ 1.0 float* ] times dup fcos drop gc ]
    31 [ \ dup ] replicate append [ 32 narray ] append >quotation ;

{ t } [
    { f t } [| enabled? |
        [
            enabled? conversion-aware-representation-costs? set
            0x7ff8000000000123 bits>double 3 runtime-bit-loop-quot compile-call
            [ double>bits ] map
        ] with-scope
    ] map first2 =
] unit-test
