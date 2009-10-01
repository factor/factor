USING: compiler.cfg.gc-checks compiler.cfg.debugger
compiler.cfg.registers compiler.cfg.instructions compiler.cfg
compiler.cfg.predecessors cpu.architecture tools.test kernel vectors
namespaces accessors sequences ;
IN: compiler.cfg.gc-checks.tests

: test-gc-checks ( -- )
    H{ } clone representations set
    cfg new 0 get >>entry
    insert-gc-checks
    drop ;

V{
    T{ ##inc-d f 3 }
    T{ ##replace f 0 D 1 }
} 0 test-bb

V{
    T{ ##box-alien f 0 1 }
} 1 test-bb

0 1 edge

[ ] [ test-gc-checks ] unit-test

[ V{ D 0 D 2 } ] [ 1 get instructions>> first uninitialized-locs>> ] unit-test
