USING: accessors arrays compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.allocation.state compiler.cfg.linear-scan.assignment
compiler.cfg.linear-scan.live-intervals compiler.cfg.registers
compiler.cfg.ssa.destruction.leaders compiler.cfg.utilities cpu.architecture
cpu.x86.assembler.operands grouping heaps kernel make namespaces random
sequences sorting tools.test ;
IN: compiler.cfg.linear-scan.assignment.tests

! assign-insn-defs
{
    T{ ##peek { dst RAX } { loc T{ ds-loc } } { insn# 0 } }
} [
    H{ { 37 RAX } } pending-interval-assoc set
    H{ { 37 int-rep } } representations set
    H{ { 37 37 } } leader-map set
    T{ ##peek f 37 D: 0 0 } [ assign-insn-defs ] keep
] unit-test

! assign-all-registers
{
    T{ ##replace-imm f 20 D: 0 f }
    T{ ##replace f RAX D: 0 f }
} [
    ! It doesn't do anything because ##replace-imm isn't a vreg-insn.
    T{ ##replace-imm { src 20 } { loc D: 0 } } [ assign-all-registers ] keep

    ! This one does something.
    H{ { 37 RAX } } pending-interval-assoc set
    H{ { 37 37 } } leader-map set
    T{ ##replace { src 37 } { loc D: 0 } } clone
    [ assign-all-registers ] keep
] unit-test

! assign-registers
{ } [
    V{ T{ ##inc { loc D: 3 } { insn# 7 } } } 0 insns>block block>cfg { }
    assign-registers
] unit-test

! assign-registers-in-block
{
    V{ T{ ##inc { loc T{ ds-loc { n 3 } } } { insn# 7 } } }
} [
    { } init-assignment
    V{ T{ ##inc { loc D: 3 } { insn# 7 } } } 0 insns>block
    [ assign-registers-in-block ] keep instructions>>
] unit-test

! insert-reload
{
    { T{ ##reload { dst RAX } { rep int-rep } { src T{ spill-slot } } } }
} [
    [
        T{ live-interval-state
           { reg RAX }
           { reload-from T{ spill-slot } }
           { reload-rep int-rep }
        } insert-reload
    ] { } make
] unit-test

! insert-spill
{ { T{ ##spill { src RAX } } } } [
    [
        T{ live-interval-state { vreg 1234 } { reg RAX } } insert-spill
    ] { } make
] unit-test

{ V{ T{ ##spill { src RAX } { rep int-rep } } } } [
    [
        1234 <live-interval>
        RAX >>reg int-rep >>spill-rep
        insert-spill
    ] V{ } make
] unit-test

: cherry-pick ( seq indices -- seq' )
    [ swap nth ] with map  ;

: (setup-vreg-spills) ( vreg-defs -- reps leaders spill-slots )
    [ [ 2 head ] map ]
    [ [ { 0 2 } cherry-pick ] map ]
    [
        [
            first4 [ nip [ rep-size 2array ] dip 2array ] [ 3drop f ] if*
        ] map sift
    ] tri ;

: setup-vreg-spills ( vreg-defs -- )
    (setup-vreg-spills)
    [ representations set ] [ leader-map set ] [ spill-slots set ] tri* ;

! vreg>spill-slot
{ T{ spill-slot { n 990 } } } [
    { { 10 int-rep 10 T{ spill-slot { n 990 } } } } setup-vreg-spills
    10 vreg>spill-slot
] unit-test

! vreg>reg
{ T{ spill-slot f 16 } } [
    { { 45 double-rep 45 T{ spill-slot { n 16 } } } } setup-vreg-spills
    45 vreg>reg
] unit-test

[
    ! It gets very strange if the leader of a vreg has a different
    ! sized representation than the vreg being led.
    { { 45 double-2-rep 45 T{ spill-slot { n 16 } } }
      { 46 double-rep 45 f } } setup-vreg-spills
    46 vreg>reg
] [ bad-vreg? ] must-fail-with

{ { 3 56 } } [
    { { 3 7 } { -1 56 } { -1 3 } } >min-heap [ -1 = ] heap-pop-while
    natural-sort
] unit-test

{ 3 } [
    90 { 50 90 95 120 } [ 25 <live-interval> 2array ] map >min-heap
    [ expire-old-intervals ] keep heap-size
] unit-test
