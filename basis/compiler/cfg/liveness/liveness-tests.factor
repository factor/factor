USING: compiler.cfg.liveness compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.predecessors
compiler.cfg.registers compiler.cfg cpu.architecture
accessors namespaces sequences kernel tools.test ;
IN: compiler.cfg.liveness.tests

! Sanity check...

V{
    T{ ##peek f V int-regs 0 D 0 }
    T{ ##replace f V int-regs 0 D 0 }
    T{ ##replace f V int-regs 1 D 1 }
    T{ ##peek f V int-regs 1 D 1 }
} 1 test-bb

V{
    T{ ##replace f V int-regs 2 D 0 }
} 2 test-bb

V{
    T{ ##replace f V int-regs 3 D 0 }
} 3 test-bb

1 get 2 get 3 get V{ } 2sequence >>successors drop

cfg new 1 get >>entry
compute-predecessors
compute-live-sets

[
    H{
        { V int-regs 1 V int-regs 1 }
        { V int-regs 2 V int-regs 2 }
        { V int-regs 3 V int-regs 3 }
    }
]
[ 1 get live-in ]
unit-test