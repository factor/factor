USING: arrays compiler.cfg.gc-checks
compiler.cfg.gc-checks.private compiler.cfg.debugger
compiler.cfg.registers compiler.cfg.instructions compiler.cfg
compiler.cfg.predecessors compiler.cfg.rpo cpu.architecture
tools.test kernel vectors namespaces accessors sequences alien
memory classes make combinators.short-circuit byte-arrays ;
IN: compiler.cfg.gc-checks.tests

: test-gc-checks ( -- )
    H{ } clone representations set
    cfg new 0 get >>entry cfg set ;

V{
    T{ ##inc-d f 3 }
    T{ ##replace f 0 D 1 }
} 0 test-bb

V{
    T{ ##box-alien f 0 1 }
} 1 test-bb

0 1 edge

[ ] [ test-gc-checks ] unit-test

[ t ] [ cfg get blocks-with-gc 1 get 1array sequence= ] unit-test

[ ] [ 1 get allocation-size 123 <alien> size assert= ] unit-test

2 \ vreg-counter set-global

[
    V{
        T{ ##load-tagged f 3 0 }
        T{ ##replace f 3 D 0 }
        T{ ##replace f 3 R 3 }
    }
] [ [ { D 0 R 3 } wipe-locs ] V{ } make ] unit-test

: gc-check? ( bb -- ? )
    instructions>>
    {
        [ length 1 = ]
        [ first ##check-nursery-branch? ]
    } 1&& ;

[ t ] [ 100 <gc-check> gc-check? ] unit-test

2 \ vreg-counter set-global

[
    V{
        T{ ##save-context f 3 4 }
        T{ ##load-tagged f 5 0 }
        T{ ##replace f 5 D 0 }
        T{ ##replace f 5 R 3 }
        T{ ##call-gc f { 0 1 2 } }
        T{ ##branch }
    }
]
[
    { D 0 R 3 } { 0 1 2 } <gc-call> instructions>>
] unit-test

30 \ vreg-counter set-global

V{
    T{ ##branch }
} 0 test-bb

V{
    T{ ##branch }
} 1 test-bb

V{
    T{ ##branch }
} 2 test-bb

V{
    T{ ##branch }
} 3 test-bb

V{
    T{ ##branch }
} 4 test-bb

0 { 1 2 } edges
1 3 edge
2 3 edge
3 4 edge

[ ] [ test-gc-checks ] unit-test

[ ] [ cfg get needs-predecessors drop ] unit-test

[ ] [ 31337 { D 1 R 2 } { 10 20 } 3 get (insert-gc-check) ] unit-test

[ t ] [ 1 get successors>> first gc-check? ] unit-test

[ t ] [ 2 get successors>> first gc-check? ] unit-test

[ t ] [ 3 get predecessors>> first gc-check? ] unit-test

30 \ vreg-counter set-global

V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f 2 D 0 }
    T{ ##inc-d f 3 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##allot f 1 64 byte-array }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##branch }
} 3 test-bb

V{
    T{ ##replace f 2 D 1 }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 5 test-bb

0 1 edge
1 { 2 3 } edges
2 4 edge
3 4 edge
4 5 edge

[ ] [ test-gc-checks ] unit-test

H{
    { 2 tagged-rep }
} representations set

[ ] [ cfg get insert-gc-checks drop ] unit-test

[ 2 ] [ 2 get predecessors>> length ] unit-test

[ t ] [ 1 get successors>> first gc-check? ] unit-test

[ 64 ] [ 1 get successors>> first instructions>> first size>> ] unit-test

[ t ] [ 2 get predecessors>> first gc-check? ] unit-test

[
    V{
        T{ ##save-context f 33 34 }
        T{ ##load-tagged f 35 0 }
        T{ ##replace f 35 D 0 }
        T{ ##replace f 35 D 1 }
        T{ ##replace f 35 D 2 }
        T{ ##call-gc f { 2 } }
        T{ ##branch }
    }
] [ 2 get predecessors>> second instructions>> ] unit-test

! Don't forget to invalidate RPO after inserting basic blocks!
[ 8 ] [ cfg get reverse-post-order length ] unit-test
