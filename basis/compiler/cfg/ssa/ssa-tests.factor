USING: accessors compiler.cfg compiler.cfg.debugger
compiler.cfg.dominance compiler.cfg.instructions
compiler.cfg.predecessors compiler.cfg.ssa assocs
compiler.cfg.registers cpu.architecture kernel namespaces sequences
tools.test vectors ;
IN: compiler.cfg.ssa.tests

! Reset counters so that results are deterministic w.r.t. hash order
0 vreg-counter set-global
0 basic-block set-global

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
    compute-dominance
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

[
    V{
        T{ ##phi f V int-regs 6 H{ { 1 V int-regs 4 } { 2 V int-regs 5 } } }
        T{ ##replace f V int-regs 6 D 0 }
        T{ ##return }
    }
] [
    3 get instructions>>
    [ dup ##phi? [ [ [ [ number>> ] dip ] assoc-map ] change-inputs ] when ] map
] unit-test