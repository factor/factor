USING: accessors compiler.cfg compiler.cfg.debugger
compiler.cfg.dominance compiler.cfg.instructions
compiler.cfg.predecessors compiler.cfg.ssa assocs
compiler.cfg.registers cpu.architecture kernel namespaces sequences
tools.test vectors ;
IN: compiler.cfg.ssa.tests

: reset-counters ( -- )
    ! Reset counters so that results are deterministic w.r.t. hash order
    0 vreg-counter set-global
    0 basic-block set-global ;

reset-counters

V{
    T{ ##load-immediate f V int-regs 1 100 }
    T{ ##add-imm f V int-regs 2 V int-regs 1 50 }
    T{ ##add-imm f V int-regs 2 V int-regs 2 10 }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##load-immediate f V int-regs 3 3 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##load-immediate f V int-regs 3 4 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##replace f V int-regs 3 D 0 }
    T{ ##return }
} 3 test-bb

0 get 1 get 2 get V{ } 2sequence >>successors drop
1 get 3 get 1vector >>successors drop
2 get 3 get 1vector >>successors drop

: test-ssa ( -- )
    cfg new 0 get >>entry
    compute-predecessors
    construct-ssa
    drop ;

[ ] [ test-ssa ] unit-test

[
    V{
        T{ ##load-immediate f V int-regs 1 100 }
        T{ ##add-imm f V int-regs 2 V int-regs 1 50 }
        T{ ##add-imm f V int-regs 3 V int-regs 2 10 }
        T{ ##branch }
    }
] [ 0 get instructions>> ] unit-test

[
    V{
        T{ ##load-immediate f V int-regs 4 3 }
        T{ ##branch }
    }
] [ 1 get instructions>> ] unit-test

[
    V{
        T{ ##load-immediate f V int-regs 5 4 }
        T{ ##branch }
    }
] [ 2 get instructions>> ] unit-test

: clean-up-phis ( insns -- insns' )
    [ dup ##phi? [ [ [ [ number>> ] dip ] assoc-map ] change-inputs ] when ] map ;

[
    V{
        T{ ##phi f V int-regs 6 H{ { 1 V int-regs 4 } { 2 V int-regs 5 } } }
        T{ ##replace f V int-regs 6 D 0 }
        T{ ##return }
    }
] [
    3 get instructions>>
    clean-up-phis
] unit-test

reset-counters

V{ } 0 test-bb
V{ } 1 test-bb
V{ T{ ##peek f V int-regs 0 D 0 } } 2 test-bb
V{ T{ ##peek f V int-regs 0 D 0 } } 3 test-bb
V{ T{ ##replace f V int-regs 0 D 0 } } 4 test-bb
V{ } 5 test-bb
V{ } 6 test-bb

0 get 1 get 5 get V{ } 2sequence >>successors drop
1 get 2 get 3 get V{ } 2sequence >>successors drop
2 get 4 get 1vector >>successors drop
3 get 4 get 1vector >>successors drop
4 get 6 get 1vector >>successors drop
5 get 6 get 1vector >>successors drop

[ ] [ test-ssa ] unit-test

[
    V{
        T{ ##phi f V int-regs 3 H{ { 2 V int-regs 1 } { 3 V int-regs 2 } } }
        T{ ##replace f V int-regs 3 D 0 }
    }
] [
    4 get instructions>>
    clean-up-phis
] unit-test