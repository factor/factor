USING: accessors arrays compiler.cfg compiler.cfg.instructions compiler.cfg.comparisons
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.assignment
compiler.cfg.linear-scan.allocation.spilling compiler.cfg.linear-scan.numbering
compiler.cfg.linear-scan.resolve compiler.cfg.liveness
compiler.cfg.register-allocation.verifier
compiler.cfg.linear-scan.live-intervals compiler.cfg.registers
compiler.cfg.ssa.destruction.leaders compiler.cfg.utilities
cpu.architecture cpu.x86.assembler.operands heaps kernel locals make math
namespaces sequences sorting tools.test ;
IN: compiler.cfg.linear-scan.assignment.tests

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

! activate-new-intervals
{
    {
        T{ ##reload
           { dst RBX }
           { rep tagged-rep }
           { src T{ spill-slot } }
        }
    }
} [
    ! Setup
    H{ } clone pending-interval-assoc set
    <min-heap> pending-interval-heap set
    30 {
        T{ live-interval-state
           { vreg 789 }
           { reg RBX }
           { reload-from T{ spill-slot } }
           { reload-rep tagged-rep }
           { ranges V{ { 30 30  } } }
           { uses
             V{ T{ vreg-use { n 26 } { use-rep tagged-rep } } }
           }
        }
    } live-intervals>min-heap [ activate-new-intervals ] { } make
] unit-test

