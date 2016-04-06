USING: assocs compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.allocation.state
compiler.cfg.linear-scan.live-intervals compiler.cfg.linear-scan.ranges
compiler.cfg.registers cpu.architecture kernel namespaces sequences
tools.test ;
IN: compiler.cfg.linear-scan.allocation.spilling.tests

: test-live-interval ( -- live-interval )
    T{ live-interval-state
       { vreg 45 }
       { spill-to T{ spill-slot { n 8 } } }
       { spill-rep double-rep }
       { ranges V{ { 22 47 } { 67 68 } { 69 72 } } }
       { uses
         V{
             T{ vreg-use
                { n 28 }
                { use-rep double-rep }
             }
         }
       }
    } ;

! assign-spill
{ T{ spill-slot f 0 } } [
    f f <basic-block> <cfg> cfg set
    H{ } clone spill-slots set
    H{ { 45 double-2-rep } } representations set
    test-live-interval assign-spill
    { 45 8 } spill-slots get at
] unit-test

! last-use-rep
{ double-rep } [
    test-live-interval last-use-rep
] unit-test

! spill-before
{ f } [
    30 <live-interval> spill-before
] unit-test

! trim-after-ranges
{
    T{ live-interval-state
       { ranges V{ { 25 30 } { 40 50 } } }
       { uses V{ T{ vreg-use { n 25 } } } }
    }
} [
    T{ live-interval-state
       { ranges V{ { 0 10 } { 20 30 } { 40 50 } } }
       { uses V{ T{ vreg-use { n 25 } } } }
    } dup trim-after-ranges
] unit-test

{
    T{ live-interval-state
       { ranges V{ { 10 23 } } }
       { uses V{ T{ vreg-use { n 10 } } } }
    }
} [
    T{ live-interval-state
       { ranges V{ { 20 23 } } }
       { uses V{ T{ vreg-use { n 10 } } } }
    }
    dup trim-after-ranges
] unit-test

! trim-before-ranges
{
    T{ live-interval-state
       { ranges V{ { 0 10 } { 20 21 } } }
       { uses V{ T{ vreg-use { n 20 } } } }
    }
} [
    T{ live-interval-state
       { ranges V{ { 0 10 } { 20 30 } { 40 50 } } }
       { uses V{ T{ vreg-use { n 20 } } } }
    } dup trim-before-ranges
] unit-test
