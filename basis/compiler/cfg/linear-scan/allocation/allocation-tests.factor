USING: accessors compiler.cfg compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals compiler.cfg.linear-scan.ranges
compiler.cfg.registers cpu.architecture cpu.x86.assembler.operands heaps kernel
namespaces system tools.test ;
IN: compiler.cfg.linear-scan.allocation.tests

: interval-[30,46] ( -- live-interval )
    T{ live-interval-state
       { vreg 49 }
       { ranges V{ { 30 46 } } }
       { uses
         V{
             T{ vreg-use { n 30 } { def-rep double-rep } }
             T{ vreg-use { n 46 } { use-rep double-rep } }
         }
       }
    } clone ;

: interval-[30,60] ( -- live-interval )
    T{ live-interval-state
       { vreg 25 }
       { ranges V{ { 30 60 } } }
       { reg RAX }
    } ;

cpu x86.64? [
    ! assign-registers
    { RAX } [
        H{ { 49 int-rep } } representations set
        f machine-registers init-allocator
        interval-[30,46] dup machine-registers assign-register reg>>
    ] unit-test

    ! register-status
    { { RAX 1/0. } } [
        f machine-registers init-allocator
        interval-[30,46] machine-registers register-status
    ] unit-test

    { { RBX 1/0. } } [
        f machine-registers init-allocator
        H{ { 25 int-rep } { 49 int-rep } } representations set
        interval-[30,60] add-active
        interval-[30,46] machine-registers register-status
    ] unit-test

    ! free-positions
    {
        {
            { RAX 1/0. }
            { RBX 1/0. }
            { RCX 1/0. }
            { RDX 1/0. }
            { RBP 1/0. }
            { RSI 1/0. }
            { RDI 1/0. }
            { R8 1/0. }
            { R9 1/0. }
            { R10 1/0. }
            { R11 1/0. }
            { R12 1/0. }
        }
    } [
        machine-registers int-regs free-positions
    ] unit-test
] when

! handle-sync-point
{ } [
    T{ sync-point { n 30 } } { } handle-sync-point
] unit-test

: test-active-intervals ( -- assoc )
    {
        { int-regs V{
            T{ live-interval-state
               { vreg 1 }
               { ranges V{ { 30 40 } } }
               { uses
                 V{ T{ vreg-use { n 32 } { def-rep double-rep } } }
               }
            }
            T{ live-interval-state
               { vreg 50 }
               { ranges V{ { 5 10 } } }
               { uses
                 V{ T{ vreg-use { n 8 } { def-rep double-rep } } }
               }
            }
        } }
        { float-regs V{ } }
    } ;

! Why are they both spilled?
{
    { { int-regs V{ } } { float-regs V{ } } }
} [
    f f <basic-block> <cfg> cfg set
    H{ } clone spill-slots set
    V{ } clone handled-intervals set
    100 progress set
    T{ sync-point { n 35 } } test-active-intervals
    [ handle-sync-point ] keep
] unit-test

! spill-at-sync-point
{ f } [
    <min-heap> unhandled-min-heap set
    f f <basic-block> <cfg> cfg set
    40 progress set
    T{ sync-point { n 40 } } interval-[30,46] spill-at-sync-point
] unit-test

! spill-at-sync-point?
{ t } [
    T{ sync-point { n 15 } } f spill-at-sync-point?
] unit-test
