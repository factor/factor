IN: compiler.cfg.branch-folding.tests
USING: compiler.cfg.branch-folding compiler.cfg.instructions
compiler.cfg compiler.cfg.registers compiler.cfg.debugger
arrays compiler.cfg.phi-elimination compiler.cfg.dce
compiler.cfg.predecessors kernel accessors assocs
sequences classes namespaces tools.test cpu.architecture ;

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

[ ] [ cfg new 0 get >>entry fold-branches compute-predecessors eliminate-phis drop ] unit-test

[ 1 ] [ 1 get successors>> length ] unit-test
[ t ] [ 1 get successors>> first 3 get eq? ] unit-test

[ T{ ##copy f V int-regs 3 V int-regs 2 } ] [ 3 get instructions>> second ] unit-test
[ 2 ] [ 4 get instructions>> length ] unit-test

V{
    T{ ##peek f V int-regs 0 D 0 }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f V int-regs 1 D 1 }
    T{ ##compare-branch f V int-regs 1 V int-regs 1 cc< }
} 1 test-bb

V{
    T{ ##copy f V int-regs 2 V int-regs 0 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##phi f V int-regs 3 V{ } }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##replace f V int-regs 3 D 0 }
    T{ ##return }
} 4 test-bb

1 get V int-regs 1 2array
2 get V int-regs 0 2array 2array 3 get instructions>> first (>>inputs)

test-diamond

[ ] [
    cfg new 0 get >>entry
    compute-predecessors
    fold-branches
    compute-predecessors
    eliminate-dead-code
    drop
] unit-test

[ 1 ] [ 3 get instructions>> first inputs>> assoc-size ] unit-test