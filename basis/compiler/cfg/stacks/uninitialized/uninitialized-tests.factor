IN: compiler.cfg.stacks.uninitialized.tests
USING: compiler.cfg.stacks.uninitialized compiler.cfg.debugger
compiler.cfg.registers compiler.cfg.instructions compiler.cfg
compiler.cfg.predecessors cpu.architecture tools.test kernel vectors
namespaces accessors sequences ;

: test-uninitialized ( -- )
    cfg new 0 get >>entry
    compute-predecessors
    compute-uninitialized-sets ;

V{
    T{ ##inc-d f 3 }
} 0 test-bb

V{
    T{ ##replace f V int-regs 0 D 0 }
    T{ ##replace f V int-regs 0 D 1 }
    T{ ##replace f V int-regs 0 D 2 }
    T{ ##inc-r f 1 }
} 1 test-bb

V{
    T{ ##peek f V int-regs 0 D 0 }
    T{ ##inc-d f 1 }
} 2 test-bb

0 1 edge
1 2 edge

[ ] [ test-uninitialized ] unit-test

[ V{ D 0 D 1 D 2 } ] [ 1 get uninitialized-locs ] unit-test
[ V{ R 0 } ] [ 2 get uninitialized-locs ] unit-test

! When merging, if a location is uninitialized in one branch and
! initialized in another, we have to consider it uninitialized,
! since it cannot be safely read from by a ##peek, or traced by GC.

V{ } 0 test-bb

V{
    T{ ##inc-d f 1 }
} 1 test-bb

V{
    T{ ##call f namestack }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##return }
} 3 test-bb

0 { 1 2 } edges
1 3 edge
2 3 edge

[ ] [ test-uninitialized ] unit-test

[ V{ D 0 } ] [ 3 get uninitialized-locs ] unit-test
