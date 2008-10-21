IN: compiler.cfg.linear-scan.tests
USING: tools.test random sorting sequences sets hashtables assocs
kernel fry arrays splitting namespaces math accessors vectors
math.order
cpu.architecture
compiler.cfg.instructions
compiler.cfg.registers
compiler.cfg.linear-scan
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.debugger ;

[ 7 ] [
    T{ live-interval
        { vreg T{ vreg { reg-class int-regs } { n 2 } } }
        { start 0 }
        { end 10 }
        { uses V{ 0 1 3 7 10 } }
    }
    4 [ >= ] find-use nip
] unit-test

[ 4 ] [
    T{ live-interval
        { vreg T{ vreg { reg-class int-regs } { n 2 } } }
        { start 0 }
        { end 10 }
        { uses V{ 0 1 3 4 10 } }
    }
    4 [ >= ] find-use nip
] unit-test

[ f ] [
    T{ live-interval
        { vreg T{ vreg { reg-class int-regs } { n 2 } } }
        { start 0 }
        { end 10 }
        { uses V{ 0 1 3 4 10 } }
    }
    100 [ >= ] find-use nip
] unit-test

[
    T{ live-interval
        { vreg T{ vreg { reg-class int-regs } { n 1 } } }
        { start 0 }
        { end 1 }
        { uses V{ 0 1 } }
    }
    T{ live-interval
        { vreg T{ vreg { reg-class int-regs } { n 1 } } }
        { start 5 }
        { end 5 }
        { uses V{ 5 } }
    }
] [
    T{ live-interval
        { vreg T{ vreg { reg-class int-regs } { n 1 } } }
        { start 0 }
        { end 5 }
        { uses V{ 0 1 5 } }
    } 2 split-interval
] unit-test

[
    T{ live-interval
        { vreg T{ vreg { reg-class int-regs } { n 1 } } }
        { start 0 }
        { end 0 }
        { uses V{ 0 } }
    }
    T{ live-interval
        { vreg T{ vreg { reg-class int-regs } { n 1 } } }
        { start 1 }
        { end 5 }
        { uses V{ 1 5 } }
    }
] [
    T{ live-interval
        { vreg T{ vreg { reg-class int-regs } { n 1 } } }
        { start 0 }
        { end 5 }
        { uses V{ 0 1 5 } }
    } 0 split-interval
] unit-test

[
    T{ live-interval
        { vreg T{ vreg { reg-class int-regs } { n 1 } } }
        { start 3 }
        { end 10 }
        { uses V{ 3 10 } }
    }
] [
    {
        T{ live-interval
            { vreg T{ vreg { reg-class int-regs } { n 1 } } }
            { start 1 }
            { end 15 }
            { uses V{ 1 3 7 10 15 } }
        }
        T{ live-interval
            { vreg T{ vreg { reg-class int-regs } { n 1 } } }
            { start 3 }
            { end 8 }
            { uses V{ 3 4 8 } }
        }
        T{ live-interval
            { vreg T{ vreg { reg-class int-regs } { n 1 } } }
            { start 3 }
            { end 10 }
            { uses V{ 3 10 } }
        }
    }
    T{ live-interval
        { vreg T{ vreg { reg-class int-regs } { n 1 } } }
        { start 5 }
        { end 5 }
        { uses V{ 5 } }
    }
    interval-to-spill
] unit-test

[ t ] [
    T{ live-interval
        { vreg T{ vreg { reg-class int-regs } { n 1 } } }
        { start 5 }
        { end 15 }
        { uses V{ 5 10 15 } }
    }
    T{ live-interval
        { vreg T{ vreg { reg-class int-regs } { n 1 } } }
        { start 1 }
        { end 20 }
        { uses V{ 1 20 } }
    }
    spill-existing?
] unit-test

[ f ] [
    T{ live-interval
        { vreg T{ vreg { reg-class int-regs } { n 1 } } }
        { start 5 }
        { end 15 }
        { uses V{ 5 10 15 } }
    }
    T{ live-interval
        { vreg T{ vreg { reg-class int-regs } { n 1 } } }
        { start 1 }
        { end 20 }
        { uses V{ 1 7 20 } }
    }
    spill-existing?
] unit-test

[ t ] [
    T{ live-interval
        { vreg T{ vreg { reg-class int-regs } { n 1 } } }
        { start 5 }
        { end 5 }
        { uses V{ 5 } }
    }
    T{ live-interval
        { vreg T{ vreg { reg-class int-regs } { n 1 } } }
        { start 1 }
        { end 20 }
        { uses V{ 1 7 20 } }
    }
    spill-existing?
] unit-test

