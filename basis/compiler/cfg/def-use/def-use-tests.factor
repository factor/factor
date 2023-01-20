! Copyright (C) 2009 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.utilities compiler.test namespaces
tools.test ;
IN: compiler.cfg.def-use.tests

! compute-insns
{
    T{ ##peek f 123 D: 0 f }
} [
    { T{ ##peek f 123 D: 0 } } 0 insns>block block>cfg compute-insns
    123 insn-of
] unit-test

V{
    T{ ##peek f 0 D: 0 }
    T{ ##peek f 1 D: 0 }
    T{ ##peek f 2 D: 0 }
} 1 test-bb
V{
    T{ ##replace f 2 D: 0 }
} 2 test-bb
1 2 edge
V{
    T{ ##replace f 0 D: 0 }
} 3 test-bb
2 3 edge
V{ } 4 test-bb
V{ } 5 test-bb
3 { 4 5 } edges
V{
    T{ ##phi f 2 H{ { 2 0 } { 3 1 } } }
} 6 test-bb
4 6 edge
5 6 edge

1 get block>cfg 0 set
{ } [ 0 get compute-defs ] unit-test
