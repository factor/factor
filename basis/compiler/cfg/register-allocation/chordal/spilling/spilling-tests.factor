USING: accessors arrays assocs compiler.cfg compiler.cfg.def-use
compiler.cfg.instructions compiler.cfg.linearization
compiler.cfg.register-allocation.chordal
compiler.cfg.register-allocation.chordal.spilling
compiler.cfg.register-allocation.chordal.bases
compiler.cfg.register-allocation.validation
compiler.cfg.register-allocation.rematerialization compiler.cfg.registers
compiler.cfg.rpo compiler.cfg.utilities cpu.architecture kernel layouts locals make math namespaces sequences
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

! A raw callback result address remains live in a memory home across a
! Factor call. Such kill blocks must not acquire register repair phis:
! the physical assignment walk intentionally skips them.
{ t t t t } [ [let
    f rematerialize-constants? namespaces:set
    H{ { 1 int-rep } { 2 int-rep } } clone representations namespaces:set
    10 vreg-counter namespaces:set
    V{ T{ ##load-integer { dst 1 } { val 100 } } T{ ##branch } }
    clone 0 insns>block :> entry
    V{ T{ ##call } T{ ##branch } } clone 1 insns>block
    t >>kill-block? :> call-block
    V{ T{ ##add-imm { dst 2 } { src1 1 } { src2 8 } } T{ ##return } }
    clone 2 insns>block :> done
    entry call-block connect-bbs call-block done connect-bbs
    entry block>cfg [
        dup H{ { int-regs { 0 1 } } } spill-ssa 2drop
        cfg>insns :> instructions
        instructions [ ##spill? ] any?
        call-block instructions>> [ ##phi? ] any? not
        call-block spill-plans get at exit-versions>> assoc-empty?
        instructions [ ##reload? ] any?
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
        ! Memory-only phi inputs remain in memory until their actual use;
        ! their ordinary parallel edge copies are lowered after coloring.
        "edge-blocks" stats at 0 or zero?
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

! The first value was saved before a block boundary. Loading it eagerly at
! the successor entry only evicts it again for the local constant before
! its actual use. An entry with a known predecessor inherits residency;
! the saved value gets one reload at its use, not two speculative reloads.
:: entry-reload-pressure-cfg ( -- graph )
    init-validation-representations
    [
        ##prologue,
        1 D: 0 ##peek,
        2 22 tag-fixnum ##load-integer,
        3 33 tag-fixnum ##load-integer,
        4 2 3 ##add, ##branch,
    ] V{ } make 0 insns>block :> entry
    [
        5 44 tag-fixnum ##load-integer,
        6 4 5 ##add,
        7 6 1 ##add,
        7 D: 0 ##replace,
        ##epilogue, ##return,
    ] V{ } make 1 insns>block :> done
    entry done connect-bbs entry block>cfg ;

{ { { 1 1 } { 1 1 } } } [
    { f t } [ [| rematerialize? |
        rematerialize? rematerialize-constants? namespaces:set
        entry-reload-pressure-cfg [
            dup construct-ssa-bases dup compute-ssa-live-sets
            dup 2 2 validation-register-bank spill-ssa nip
            [ "pressure-stores" of ] [ "reload-definitions" of ] bi 2array
        ] with-cfg
    ] with-scope ] map
] unit-test

{ { { 110 92 } { 110 92 } } } [
    { f t } [ [| rematerialize? |
        rematerialize? rematerialize-constants? namespaces:set
        entry-reload-pressure-cfg :> graph
        chordal-allocator graph 2 2 validation-register-bank
        [ chordal-allocation-with-registers ] constrained-allocator boa
        graph swap compile-validation-cfg :> word
        11 word execute( input -- result )
        -7 word execute( input -- result ) 2array
    ] with-scope ] map
] unit-test
