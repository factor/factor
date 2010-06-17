USING: compiler.cfg.stacks.uninitialized compiler.cfg.debugger
compiler.cfg.registers compiler.cfg.instructions compiler.cfg
compiler.cfg.predecessors cpu.architecture tools.test kernel vectors
namespaces accessors sequences ;
IN: compiler.cfg.stacks.uninitialized.tests

: test-uninitialized ( -- )
    cfg new 0 get >>entry
    compute-uninitialized-sets ;

V{
    T{ ##inc-d f 3 }
} 0 test-bb

V{
    T{ ##replace f 0 D 0 }
    T{ ##replace f 0 D 1 }
    T{ ##replace f 0 D 2 }
    T{ ##inc-r f 1 }
} 1 test-bb

V{
    T{ ##peek f 0 D 0 }
    T{ ##inc-d f 1 }
} 2 test-bb

0 1 edge
1 2 edge

[ ] [ test-uninitialized ] unit-test

[ { B{ 0 0 0 } B{ } } ] [ 1 get uninitialized-in ] unit-test
[ { B{ 1 1 1 } B{ 0 } } ] [ 2 get uninitialized-in ] unit-test

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

[ { B{ 0 } B{ } } ] [ 3 get uninitialized-in ] unit-test
