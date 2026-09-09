USING: accessors arrays assocs compiler.cfg compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.linearization
compiler.cfg.loop-detection compiler.cfg.optimizer compiler.cfg.registers
compiler.cfg.representations compiler.cfg.representations.coalescing
compiler.cfg.representations.selection compiler.cfg.utilities compiler.test
cpu.architecture kernel kernel.private locals math math.private namespaces
quotations sequences sequences.generalizations tools.test ;
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
