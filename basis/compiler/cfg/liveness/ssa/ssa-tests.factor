USING: accessors compiler.cfg compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.liveness.ssa
compiler.cfg.liveness arrays sequences assocs
compiler.cfg.registers kernel namespaces tools.test ;
IN: compiler.cfg.liveness.ssa.tests

V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##branch }
} 1 test-bb

V{
    T{ ##load-integer f 0 0 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##load-integer f 1 1 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##phi f 2 H{ { 2 0 } { 3 1 } } }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##branch }
} 5 test-bb

V{
    T{ ##replace f 2 D 0 }
    T{ ##branch }
} 6 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 7 test-bb

0 1 edge
1 { 2 3 } edges
2 4 edge
3 4 edge
4 { 5 6 } edges
5 6 edge
6 7 edge

[ ] [ cfg new 0 get >>entry dup cfg set compute-ssa-live-sets ] unit-test

[ t ] [ 0 get live-in assoc-empty? ] unit-test

[ H{ { 2 2 } } ] [ 4 get live-out ] unit-test

[ H{ { 0 0 } } ] [ 2 get 4 get edge-live-in ] unit-test

[ H{ { 1 1 } } ] [ 3 get 4 get edge-live-in ] unit-test
