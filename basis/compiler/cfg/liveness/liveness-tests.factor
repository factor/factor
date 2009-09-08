USING: compiler.cfg.liveness compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.predecessors
compiler.cfg.registers compiler.cfg cpu.architecture
accessors namespaces sequences kernel tools.test vectors ;
IN: compiler.cfg.liveness.tests

: test-liveness ( -- )
    cfg new 1 get >>entry
    compute-live-sets ;

! Sanity check...

V{
    T{ ##peek f 0 D 0 }
    T{ ##replace f 0 D 0 }
    T{ ##replace f 1 D 1 }
    T{ ##peek f 1 D 1 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##replace f 2 D 0 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##replace f 3 D 0 }
    T{ ##return }
} 3 test-bb

1 { 2 3 } edges

test-liveness

[
    H{
        { 1 1 }
        { 2 2 }
        { 3 3 }
    }
]
[ 1 get live-in ]
unit-test

! Tricky case; defs must be killed before uses

V{
    T{ ##peek f 0 D 0 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##add-imm f 0 0 10 }
    T{ ##return }
} 2 test-bb

1 2 edge

test-liveness

[ H{ { 0 0 } } ] [ 2 get live-in ] unit-test