USING: accessors assocs combinators.extras compiler.cfg
compiler.cfg.instructions compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals compiler.cfg.registers
compiler.cfg.stack-frame compiler.cfg.utilities cpu.architecture
cpu.x86.assembler.operands fry heaps kernel layouts literals
namespaces sequences system tools.test ;
IN: compiler.cfg.linear-scan.allocation.state.tests

! active-intervals-for
{
    V{ T{ live-interval-state { vreg 123 } } }
} [
    f machine-registers init-allocator
    H{ { 123 int-rep } } representations set
    T{ live-interval-state { vreg 123 } }
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
                }
            }
        }
        { float-regs V{ } }
    }
} [
    f machine-registers init-allocator
    H{ { 123 int-rep } } representations set
    T{ live-interval-state { vreg 123 } } add-active
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
${
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
    } ?
} [
    H{ } clone spill-slots set
    f f <basic-block> <cfg> cfg set
    { 1234 45 3 } { int-rep double-2-rep tagged-rep }
    [ assign-spill-slot drop ] 2each
    spill-slots get
] unit-test

{ t } [
    H{ } clone spill-slots set
    { } insns>cfg cfg set
    55 int-rep assign-spill-slot spill-slots get values first eq?
] unit-test

{
    H{
        { { 55 $[ cell ] } T{ spill-slot } }
        { { 44 $[ cell ] } T{ spill-slot { n $[ cell ] } } }
    }
} [
    H{ } clone spill-slots set
    { } insns>cfg cfg set
    { { 55 int-rep } { 44 int-rep } { 55 int-rep } } [
        assign-spill-slot drop
    ] assoc-each
    spill-slots get
] unit-test

! check-handled
{ } [
    40 progress set
    T{ live-interval-state
       { vreg 123 }
       { ranges V{ { 0 0 } { 30 34 } } }
    }
    check-handled
] unit-test

! align-spill-area
${ cell } [
    3 { } insns>cfg stack-frame>> [ align-spill-area ] keep
    spill-area-align>>
] unit-test

! inactive-intervals-for
{
    V{ T{ live-interval-state { vreg 123 } } }
} [
    f machine-registers init-allocator
    H{ { 123 int-rep } } representations set
    T{ live-interval-state { vreg 123 } }
    [ add-inactive ] keep inactive-intervals-for
] unit-test

! interval/sync-point-key
{ { 33 1/0. 1/0. } } [
    T{ sync-point { n 33 } } interval/sync-point-key
] unit-test

{ { 0 34 123 } } [
    T{ live-interval-state
       { vreg 123 }
       { ranges V{ { 0 0 } { 30 34 } } }
    } interval/sync-point-key
] unit-test

! next-spill-slot
{
    T{ spill-slot f 0 }
    T{ spill-slot f 8 }
    T{ stack-frame
       { spill-area-size 16 }
       { spill-area-align $[ cell ] }
    }
} [
    { } insns>cfg stack-frame>> [ '[ 8 _ next-spill-slot ] twice ] keep
] unit-test

! >unhandled-min-heap
{
    {
        { { 5 1/0. 1/0. } T{ sync-point { n 5 } } }
        {
            { 20 28 f }
            T{ live-interval-state { ranges V{ { 20 28 } } } }
        }
        {
            { 20 30 f }
            T{ live-interval-state { ranges V{ { 20 30 } } } }
        }
        {
            { 33 999 f }
            T{ live-interval-state { ranges V{ { 33 999 } } } }
        }
        { { 33 1/0. 1/0. } T{ sync-point { n 33 } } }
        { { 100 1/0. 1/0. } T{ sync-point { n 100 } } }
    }
} [
    {
        T{ live-interval-state { ranges V{ { 20 30 } } } }
        T{ live-interval-state { ranges V{ { 20 28 } } } }
        T{ live-interval-state { ranges V{ { 33 999 } } } }
        T{ sync-point { n 5 } }
        T{ sync-point { n 33 } }
        T{ sync-point { n 100 } }
    }
    >unhandled-min-heap heap-pop-all
] unit-test

{ 2 } [
    {
        T{ live-interval-state { ranges V{ { 20 30 } } } }
        T{ live-interval-state { ranges V{ { 20 30 } } } }
    } >unhandled-min-heap heap-size
] unit-test
