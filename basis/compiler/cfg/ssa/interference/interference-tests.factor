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
    compute-ssa-live-sets
    compute-predecessors
    dup compute-defs
    dup compute-dominance
    compute-live-ranges ;

V{
    T{ ##peek f V int-rep 0 D 0 }
    T{ ##peek f V int-rep 2 D 0 }
    T{ ##copy f V int-rep 1 V int-rep 0 }
    T{ ##copy f V int-rep 3 V int-rep 2 }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f V int-rep 4 D 0 }
    T{ ##peek f V int-rep 5 D 0 }
    T{ ##replace f V int-rep 3 D 0 }
    T{ ##peek f V int-rep 6 D 0 }
    T{ ##replace f V int-rep 5 D 0 }
    T{ ##return }
} 1 test-bb

0 1 edge

[ ] [ test-interference ] unit-test

[ f ] [ V int-rep 0 V int-rep 1 vregs-interfere? ] unit-test
[ f ] [ V int-rep 1 V int-rep 0 vregs-interfere? ] unit-test
[ f ] [ V int-rep 2 V int-rep 3 vregs-interfere? ] unit-test
[ f ] [ V int-rep 3 V int-rep 2 vregs-interfere? ] unit-test
[ t ] [ V int-rep 0 V int-rep 2 vregs-interfere? ] unit-test
[ t ] [ V int-rep 2 V int-rep 0 vregs-interfere? ] unit-test
[ f ] [ V int-rep 1 V int-rep 3 vregs-interfere? ] unit-test
[ f ] [ V int-rep 3 V int-rep 1 vregs-interfere? ] unit-test
[ t ] [ V int-rep 3 V int-rep 4 vregs-interfere? ] unit-test
[ t ] [ V int-rep 4 V int-rep 3 vregs-interfere? ] unit-test
[ t ] [ V int-rep 3 V int-rep 5 vregs-interfere? ] unit-test
[ t ] [ V int-rep 5 V int-rep 3 vregs-interfere? ] unit-test
[ f ] [ V int-rep 3 V int-rep 6 vregs-interfere? ] unit-test
[ f ] [ V int-rep 6 V int-rep 3 vregs-interfere? ] unit-test