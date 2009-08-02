USING: compiler.cfg.instructions compiler.cfg.registers cpu.architecture
compiler.cfg.debugger arrays accessors kernel namespaces sequences assocs
compiler.cfg.predecessors compiler.cfg.ssa.destruction tools.test
compiler.cfg vectors ;
IN: compiler.cfg.ssa.destruction.tests

! This needs way more tests

! Untested code path
V{
    T{ ##peek f V int-regs 0 D 0 }
} 0 test-bb

V{
    T{ ##peek f V int-regs 1 D 0 }
} 1 test-bb

V{
    T{ ##replace f V int-regs 0 D 0 }
} 2 test-bb

V{
    T{ ##branch }
} 3 test-bb

V{
    T{ ##phi f V int-regs 2 H{ { 2 V int-regs 1 } { 3 V int-regs 0 } } }
} 4 test-bb

0 { 1 3 } edges
1 2 edge
2 4 edge
3 4 edge

: test-destruction ( -- )
    cfg new 0 get >>entry compute-predecessors destruct-ssa drop ;

[ ] [ test-destruction ] unit-test

! "Virtual swap" problem
V{
    T{ ##peek f V int-regs 0 D 0 }
    T{ ##peek f V int-regs 1 D 1 }
} 0 test-bb

V{
    T{ ##branch }
} 1 test-bb

V{
    T{ ##branch }
} 2 test-bb

V{
    T{ ##phi f V int-regs 2 H{ { 1 V int-regs 0 } { 2 V int-regs 1 } } }
    T{ ##phi f V int-regs 3 H{ { 1 V int-regs 1 } { 2 V int-regs 0 } } }
} 3 test-bb

0 { 1 2 } edges
1 3 edge
2 3 edge

[ ] [ test-destruction ] unit-test

! How to test?

! Reduction of suffix-arrays regression
V{
    T{ ##peek f V int-regs 48 D 0 }
    T{ ##peek f V int-regs 47 D 0 }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##branch }
} 1 test-bb

V{
    T{ ##branch }
} 2 test-bb

V{
    T{ ##branch }
} 3 test-bb

V{
    T{ ##phi f V int-regs 94 H{ { 1 V int-regs 48 } { 2 V int-regs 47 } } }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##branch }
} 5 test-bb

V{
    T{ ##branch }
} 6 test-bb

V{
    T{ ##branch }
} 7 test-bb

V{
    T{ ##phi f V int-regs 56 H{ { 3 V int-regs 48 } { 6 V int-regs 94 } { 7 V int-regs 94 } { 5 V int-regs 47 } } }
    T{ ##branch }
} 8 test-bb

0 { 1 2 } edges
1 { 3 4 } edges
2 { 4 5 } edges
4 { 6 7 } edges
3 8 edge
6 8 edge
7 8 edge
5 8 edge

[ ] [ test-destruction ] unit-test

[ f ] [ 0 get instructions>> first2 [ dst>> ] bi@ = ] unit-test