! assign-insn-defs
{
    T{ ##peek { dst RAX } { loc T{ ds-loc } } { insn# 0 } }
} [
    H{ { 37 RAX } } pending-interval-assoc set
    { { 37 int-rep 37 f } } setup-vreg-spills
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

! expire-old-intervals
{ 3 H{ } } [
    H{ { 25 RBX } } clone pending-interval-assoc set
    90 { 50 90 95 120 } [ 25 <live-interval> 2array ] map >min-heap
    [ expire-old-intervals ] keep heap-size
    pending-interval-assoc get
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

! spill/reloads-for-call-gc

! The interval should be spilled around the gc instruction at 128. And
! it's spill representation should be int-rep because on instruction
! 102 it was converted from a tagged-rep to an int-rep.
: test-call-gc ( -- ##call-gc )
    T{ gc-map { gc-roots { 149 109 110 } } { derived-roots V{ } } } 128
    ##call-gc boa ;

: test-interval ( -- live-interval )
    T{ live-interval-state
       { vreg 235 }
       { reg RDI }
       { ranges V{ { 88 94 } { 100 154 } } }
       { uses
         V{
             T{ vreg-use
                { n 88 }
                { def-rep tagged-rep }
              }
             T{ vreg-use
                { n 90 }
                { def-rep int-rep }
                { use-rep tagged-rep }
              }
             T{ vreg-use
                { n 100 }
                { def-rep tagged-rep }
              }
             T{ vreg-use
                { n 102 }
                { def-rep int-rep }
                { use-rep tagged-rep }
              }
             T{ vreg-use { n 144 } { use-rep int-rep } }
             T{ vreg-use { n 146 } { use-rep int-rep } }
             T{ vreg-use
                { n 148 }
                { def-rep int-rep }
                { use-rep int-rep }
              }
             T{ vreg-use
                { n 150 }
                { def-rep tagged-rep }
                { use-rep int-rep }
              }
             T{ vreg-use
                { n 154 }
                { use-rep tagged-rep }
              }
         } }
    } ;

{
    V{ { RDI int-rep T{ spill-slot } } }
} [
    f f <basic-block> <cfg> cfg set
    H{ } clone spill-slots set
    H{ } clone pending-interval-assoc set
    <min-heap> pending-interval-heap set
    H{ { 235 float-rep } } representations set
    test-interval add-pending
    test-call-gc spill/reloads-for-call-gc
] unit-test

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

! vregs>regs
{ { { 33 RAX } { 44 RBX } } } [
    { { 33 int-rep 33 f } { 44 int-rep 44 f } } setup-vreg-spills
    H{ { 33 RAX } { 44 RBX } } pending-interval-assoc set
    { { 33 33 } { 44 44 } } vregs>regs
] unit-test


{ { 3 56 } } [
    { { 3 7 } { -1 56 } { -1 3 } } >min-heap [ -1 = ] heap-pop-while
    sort
] unit-test

! The old product expires before its successor activates, even if the
! physical register is identical. Boundary stores are left to the resolver;
! a bypass into the destination must not execute the old product's store.
{ t t t t } [
    {
        T{ live-interval-state
            { vreg 37 } { reg RAX }
            { ranges V{ { 0 3 } } }
            { spill-to T{ spill-slot { n 0 } } } { spill-rep int-rep }
            { uses V{ T{ vreg-use { n 2 } { use-rep int-rep } } } }
        }
        T{ live-interval-state
            { vreg 37 } { reg RAX }
            { ranges V{ { 3 6 } } }
            { uses V{ T{ vreg-use { n 4 } { use-rep int-rep } } } }
        }
    } [ clone ] map init-assignment
    H{ { 37 37 } } leader-map set
    H{ { 37 int-rep } } representations set
    V{ T{ ##peek { dst 37 } { loc D: 0 } { insn# 0 } }
        T{ ##compare-integer-imm-branch { src1 37 } { src2 0 } { cc cc= } { insn# 2 } } }
    [ clone ] map 0 insns>block
    [ assign-registers-in-block ] keep
    V{ T{ ##replace { src 37 } { loc D: 0 } { insn# 4 } }
        T{ ##branch { insn# 6 } } }
    [ clone ] map 1 insns>block
    [ assign-registers-in-block ] keep swap
    [ instructions>> dup first src>> RAX = swap [ ##spill? ] any? not ]
    [ instructions>> dup last ##compare-integer-imm-branch? swap [ ##spill? ] any? not ] bi*
] unit-test

! Overflowing arithmetic defines its output in a terminator. Its store must
! run on outgoing edges after that definition, never before the instruction.
:: defining-terminator-fixture ( -- cfg snapshot source )
    H{ { 1 tagged-rep } { 2 tagged-rep } { 3 tagged-rep } } representations set
    H{ { 1 1 } { 2 2 } { 3 3 } } leader-map set
    H{ } clone spill-slots set
    V{ T{ ##load-integer { dst 1 } { val 16 } }
        T{ ##load-integer { dst 2 } { val 32 } }
        T{ ##fixnum-add { dst 3 } { src1 1 } { src2 2 } { cc cc/o } } }
    [ clone ] map 0 insns>block :> source
    V{ T{ ##replace { src 3 } { loc D: 0 } } T{ ##return } }
    [ clone ] map 1 insns>block :> left
    V{ T{ ##replace { src 3 } { loc D: 0 } } T{ ##return } }
    [ clone ] map 2 insns>block :> right
    source left connect-bbs source right connect-bbs
    source block>cfg :> graph
    graph cfg set
    graph snapshot-value-flow :> snapshot
    graph compute-live-sets graph number-instructions
    graph compute-live-intervals :> original
    original [ vreg>> 3 = ] partition :> ( outputs inputs )
    outputs first :> output
    [
        output source block-to 1 + split-for-spill :> ( definition uses )
        uses uses uses>> second n>> 1 - split-for-spill :> ( use1 use2 )
        definition RCX >>reg drop use1 RDX >>reg drop use2 RDX >>reg drop
        inputs [ dup vreg>> 1 = [ RAX ] [ RBX ] if >>reg ] map
        definition use1 use2 3array append :> allocated
        graph allocated assign-registers graph resolve-data-flow
    ] call
    graph snapshot source ;

{ t t } [
    defining-terminator-fixture [ check-value-flow ] dip
    [ instructions>> [ ##spill? ] any? not ]
    [ successors>> [ instructions>> first ##spill? ] all? ] bi
] unit-test