[ ] [
    {
        T{ live-interval { vreg T{ vreg { n 1 } { reg-class int-regs } } } { start 0 } { end 100 } { uses V{ 0 100 } } }
    }
    H{ { int-regs { "A" } } }
    check-linear-scan
] unit-test

[ ] [
    {
        T{ live-interval { vreg T{ vreg { n 1 } { reg-class int-regs } } } { start 0 } { end 10 } { uses V{ 0 10 } } }
        T{ live-interval { vreg T{ vreg { n 2 } { reg-class int-regs } } } { start 11 } { end 20 } { uses V{ 11 20 } } }
    }
    H{ { int-regs { "A" } } }
    check-linear-scan
] unit-test

[ ] [
    {
        T{ live-interval { vreg T{ vreg { n 1 } { reg-class int-regs } } } { start 0 } { end 100 } { uses V{ 0 100 } } }
        T{ live-interval { vreg T{ vreg { n 2 } { reg-class int-regs } } } { start 30 } { end 60 } { uses V{ 30 60 } } }
    }
    H{ { int-regs { "A" } } }
    check-linear-scan
] unit-test

[ ] [
    {
        T{ live-interval { vreg T{ vreg { n 1 } { reg-class int-regs } } } { start 0 } { end 100 } { uses V{ 0 100 } } }
        T{ live-interval { vreg T{ vreg { n 2 } { reg-class int-regs } } } { start 30 } { end 200 } { uses V{ 30 200 } } }
    }
    H{ { int-regs { "A" } } }
    check-linear-scan
] unit-test

[
    {
        T{ live-interval { vreg T{ vreg { n 1 } { reg-class int-regs } } } { start 0 } { end 100 } { uses V{ 0 100 } } }
        T{ live-interval { vreg T{ vreg { n 2 } { reg-class int-regs } } } { start 30 } { end 100 } { uses V{ 30 100 } } }
    }
    H{ { int-regs { "A" } } }
    check-linear-scan
] must-fail

SYMBOL: available

SYMBOL: taken

SYMBOL: max-registers

SYMBOL: max-insns

SYMBOL: max-uses

: not-taken ( -- n )
    available get keys dup empty? [ "Oops" throw ] when
    random
    dup taken get nth 1 + max-registers get = [
        dup available get delete-at
    ] [
        dup taken get [ 1 + ] change-nth
    ] if ;

: random-live-intervals ( num-intervals max-uses max-registers max-insns -- seq )
    [
        max-insns set
        max-registers set
        max-uses set
        max-insns get [ 0 ] replicate taken set
        max-insns get [ dup ] H{ } map>assoc available set
        [
            live-interval new
                swap int-regs swap vreg boa >>vreg
                max-uses get random 2 max [ not-taken ] replicate natural-sort
                [ >>uses ] [ first >>start ] bi
                dup uses>> peek >>end
        ] map
    ] with-scope ;

: random-test ( num-intervals max-uses max-registers max-insns -- )
    over >r random-live-intervals r> int-regs associate check-linear-scan ;

[ ] [ 30 2 1 60 random-test ] unit-test
[ ] [ 60 2 2 60 random-test ] unit-test
[ ] [ 80 2 3 200 random-test ] unit-test
[ ] [ 70 2 5 30 random-test ] unit-test
[ ] [ 60 2 6 30 random-test ] unit-test
[ ] [ 1 2 10 10 random-test ] unit-test

[ ] [ 10 4 2 60 random-test ] unit-test
[ ] [ 10 20 2 400 random-test ] unit-test
[ ] [ 10 20 4 300 random-test ] unit-test

USING: math.private compiler.cfg.debugger ;

[ ] [ [ float+ float>fixnum 3 fixnum*fast ] test-mr first linear-scan drop ] unit-test

[ f ] [
    T{ ##allot
        f
        T{ vreg f int-regs 1 }
        40
        array
        T{ vreg f int-regs 2 }
        f
    } clone
    1array (linear-scan) first regs>> values all-equal?
] unit-test

[ 0 1 ] [
    {
        T{ live-interval
            { vreg T{ vreg { reg-class int-regs } { n 1 } } }
            { start 0 }
            { end 5 }
            { uses V{ 0 1 5 } }
        }
        T{ live-interval
            { vreg T{ vreg { reg-class int-regs } { n 2 } } }
            { start 3 }
            { end 4 }
            { uses V{ 3 4 } }
        }
        T{ live-interval
            { vreg T{ vreg { reg-class int-regs } { n 3 } } }
            { start 2 }
            { end 6 }
            { uses V{ 2 4 6 } }
        }
    } [ clone ] map
    H{ { int-regs { "A" "B" } } }
    allocate-registers
    first split-before>> [ start>> ] [ end>> ] bi
] unit-test
