USING: arrays compiler.cfg.gc-checks
compiler.cfg.gc-checks.private compiler.cfg.debugger
compiler.cfg.registers compiler.cfg.instructions compiler.cfg
compiler.cfg.predecessors compiler.cfg.rpo cpu.architecture
tools.test kernel vectors namespaces accessors sequences alien
memory classes make combinators.short-circuit byte-arrays
compiler.cfg.comparisons ;
IN: compiler.cfg.gc-checks.tests

[ { } ] [
    V{
        T{ ##inc-d }
        T{ ##peek }
        T{ ##add }
        T{ ##branch }
    } gc-check-offsets
] unit-test

[ { } ] [
    V{
        T{ ##inc-d }
        T{ ##peek }
        T{ ##alien-invoke }
        T{ ##add }
        T{ ##branch }
    } gc-check-offsets
] unit-test

[ { 0 } ] [
    V{
        T{ ##inc-d }
        T{ ##peek }
        T{ ##allot }
        T{ ##alien-invoke }
        T{ ##add }
        T{ ##branch }
    } gc-check-offsets
] unit-test

[ { 0 } ] [
    V{
        T{ ##inc-d }
        T{ ##peek }
        T{ ##allot }
        T{ ##allot }
        T{ ##add }
        T{ ##branch }
    } gc-check-offsets
] unit-test

[ { 0 4 } ] [
    V{
        T{ ##inc-d }
        T{ ##peek }
        T{ ##allot }
        T{ ##alien-invoke }
        T{ ##allot }
        T{ ##add }
        T{ ##sub }
        T{ ##branch }
    } gc-check-offsets
] unit-test

[ { 3 } ] [
    V{
        T{ ##inc-d }
        T{ ##peek }
        T{ ##alien-invoke }
        T{ ##allot }
        T{ ##add }
        T{ ##branch }
    } gc-check-offsets
] unit-test

[ { { "a" } } ] [ { "a" } { } split-instructions ] unit-test

[ { { } { "a" } } ] [ { "a" } { 0 } split-instructions ] unit-test

[ { { "a" } { } } ] [ { "a" } { 1 } split-instructions ] unit-test

[ { { "a" } { "b" } } ] [ { "a" "b" } { 1 } split-instructions ] unit-test

[ { { } { "a" } { "b" "c" } } ] [ { "a" "b" "c" } { 0 1 } split-instructions ] unit-test

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

[ ] [ 1 get instructions>> allocation-size 123 <alien> size assert= ] unit-test

2 vreg-counter set-global

: gc-check? ( bb -- ? )
    instructions>>
    {
        [ length 1 = ]
        [ first ##check-nursery-branch? ]
    } 1&& ;

: gc-call? ( bb -- ? )
    instructions>>
    V{
        T{ ##call-gc f T{ gc-map } }
        T{ ##branch }
    } = ;

4 vreg-counter set-global

[ t ] [ <gc-call> gc-call? ] unit-test

30 vreg-counter set-global

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

[ ] [ 1 get successors>> first successors>> first 2 set ] unit-test

[ 2 ] [ 2 get predecessors>> length ] unit-test

[ t ] [ 1 get successors>> first gc-check? ] unit-test

[ 64 ] [ 1 get successors>> first instructions>> first size>> ] unit-test

[ t ] [ 2 get predecessors>> first gc-check? ] unit-test

[
    V{
        T{ ##call-gc f T{ gc-map } }
        T{ ##branch }
    }
] [ 2 get predecessors>> second instructions>> ] unit-test

! Don't forget to invalidate RPO after inserting basic blocks!
[ 8 ] [ cfg get reverse-post-order length ] unit-test

! Do the right thing with ##phi instructions
V{
    T{ ##branch }
} 0 test-bb

V{
    T{ ##load-reference f 1 "hi" }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##load-reference f 2 "bye" }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##phi f 3 H{ { 1 1 } { 2 2 } } }
    T{ ##allot f 1 64 byte-array }
    T{ ##branch }
} 3 test-bb

0 { 1 2 } edges
1 3 edge
2 3 edge

[ ] [ test-gc-checks ] unit-test

H{
    { 1 tagged-rep }
    { 2 tagged-rep }
    { 3 tagged-rep }
} representations set

[ ] [ cfg get insert-gc-checks drop ] unit-test
[ ] [ 1 get successors>> first successors>> first 3 set ] unit-test
[ t ] [ 2 get successors>> first instructions>> first ##phi? ] unit-test
[ 2 ] [ 3 get instructions>> length ] unit-test

! GC check in a block that is its own successor
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##allot f 1 64 byte-array }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 2 test-bb

0 1 edge
1 { 1 2 } edges

[ ] [ test-gc-checks ] unit-test

[ ] [ cfg get insert-gc-checks drop ] unit-test

[ ] [
    0 get successors>> first predecessors>>
    [ first 0 get assert= ]
    [ second 1 get [ instructions>> ] bi@ assert= ] bi
] unit-test

[ ] [
    0 get successors>> first successors>>
    [ first 1 get [ instructions>> ] bi@ assert= ]
    [ second gc-call? t assert= ] bi
] unit-test

[ ] [
    2 get predecessors>> first predecessors>>
    [ first gc-check? t assert= ]
    [ second gc-call? t assert= ] bi
] unit-test

! Brave new world of calls in the middle of BBs

! call then allot
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##alien-invoke f "malloc" f f f f f T{ gc-map } }
    T{ ##allot f 1 64 byte-array }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 2 test-bb

0 1 edge
1 2 edge

2 vreg-counter set-global

[ ] [ test-gc-checks ] unit-test

[ ] [ cfg get insert-gc-checks drop ] unit-test

! The GC check should come after the alien-invoke
[
    V{
        T{ ##alien-invoke f "malloc" f f f f f T{ gc-map } }
        T{ ##check-nursery-branch f 64 cc<= 3 4 }
    }
] [ 0 get successors>> first instructions>> ] unit-test

! call then allot then call then allot
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##alien-invoke f "malloc" f f f f f T{ gc-map } }
    T{ ##allot f 1 64 byte-array }
    T{ ##alien-invoke f "malloc" f f f f f T{ gc-map } }
    T{ ##allot f 2 64 byte-array }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 2 test-bb

0 1 edge
1 2 edge

2 vreg-counter set-global

[ ] [ test-gc-checks ] unit-test

[ ] [ cfg get insert-gc-checks drop ] unit-test

[
    V{
        T{ ##alien-invoke f "malloc" f f f f f T{ gc-map } }
        T{ ##check-nursery-branch f 64 cc<= 3 4 }
    }
] [
    0 get
    successors>> first
    instructions>>
] unit-test

[
    V{
        T{ ##allot f 1 64 byte-array }
        T{ ##alien-invoke f "malloc" f f f f f T{ gc-map } }
        T{ ##check-nursery-branch f 64 cc<= 5 6 }
    }
] [
    0 get
    successors>> first
    successors>> first
    instructions>>
] unit-test

[
    V{
        T{ ##allot f 2 64 byte-array }
        T{ ##branch }
    }
] [
    0 get
    successors>> first
    successors>> first
    successors>> first
    instructions>>
] unit-test
