USING: accessors arrays compiler.cfg.instructions
compiler.cfg.linear-scan.assignment compiler.cfg.linear-scan.live-intervals
compiler.cfg.registers compiler.cfg.utilities cpu.architecture
cpu.x86.assembler.operands grouping heaps kernel make namespaces random
sequences sorting tools.test ;
IN: compiler.cfg.linear-scan.assignment.tests

{ { T{ ##spill { src RAX } } } } [
    [
        T{ live-interval-state { vreg 1234 } { reg RAX } } insert-spill
    ] { } make
] unit-test

{ } [
    { } init-assignment
    V{
        T{ ##inc { loc D 3 } { insn# 7 } }
    } 0 insns>block
    assign-registers-in-block
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
