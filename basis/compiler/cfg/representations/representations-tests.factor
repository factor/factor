USING: accessors compiler.cfg compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.representations.preferred cpu.architecture kernel
namespaces tools.test sequences arrays system literals layouts
math ;
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

! Converting a ##load-integer into a ##load-tagged
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##load-integer f 1 100 }
    T{ ##replace f 1 D 0 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 2 test-bb

0 1 edge
1 2 edge

[ ] [ test-representations ] unit-test

[ T{ ##load-tagged f 1 $[ 100 tag-fixnum ] } ]
[ 1 get instructions>> first ]
unit-test

! scalar-rep => int-rep conversion
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f 1 D 0 }
    T{ ##peek f 2 D 0 }
    T{ ##vector>scalar f 3 2 int-4-rep }
    T{ ##shl f 4 1 3 }
    T{ ##replace f 4 D 0 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 2 test-bb

0 1 edge
1 2 edge

[ ] [ test-representations ] unit-test

[ t ] [ 1 get instructions>> 4 swap nth ##scalar>integer? ] unit-test

cpu x86.32? [

    ! Make sure load-constant is converted into load-double
    V{
        T{ ##prologue }
        T{ ##branch }
    } 0 test-bb

    V{
        T{ ##peek f 1 D 0 }
        T{ ##load-reference f 2 0.5 }
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
        T{ ##load-reference f 2 1.5 }
        T{ ##branch }
    } 2 test-bb

    V{
        T{ ##load-reference f 3 2.5 }
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

! Peephole optimization if input to ##shl-imm is tagged

3 \ vreg-counter set-global

V{
    T{ ##peek f 1 D 0 }
    T{ ##shl-imm f 2 1 3 }
    T{ ##replace f 2 D 0 }
} 0 test-bb

[ ] [ test-representations ] unit-test

[
    V{
        T{ ##peek f 1 D 0 }
        T{ ##sar-imm f 2 1 1 }
        T{ ##shl-imm f 4 2 $[ tag-bits get ] }
        T{ ##replace f 4 D 0 }
    }
] [ 0 get instructions>> ] unit-test

V{
    T{ ##peek f 1 D 0 }
    T{ ##shl-imm f 2 1 10 }
    T{ ##replace f 2 D 0 }
} 0 test-bb

[ ] [ test-representations ] unit-test

[
    V{
        T{ ##peek f 1 D 0 }
        T{ ##shl-imm f 2 1 $[ 10 tag-bits get - ] }
        T{ ##shl-imm f 5 2 $[ tag-bits get ] }
        T{ ##replace f 5 D 0 }
    }
] [ 0 get instructions>> ] unit-test

V{
    T{ ##peek f 1 D 0 }
    T{ ##shl-imm f 2 1 $[ tag-bits get ] }
    T{ ##replace f 2 D 0 }
} 0 test-bb

[ ] [ test-representations ] unit-test

[
    V{
        T{ ##peek f 1 D 0 }
        T{ ##copy f 2 1 int-rep }
        T{ ##shl-imm f 6 2 $[ tag-bits get ] }
        T{ ##replace f 6 D 0 }
    }
] [ 0 get instructions>> ] unit-test

! Peephole optimization if input to ##sar-imm is tagged
V{
    T{ ##peek f 1 D 0 }
    T{ ##sar-imm f 2 1 3 }
    T{ ##replace f 2 D 0 }
} 0 test-bb

[ ] [ test-representations ] unit-test

[
    V{
        T{ ##peek f 1 D 0 }
        T{ ##sar-imm f 2 1 $[ 3 tag-bits get + ] }
        T{ ##shl-imm f 7 2 $[ tag-bits get ] }
        T{ ##replace f 7 D 0 }
    }
] [ 0 get instructions>> ] unit-test