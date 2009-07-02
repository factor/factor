IN: compiler.cfg.phi-elimination.tests
USING: compiler.cfg.instructions compiler.cfg compiler.cfg.registers
compiler.cfg.debugger compiler.cfg.phi-elimination kernel accessors
sequences classes namespaces tools.test cpu.architecture arrays ;

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

[ T{ ##copy f V int-regs 3 V int-regs 1 } ] [ 2 get instructions>> second ] unit-test
[ T{ ##copy f V int-regs 3 V int-regs 2 } ] [ 3 get instructions>> second ] unit-test
[ 2 ] [ 4 get instructions>> length ] unit-test