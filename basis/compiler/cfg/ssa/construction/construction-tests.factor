USING: accessors compiler.cfg compiler.cfg.debugger
compiler.cfg.dominance compiler.cfg.instructions
compiler.cfg.predecessors compiler.cfg.ssa.construction assocs
compiler.cfg.registers cpu.architecture kernel namespaces sequences
tools.test vectors ;
IN: compiler.cfg.ssa.construction.tests

: reset-counters ( -- )
    ! Reset counters so that results are deterministic w.r.t. hash order
    0 vreg-counter set-global
    0 basic-block set-global ;

reset-counters

V{
    T{ ##load-integer f 1 100 }
    T{ ##add-imm f 2 1 50 }
    T{ ##add-imm f 2 2 10 }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##load-integer f 3 3 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##load-integer f 3 4 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##replace f 3 D 0 }
    T{ ##return }
} 3 test-bb

0 { 1 2 } edges
1 3 edge
2 3 edge

: test-ssa ( -- )
    cfg new 0 get >>entry
    dup cfg set
    construct-ssa
    drop ;

[ ] [ test-ssa ] unit-test

[
    V{
        T{ ##load-integer f 1 100 }
        T{ ##add-imm f 2 1 50 }
        T{ ##add-imm f 3 2 10 }
        T{ ##branch }
    }
] [ 0 get instructions>> ] unit-test

[
    V{
        T{ ##load-integer f 4 3 }
        T{ ##branch }
    }
] [ 1 get instructions>> ] unit-test

[
    V{
        T{ ##load-integer f 5 4 }
        T{ ##branch }
    }
] [ 2 get instructions>> ] unit-test

: clean-up-phis ( insns -- insns' )
    [ dup ##phi? [ [ [ [ number>> ] dip ] assoc-map ] change-inputs ] when ] map ;

[
    V{
        T{ ##phi f 6 H{ { 1 4 } { 2 5 } } }
        T{ ##replace f 6 D 0 }
        T{ ##return }
    }
] [
    3 get instructions>>
    clean-up-phis
] unit-test

reset-counters

V{ } 0 test-bb
V{ } 1 test-bb
V{ T{ ##peek f 0 D 0 } } 2 test-bb
V{ T{ ##peek f 0 D 0 } } 3 test-bb
V{ T{ ##replace f 0 D 0 } } 4 test-bb
V{ } 5 test-bb
V{ } 6 test-bb

0 { 1 5 } edges
1 { 2 3 } edges
2 4 edge
3 4 edge
4 6 edge
5 6 edge

[ ] [ test-ssa ] unit-test

[
    V{
        T{ ##phi f 3 H{ { 2 1 } { 3 2 } } }
        T{ ##replace f 3 D 0 }
    }
] [
    4 get instructions>>
    clean-up-phis
] unit-test