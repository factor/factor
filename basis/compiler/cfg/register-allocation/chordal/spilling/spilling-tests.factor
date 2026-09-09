USING: accessors assocs compiler.cfg compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.linearization
compiler.cfg.register-allocation.chordal.spilling
compiler.cfg.register-allocation.chordal.bases
compiler.cfg.register-allocation.validation
compiler.cfg.register-allocation.rematerialization compiler.cfg.registers
compiler.cfg.rpo compiler.cfg.utilities cpu.architecture kernel locals math namespaces sequences
sets tools.test ;
IN: compiler.cfg.register-allocation.chordal.spilling.tests

! This is the actual source rewrite under a two-register bank. The first
! add input dies early and may share the output register. Value 1 is saved
! while the nearer operands are used, then reloaded into a fresh SSA name.
: pressure-cfg ( -- cfg )
    V{
        T{ ##load-integer { dst 1 } { val 11 } }
        T{ ##load-integer { dst 2 } { val 22 } }
        T{ ##load-integer { dst 3 } { val 33 } }
        T{ ##add { dst 4 } { src1 2 } { src2 3 } }
        T{ ##add { dst 5 } { src1 4 } { src2 1 } }
        T{ ##return }
    } clone insns>cfg ;

{ t t t t } [ [let
    f rematerialize-constants? namespaces:set
    H{ { 1 int-rep } { 2 int-rep } { 3 int-rep }
        { 4 int-rep } { 5 int-rep } } clone representations namespaces:set
    10 vreg-counter namespaces:set
    pressure-cfg [
        dup H{ { int-regs { 0 1 } } } spill-ssa :> ( fixed stats )
        cfg>insns :> instructions
        instructions [ ##spill? ] any?
        instructions [ ##reload? ] filter [ dst>> 10 >= ] all?
        fixed values [ spill-slot? ] all?
        instructions [ ##add? ] filter last src2>> 10 >=
    ] with-cfg
] ] unit-test

:: check-rewritten-phis ( graph -- ? )
    graph reverse-post-order [| bb |
        bb instructions>> [ ##phi? ] filter [| phi |
            phi inputs>> keys bb predecessors>> set=
        ] all?
    ] all? ;

{ t t t } [ [let
    f rematerialize-constants? namespaces:set
    6 3 <validation-diamond> [
        dup construct-ssa-bases dup compute-ssa-live-sets
        dup dup 2 2 validation-register-bank spill-ssa :> ( fixed stats )
        check-rewritten-phis
        "memory-phis" stats at 0 >
        "edge-blocks" stats at 0 >
    ] with-cfg
] ] unit-test

{ t t } [ [let
    f rematerialize-constants? namespaces:set
    2 t <validation-cycle> [
        dup construct-ssa-bases dup compute-ssa-live-sets
        dup dup 2 2 validation-register-bank spill-ssa :> ( fixed stats )
        check-rewritten-phis
        "reload-definitions" stats at 0 >
    ] with-cfg
] ] unit-test
