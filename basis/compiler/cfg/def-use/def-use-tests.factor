! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel tools.test accessors vectors sequences namespaces
arrays
cpu.architecture
compiler.cfg.def-use
compiler.cfg
compiler.cfg.debugger
compiler.cfg.instructions
compiler.cfg.registers ;

V{
    T{ ##peek f V int-regs 0 D 0 }
    T{ ##peek f V int-regs 1 D 0 }
    T{ ##peek f V int-regs 2 D 0 }
} 1 test-bb
V{
    T{ ##replace f V int-regs 2 D 0 }
} 2 test-bb
1 2 edge
V{
    T{ ##replace f V int-regs 0 D 0 }
} 3 test-bb
2 3 edge
V{ } 4 test-bb
V{ } 5 test-bb
3 { 4 5 } edges
V{
    T{ ##phi f V int-regs 2 H{ { 2 V int-regs 0 } { 3 V int-regs 1 } } }
} 6 test-bb
4 6 edge
5 6 edge

cfg new 1 get >>entry 0 set
[ ] [ 0 get [ compute-defs ] [ compute-uses ] bi ] unit-test
