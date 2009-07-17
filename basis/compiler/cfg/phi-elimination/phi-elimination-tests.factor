! Copyright (C) 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.cfg.instructions compiler.cfg compiler.cfg.registers
compiler.cfg.comparisons compiler.cfg.debugger locals
compiler.cfg.phi-elimination kernel accessors sequences classes
namespaces tools.test cpu.architecture arrays ;
IN: compiler.cfg.phi-elimination.tests

V{ T{ ##branch } } 0 test-bb

V{
    T{ ##peek f V int-regs 0 D 0 }
    T{ ##compare-branch f V int-regs 0 V int-regs 0 cc< }
} 1 test-bb

V{
    T{ ##load-immediate f V int-regs 1 1 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##load-immediate f V int-regs 2 2 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##phi f V int-regs 3 { } }
    T{ ##replace f V int-regs 3 D 0 }
    T{ ##return }
} 4 test-bb

4 get instructions>> first
2 get V int-regs 1 2array
3 get V int-regs 2 2array 2array
>>inputs drop

test-diamond

[ ] [ cfg new 0 get >>entry eliminate-phis drop ] unit-test

[let | n! [ f ] |

[ ] [ 2 get successors>> first instructions>> first dst>> n>> n! ] unit-test

[ t ] [
    T{ ##copy f V int-regs n V int-regs 1 }
    2 get successors>> first instructions>> first =
] unit-test

[ t ] [
    T{ ##copy f V int-regs n V int-regs 2 }
    3 get successors>> first instructions>> first =
] unit-test

[ t ] [
    T{ ##copy f V int-regs 3 V int-regs n }
    4 get instructions>> first =
] unit-test

]

[ 3 ] [ 4 get instructions>> length ] unit-test
