USING: accessors compiler.cfg compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals cpu.architecture
cpu.x86.assembler.operands heaps kernel namespaces system tools.test ;
IN: compiler.cfg.linear-scan.allocation.tests

: interval-[30,46] ( -- live-interval )
    T{ live-interval-state
       { vreg 49 }
       { start 30 } { end 46 }
       { ranges { T{ live-range { from 30 } { to 46 } } } }
       { uses
         {
             T{ vreg-use { n 30 } { def-rep double-rep } }
             T{ vreg-use { n 46 } { use-rep double-rep } }
         }
       }
       { reg-class int-regs }
    } clone ;

: interval-[30,60] ( -- live-interval )
    T{ live-interval-state
       { vreg 25 }
       { start 30 } { end 60 }
       { reg-class int-regs }
       { reg RAX }
    } ;

cpu x86.64? [
    ! assign-registers
    { RAX } [
        f machine-registers init-allocator
        interval-[30,46] dup machine-registers assign-register reg>>
    ] unit-test

    ! register-status
    { { RAX 1/0. } } [
        f machine-registers init-allocator
        interval-[30,46] machine-registers register-status
    ] unit-test

    { { RCX 1/0. } } [
        f machine-registers init-allocator
        interval-[30,60] add-active
        interval-[30,46] machine-registers register-status
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
               { start 30 }
               { end 40 }
               { ranges
                 { T{ live-range { from 30 } { to 40 } } }
               }
               { uses
                 { T{ vreg-use { n 32 } { def-rep double-rep } } }
               }
            }
            T{ live-interval-state
               { vreg 50 }
               { start 5 }
               { end 10 }
               { ranges
                 { T{ live-range { from 5 } { to 10 } } }
               }
               { uses
                 { T{ vreg-use { n 8 } { def-rep double-rep } } }
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
