USING: accessors arrays compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.assignment compiler.cfg.linear-scan.live-intervals
compiler.cfg.registers compiler.cfg.ssa.destruction.leaders
compiler.cfg.utilities cpu.architecture cpu.x86.assembler.operands grouping
heaps kernel make namespaces random sequences sorting tools.test ;
IN: compiler.cfg.linear-scan.assignment.tests

{
    T{ ##peek { dst RAX } { loc T{ ds-loc } } { insn# 0 } }
} [
    H{ { 37 RAX } } pending-interval-assoc set
    H{ { 37 int-rep } } representations set
    H{ { 37 37 } } leader-map set
    T{ ##peek f 37 D 0 0 } [ assign-insn-defs ] keep
] unit-test

! assign-registers-in-block
{
    V{ T{ ##inc { loc T{ ds-loc { n 3 } } } { insn# 7 } } }
} [
    { } init-assignment
    V{ T{ ##inc { loc D 3 } { insn# 7 } } } 0 insns>block
    [ assign-registers-in-block ] keep instructions>>
] unit-test

! insert-spill
{ { T{ ##spill { src RAX } } } } [
    [
        T{ live-interval-state { vreg 1234 } { reg RAX } } insert-spill
    ] { } make
] unit-test

{ V{ T{ ##spill { src RAX } { rep int-rep } } } } [
    [
        1234 int-regs <live-interval>
        RAX >>reg int-rep >>spill-rep
        insert-spill
    ] V{ } make
] unit-test

{ { 3 56 } } [
    { { 3 7 } { -1 56 } { -1 3 } } >min-heap [ -1 = ] heap-pop-while
    natural-sort
] unit-test

{ 3 } [
    { 50 90 95 120 } [ 25 int-regs <live-interval> 2array ] map >min-heap
    pending-interval-heap set 90 expire-old-intervals
    pending-interval-heap get heap-size
] unit-test

{ } [
    V{ T{ ##inc { loc D 3 } { insn# 7 } } } 0 insns>block block>cfg { }
    assign-registers
] unit-test
