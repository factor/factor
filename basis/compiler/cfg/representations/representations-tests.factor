USING: accessors compiler.cfg compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.representations.preferred cpu.architecture kernel
namespaces tools.test sequences arrays system ;
IN: compiler.cfg.representations

[ { double-rep double-rep } ] [
    T{ ##add-float
       { dst 5 }
       { src1 3 }
       { src2 4 }
    } uses-vreg-reps
] unit-test

[ double-rep ] [
    T{ ##alien-double
       { dst 5 }
       { src 3 }
    } defs-vreg-rep
] unit-test

: test-representations ( -- )
    cfg new 0 get >>entry dup cfg set select-representations drop ;

! Make sure cost calculation isn't completely wrong
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f 1 D 0 }
    T{ ##peek f 2 D 1 }
    T{ ##add-float f 3 1 2 }
    T{ ##replace f 3 D 0 }
    T{ ##replace f 3 D 1 }
    T{ ##replace f 3 D 2 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 2 test-bb

0 1 edge
1 2 edge

[ ] [ test-representations ] unit-test

[ 1 ] [ 1 get instructions>> [ ##allot? ] count ] unit-test

cpu x86.32? [

    ! Make sure load-constant is converted into load-double
    V{
        T{ ##prologue }
        T{ ##branch }
    } 0 test-bb

    V{
        T{ ##peek f 1 D 0 }
        T{ ##load-constant f 2 0.5 }
        T{ ##add-float f 3 1 2 }
        T{ ##replace f 3 D 0 }
        T{ ##branch }
    } 1 test-bb

    V{
        T{ ##epilogue }
        T{ ##return }
    } 2 test-bb

    0 1 edge
    1 2 edge

    [ ] [ test-representations ] unit-test

    [ t ] [ 1 get instructions>> second ##load-double? ] unit-test

    ! Make sure phi nodes are handled in a sane way
    V{
        T{ ##prologue }
        T{ ##branch }
    } 0 test-bb

    V{
        T{ ##peek f 1 D 0 }
        T{ ##compare-imm-branch f 1 2 }
    } 1 test-bb

    V{
        T{ ##load-constant f 2 1.5 }
        T{ ##branch }
    } 2 test-bb

    V{
        T{ ##load-constant f 3 2.5 }
        T{ ##branch }
    } 3 test-bb

    V{
        T{ ##phi f 4 }
        T{ ##peek f 5 D 0 }
        T{ ##add-float f 6 4 5 }
        T{ ##replace f 6 D 0 }
    } 4 test-bb

    V{
        T{ ##epilogue }
        T{ ##return }
    } 5 test-bb

    test-diamond
    4 5 edge

    2 get 2 2array
    3 get 3 2array 2array 4 get instructions>> first (>>inputs)

    [ ] [ test-representations ] unit-test

    [ t ] [ 2 get instructions>> first ##load-double? ] unit-test

    [ t ] [ 3 get instructions>> first ##load-double? ] unit-test

    [ t ] [ 4 get instructions>> first ##phi? ] unit-test
] when