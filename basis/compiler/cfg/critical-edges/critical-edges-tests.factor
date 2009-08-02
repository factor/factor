USING: accessors assocs compiler.cfg
compiler.cfg.critical-edges compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.predecessors
compiler.cfg.registers cpu.architecture kernel namespaces
sequences tools.test compiler.cfg.utilities ;
IN: compiler.cfg.critical-edges.tests

! Make sure we update phi nodes when splitting critical edges

: test-critical-edges ( -- )
    cfg new 0 get >>entry
    compute-predecessors
    split-critical-edges ;

V{
    T{ ##peek f V int-regs 0 D 0 }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f V int-regs 1 D 1 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##phi f V int-regs 2 H{ { 0 V int-regs 0 } { 1 V int-regs 1 } } }
    T{ ##return }
} 2 test-bb

0 { 1 2 } edges
1 2 edge

[ ] [ test-critical-edges ] unit-test

[ t ] [ 0 get successors>> second successors>> first 2 get eq? ] unit-test

[ V int-regs 0 ] [ 2 get instructions>> first inputs>> 0 get successors>> second swap at ] unit-test