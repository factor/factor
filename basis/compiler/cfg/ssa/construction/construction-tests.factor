USING: accessors assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.ssa.construction
compiler.cfg.ssa.construction.private compiler.cfg.utilities
compiler.test kernel namespaces sequences tools.test ;
IN: compiler.cfg.ssa.construction.tests

! insert-phi-later
{
    { V{ T{ ##phi { dst 789 } { inputs H{ } } } } }
} [
    H{ } clone inserting-phis set
    789 { } 0 insns>block insert-phi-later
    inserting-phis get values
] unit-test

{ 99 55 } [
    H{ } clone inserting-phis set
    { } 55 insns>block { } 1 insns>block [ connect-bbs ] keep
    99 swap insert-phi-later
    inserting-phis get values first first
    [ dst>> ] [ inputs>> keys first number>> ] bi
] unit-test

! live-phi?
{ f t } [
    HS{ 68 } live-phis set
    T{ ##phi } live-phi?
    T{ ##phi { dst 68 } }  live-phi?
] unit-test


: reset-counters ( -- )
    ! Reset counters so that results are deterministic w.r.t. hash order
    reset-vreg-counter 0 basic-block set-global ;

: test-ssa ( -- )
    0 get block>cfg
    dup cfg set
    construct-ssa ;

: clean-up-phis ( insns -- insns' )
    [ dup ##phi? [ [ [ [ number>> ] dip ] assoc-map ] change-inputs ] when ] map ;

! Test 1
reset-counters

V{
    T{ ##load-integer f 1 100 }
    T{ ##add-imm f 2 1 50 }
    T{ ##add-imm f 2 2 10 }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##load-integer f 3 3 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##load-integer f 3 4 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##replace f 3 D: 0 }
    T{ ##return }
} 3 test-bb

0 { 1 2 } edges
1 3 edge
2 3 edge

{ } [ test-ssa ] unit-test

{
    V{
        T{ ##load-integer f 1 100 }
        T{ ##add-imm f 2 1 50 }
        T{ ##add-imm f 3 2 10 }
        T{ ##branch }
    }
} [ 0 get instructions>> ] unit-test

{
    V{
        T{ ##load-integer f 4 3 }
        T{ ##branch }
    }
} [ 1 get instructions>> ] unit-test

{
    V{
        T{ ##load-integer f 5 4 }
        T{ ##branch }
    }
} [ 2 get instructions>> ] unit-test

{
    V{
        T{ ##phi f 6 H{ { 1 4 } { 2 5 } } }
        T{ ##replace f 6 D: 0 }
        T{ ##return }
    }
} [
    3 get instructions>>
    clean-up-phis
] unit-test

! Test 2
reset-counters

V{ } 0 test-bb
V{ } 1 test-bb
V{ T{ ##peek f 0 D: 0 } } 2 test-bb
V{ T{ ##peek f 0 D: 0 } } 3 test-bb
V{ T{ ##replace f 0 D: 0 } } 4 test-bb
V{ } 5 test-bb
V{ } 6 test-bb

0 { 1 5 } edges
1 { 2 3 } edges
2 4 edge
3 4 edge
4 6 edge
5 6 edge

{ } [ test-ssa ] unit-test

{
    V{
        T{ ##phi f 3 H{ { 2 1 } { 3 2 } } }
        T{ ##replace f 3 D: 0 }
    }
} [
    4 get instructions>>
    clean-up-phis
] unit-test

! Test 3
reset-counters

V{
    T{ ##branch }
} 0 test-bb

V{
    T{ ##load-integer f 3 3 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##load-integer f 3 4 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##branch }
} 3 test-bb

V{
    T{ ##return }
} 4 test-bb

0 { 1 2 3 } edges
1 4 edge
2 4 edge
3 4 edge

{ } [ test-ssa ] unit-test

{ V{ } } [ 4 get instructions>> [ ##phi? ] filter ] unit-test

! Test 4
reset-counters

V{
    T{ ##branch }
} 0 test-bb

V{
    T{ ##branch }
} 1 test-bb

V{
    T{ ##load-integer f 0 4 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##load-integer f 0 4 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##branch }
} 4 test-bb

V{
    T{ ##branch }
} 5 test-bb

V{
    T{ ##branch }
} 6 test-bb

V{
    T{ ##return }
} 7 test-bb

0 { 1 6 } edges
1 { 2 3 4 } edges
2 5 edge
3 5 edge
4 5 edge
5 7 edge
6 7 edge

{ } [ test-ssa ] unit-test

{ V{ } } [ 5 get instructions>> [ ##phi? ] filter ] unit-test

{ V{ } } [ 7 get instructions>> [ ##phi? ] filter ] unit-test
