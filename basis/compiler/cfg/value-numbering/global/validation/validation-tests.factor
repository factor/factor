USING: accessors arrays assocs compiler.cfg.checker compiler.cfg.instructions
compiler.cfg.linearization
compiler.cfg.linear-scan.allocation.state compiler.cfg.register-allocation
compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.verifier compiler.cfg.utilities
compiler.cfg.registers
compiler.cfg.value-numbering compiler.cfg.value-numbering.global.validation
compiler.test cpu.architecture kernel locals math ranges namespaces sequences
tools.test ;
IN: compiler.cfg.value-numbering.global.validation.tests

! This calls the real production selector, not global-value-numbering
! directly. OFF retains both expressions; ON eliminates the dominated one.
:: production-gvn-witness ( enabled? -- repeated )
    V{ T{ ##peek { dst 0 } { loc D: 0 } }
       T{ ##xor-imm { dst 1 } { src1 0 } { src2 7 } }
       T{ ##branch } } 0 test-bb
    V{ T{ ##xor-imm { dst 2 } { src1 0 } { src2 7 } }
       T{ ##branch } } 1 test-bb
    0 1 edge
    0 get block>cfg :> graph
    graph check-ssa
    enabled? global-value-numbering? [ graph value-numbering ] with-variable
    graph check-ssa
    graph cfg>insns [ ##xor-imm? ] count ;

{ 2 1 } [
    f production-gvn-witness t production-gvn-witness
] unit-test

! Independent runtime answers under the full 2x2 flag interaction. The final
! allocation checker remains enabled but is not used as an oracle for GVN:
! its snapshot is taken after the optimization being tested.
{ t } [ [ [let
    t check-allocation? set t check-ssa? set
    linear-scan-allocator register-allocator set
    value-flow-verifier-enabled? t assert=
    { f t } [| gvn? |
        gvn? global-value-numbering? set
        { f t } [| remat? |
            remat? rematerialize-constants? set
            [ gvn-branch-program ] fresh-compiled-word :> branch
            [ gvn-loop-program ] fresh-compiled-word :> loop
            41 <iota> [ 20 - ] map [| x |
                { f t } [| flag |
                    x flag branch execute( x flag -- y )
                    x flag branch-answer =
                ] all?
                { 0 1 2 3 8 17 } [| n |
                    x n loop execute( x n -- y )
                    x n loop-answer =
                ] all? and
            ] all?
        ] all?
    ] all?
] ] with-scope ] unit-test
