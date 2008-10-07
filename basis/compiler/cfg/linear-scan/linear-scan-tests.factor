IN: compiler.cfg.linear-scan.tests
USING: tools.test random sorting sequences sets hashtables assocs
kernel fry arrays splitting namespaces math accessors vectors
math.order
compiler.cfg.registers
compiler.cfg.linear-scan
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.debugger ;

[ ] [
    {
        T{ live-interval { vreg T{ vreg { n 1 } } } { start 0 } { end 100 } { uses V{ 100 } } }
    }
    H{ { f { "A" } } }
    check-linear-scan
] unit-test

[ ] [
    {
        T{ live-interval { vreg T{ vreg { n 1 } } } { start 0 } { end 10 } { uses V{ 10 } } }
        T{ live-interval { vreg T{ vreg { n 2 } } } { start 11 } { end 20 } { uses V{ 20 } } }
    }
    H{ { f { "A" } } }
    check-linear-scan
] unit-test

[ ] [
    {
        T{ live-interval { vreg T{ vreg { n 1 } } } { start 0 } { end 100 } { uses V{ 100 } } }
        T{ live-interval { vreg T{ vreg { n 2 } } } { start 30 } { end 60 } { uses V{ 60 } } }
    }
    H{ { f { "A" } } }
    check-linear-scan
] unit-test

[ ] [
    {
        T{ live-interval { vreg T{ vreg { n 1 } } } { start 0 } { end 100 } { uses V{ 100 } } }
        T{ live-interval { vreg T{ vreg { n 2 } } } { start 30 } { end 200 } { uses V{ 200 } } }
    }
    H{ { f { "A" } } }
    check-linear-scan
] unit-test

[
    {
        T{ live-interval { vreg T{ vreg { n 1 } } } { start 0 } { end 100 } { uses V{ 100 } } }
        T{ live-interval { vreg T{ vreg { n 2 } } } { start 30 } { end 100 } { uses V{ 100 } } }
    }
    H{ { f { "A" } } }
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
                swap f swap vreg boa >>vreg
                max-uses get random 2 max [ not-taken ] replicate natural-sort
                unclip [ >vector >>uses ] [ >>start ] bi*
                dup uses>> first >>end
        ] map
    ] with-scope ;

: random-test ( num-intervals max-uses max-registers max-insns -- )
    over >r random-live-intervals r> f associate check-linear-scan ;

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
