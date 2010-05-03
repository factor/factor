USING: accessors compiler.cfg compiler.cfg.debugger
compiler.cfg.def-use compiler.cfg.dominance
compiler.cfg.instructions compiler.cfg.liveness.ssa
compiler.cfg.registers compiler.cfg.predecessors
compiler.cfg.ssa.interference
compiler.cfg.ssa.interference.live-ranges cpu.architecture
kernel namespaces tools.test ;
IN: compiler.cfg.ssa.interference.tests

: test-interference ( -- )
    cfg new 0 get >>entry
    dup compute-ssa-live-sets
    dup compute-defs
    compute-live-ranges ;

V{
    T{ ##peek f 0 D 0 }
    T{ ##peek f 2 D 0 }
    T{ ##copy f 1 0 }
    T{ ##copy f 3 2 }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f 4 D 0 }
    T{ ##peek f 5 D 0 }
    T{ ##replace f 3 D 0 }
    T{ ##peek f 6 D 0 }
    T{ ##replace f 5 D 0 }
    T{ ##return }
} 1 test-bb

0 1 edge

[ ] [ test-interference ] unit-test

[ f ] [ 0 1 vregs-interfere? ] unit-test
[ f ] [ 1 0 vregs-interfere? ] unit-test
[ f ] [ 2 3 vregs-interfere? ] unit-test
[ f ] [ 3 2 vregs-interfere? ] unit-test
[ t ] [ 0 2 vregs-interfere? ] unit-test
[ t ] [ 2 0 vregs-interfere? ] unit-test
[ f ] [ 1 3 vregs-interfere? ] unit-test
[ f ] [ 3 1 vregs-interfere? ] unit-test
[ t ] [ 3 4 vregs-interfere? ] unit-test
[ t ] [ 4 3 vregs-interfere? ] unit-test
[ t ] [ 3 5 vregs-interfere? ] unit-test
[ t ] [ 5 3 vregs-interfere? ] unit-test
[ f ] [ 3 6 vregs-interfere? ] unit-test
[ f ] [ 6 3 vregs-interfere? ] unit-test