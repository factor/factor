USING: accessors arrays assocs combinators.extras compiler.cfg
compiler.cfg.instructions compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals compiler.cfg.utilities cpu.architecture
cpu.x86.assembler.operands heaps kernel layouts namespaces sequences system
tools.test ;
IN: compiler.cfg.linear-scan.allocation.state.tests

! active-intervals-for
{
    V{ T{ live-interval-state { reg-class int-regs } { vreg 123 } } }
} [
    f machine-registers init-allocator
    T{ live-interval-state { reg-class int-regs } { vreg 123 } }
    [ add-active ] keep active-intervals-for
] unit-test

! add-active
{
    {
        {
            int-regs
            V{
                T{ live-interval-state
                   { vreg 123 }
                   { reg-class int-regs }
                }
            }
        }
        { float-regs V{ } }
    }
} [
    f machine-registers init-allocator
    T{ live-interval-state { reg-class int-regs } { vreg 123 } } add-active
    active-intervals get
] unit-test

! add-use-position
cpu x86.64? [
    {
        {
            { XMM0 1/0. }
            { XMM1 25 }
            { XMM2 1/0. }
            { XMM3 1/0. }
            { XMM4 1/0. }
            { XMM5 1/0. }
            { XMM6 1/0. }
            { XMM7 1/0. }
            { XMM8 1/0. }
            { XMM9 1/0. }
            { XMM10 1/0. }
            { XMM11 1/0. }
            { XMM12 1/0. }
            { XMM13 1/0. }
            { XMM14 1/0. }
            { XMM15 1/0. }
        }
    } [
        25 XMM1 machine-registers float-regs free-positions
        [ add-use-position ] keep
    ] unit-test
] when

! add-use-position
{ { { "prutt" 12 } } } [
    30 "prutt" { { "prutt" 12 } } [ add-use-position ] keep
] unit-test

! assign-spill-slot
cpu x86.32?
H{
    { { 3 4 } T{ spill-slot { n 32 } } }
    { { 1234 4 } T{ spill-slot } }
    { { 45 16 } T{ spill-slot { n 16 } } }
}
H{
    { { 3 8 } T{ spill-slot { n 32 } } }
    { { 1234 8 } T{ spill-slot } }
    { { 45 16 } T{ spill-slot { n 16 } } }
} ? 1array
[
    H{ } clone spill-slots set
    f f <basic-block> <cfg> cfg set
    { 1234 45 3 } { int-rep double-2-rep tagged-rep }
    [ assign-spill-slot drop ] 2each
    spill-slots get
] unit-test

{ t } [
    H{ } clone spill-slots set
    f f <basic-block> <cfg> cfg set
    55 int-rep assign-spill-slot spill-slots get values first eq?
] unit-test

! check-handled
{ } [
    40 progress set
    T{ live-interval-state
       { end 34 }
       { reg-class int-regs }
       { vreg 123 }
    }
    check-handled
] unit-test

! align-spill-area
{ t } [
    3 f f { } 0 insns>block <cfg> [ align-spill-area ] keep
    spill-area-align>> cell =
] unit-test

! inactive-intervals-for
{
    V{ T{ live-interval-state { reg-class int-regs } { vreg 123 } } }
} [
    f machine-registers init-allocator
    T{ live-interval-state { reg-class int-regs } { vreg 123 } }
    [ add-inactive ] keep inactive-intervals-for
] unit-test

! interval/sync-point-key
{ { 33 1/0.0 1/0.0 } } [
    T{ sync-point { n 33 } } interval/sync-point-key
] unit-test

! next-spill-slot
{
    T{ spill-slot f 0 }
    T{ spill-slot f 8 }
    T{ cfg { spill-area-size 16 } }
} [
    H{ } clone spill-slots set
    T{ cfg { spill-area-size 0 } } cfg set
    [ 8 next-spill-slot ] twice
    cfg get
] unit-test

! >unhandled-min-heap
{
    {
        { { 5 1/0. 1/0. } T{ sync-point { n 5 } } }
        {
            { 20 28 f }
            T{ live-interval-state { start 20 } { end 28 } }
        }
        {
            { 20 30 f }
            T{ live-interval-state { start 20 } { end 30 } }
        }
        {
            { 33 999 f }
            T{ live-interval-state { start 33 } { end 999 } }
        }
        { { 33 1/0. 1/0. } T{ sync-point { n 33 } } }
        { { 100 1/0. 1/0. } T{ sync-point { n 100 } } }
    }
} [
    {
        T{ live-interval-state { start 20 } { end 30 } }
        T{ live-interval-state { start 20 } { end 28 } }
        T{ live-interval-state { start 33 } { end 999 } }
        T{ sync-point { n 5 } }
        T{ sync-point { n 33 } }
        T{ sync-point { n 100 } }
    }
    >unhandled-min-heap heap-pop-all
] unit-test

{ 2 } [
    {
        T{ live-interval-state { start 20 } { end 30 } }
        T{ live-interval-state { start 20 } { end 30 } }
    } >unhandled-min-heap heap-size
] unit-test
