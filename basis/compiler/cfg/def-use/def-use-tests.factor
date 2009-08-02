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
1 get 2 get 1vector >>successors drop
V{
    T{ ##replace f V int-regs 0 D 0 }
} 3 test-bb
2 get 3 get 1vector >>successors drop
V{ } 4 test-bb
V{ } 5 test-bb
3 get 4 get 5 get V{ } 2sequence >>successors drop
V int-regs 2
    2 get V int-regs 0 2array
    3 get V int-regs 1 2array
2array \ ##phi new-insn 1vector
6 test-bb
4 get 6 get 1vector >>successors drop
5 get 6 get 1vector >>successors drop

cfg new 1 get >>entry 0 set
[ ] [ 0 get compute-def-use ] unit-test
