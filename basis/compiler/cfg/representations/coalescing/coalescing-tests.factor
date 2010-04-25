USING: arrays sequences kernel namespaces accessors compiler.cfg
compiler.cfg.instructions
compiler.cfg.registers
compiler.cfg.debugger
compiler.cfg.representations.coalescing
tools.test ;
IN: compiler.cfg.representations.coalescing.tests

: test-scc ( -- )
    cfg new 0 get >>entry compute-components ;

V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f 2 D 0 }
    T{ ##load-integer f 0 0 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##load-integer f 1 0 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##phi f 3 }
} 3 test-bb

0 { 1 2 } edges
1 3 edge
2 3 edge

1 get 0 2array
2 get 1 2array 2array 3 get instructions>> first (>>inputs)

[ ] [ test-scc ] unit-test

[ t ] [ 0 vreg>scc 1 vreg>scc = ] unit-test
[ t ] [ 0 vreg>scc 3 vreg>scc = ] unit-test
[ f ] [ 2 vreg>scc 3 vreg>scc = ] unit-test
