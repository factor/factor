USING: accessors arrays assocs combinators.extras compiler.cfg
compiler.cfg.instructions compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals compiler.cfg.utilities cpu.architecture
cpu.x86.assembler.operands heaps kernel layouts namespaces sequences system
tools.test ;
IN: compiler.cfg.linear-scan.allocation.state.tests

! active-intervals-for
{
    V{ T{ live-interval-state { reg-class int-regs } { vreg 123 } } }
} [
    f f machine-registers init-allocator
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
    f f machine-registers init-allocator
    T{ live-interval-state { reg-class int-regs } { vreg 123 } } add-active
    active-intervals get
] unit-test

! add-use-position
cpu x86.64? [
    {
        H{
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
            { XMM11 1/0. }
            { XMM10 1/0. }
            { XMM13 1/0. }
            { XMM12 1/0. }
            { XMM15 1/0. }
            { XMM14 1/0. }
        }
    } [
        25 XMM1 machine-registers float-regs free-positions
        [ add-use-position ] keep
    ] unit-test
] when

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

! free-positions
cpu x86.64? [
    {
        H{
            { RCX 1/0. }
            { RBX 1/0. }
            { RAX 1/0. }
            { R12 1/0. }
            { RDI 1/0. }
            { R10 1/0. }
            { RSI 1/0. }
            { R11 1/0. }
            { R8 1/0. }
            { R9 1/0. }
            { RDX 1/0. }
            { RBP 1/0. }
        }
    } [
        machine-registers int-regs free-positions
    ] unit-test
] when

! align-spill-area
{ t } [
    3 f f { } 0 insns>block <cfg> [ align-spill-area ] keep
    spill-area-align>> cell =
] unit-test

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

{ { 33 1/0.0 } } [
    T{ sync-point { n 33 } } sync-point-key
] unit-test

{
    {
        { { 5 1/0. } T{ sync-point { n 5 } } }
        {
            { 20 28 }
            T{ live-interval-state { start 20 } { end 28 } }
        }
        {
            { 20 30 }
            T{ live-interval-state { start 20 } { end 30 } }
        }
        {
            { 33 999 }
            T{ live-interval-state { start 33 } { end 999 } }
        }
        { { 33 1/0. } T{ sync-point { n 33 } } }
        { { 100 1/0. } T{ sync-point { n 100 } } }
    }
} [
    {
        T{ live-interval-state { start 20 } { end 30 } }
        T{ live-interval-state { start 20 } { end 28 } }
        T{ live-interval-state { start 33 } { end 999 } }
    }
    {
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
    } { } >unhandled-min-heap heap-size
] unit-test
