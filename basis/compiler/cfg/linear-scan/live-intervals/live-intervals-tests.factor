USING: arrays compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.numbering compiler.cfg.liveness
compiler.cfg.registers compiler.cfg.ssa.destruction.leaders
compiler.cfg.utilities cpu.architecture kernel namespaces sequences
tools.test ;
IN: compiler.cfg.linear-scan.live-intervals.tests

! add-range
{
    T{ live-interval-state
       { vreg 5 }
       { ranges V{ T{ live-range { from 5 } { to 12 } } } }
       { uses V{ } }
       { reg-class int-rep }
    }
} [
    5 int-rep <live-interval> dup
    { { 5 10 } { 8 12 } } [ first2 rot add-range ] with each
] unit-test

{
    T{ live-interval-state
       { vreg 5 }
       { ranges V{ T{ live-range { from 5 } { to 12 } } } }
       { uses V{ } }
       { reg-class int-rep }
    }
} [
    5 int-rep <live-interval> dup
    { { 10 12 } { 5 10 } } [ first2 rot add-range ] with each
] unit-test

! cfg>sync-points
{
    V{ T{ sync-point { n 0 } } }
} [
    V{ T{ ##call-gc } } insns>cfg
    [ number-instructions ] [ cfg>sync-points ] bi
] unit-test

! handle-live-out
{ } [
    H{ } clone live-outs set
    <basic-block> handle-live-out
] unit-test

{
    H{
        {
            8
            T{ live-interval-state
               { vreg 8 }
               { ranges V{ T{ live-range { from -10 } { to 23 } } } }
               { uses V{ } }
               { reg-class int-regs }
            }
        }
        {
            9
            T{ live-interval-state
               { vreg 9 }
               { ranges V{ T{ live-range { from -10 } { to 23 } } } }
               { uses V{ } }
               { reg-class int-regs }
            }
        }
        {
            4
            T{ live-interval-state
               { vreg 4 }
               { ranges V{ T{ live-range { from -10 } { to 23 } } } }
               { uses V{ } }
               { reg-class int-regs }
            }
        }
    }
} [
    -10 from set
    23 to set
    H{ } clone live-intervals set
    H{ { 4 4 } { 8 8 } { 9 9 } } leader-map set
    H{ { 4 int-rep } { 8 int-rep } { 9 int-rep } } representations set
    <basic-block> [ H{ { 4 4 } { 8 8 } { 9 9 } } 2array 1array live-outs set ]
    [ handle-live-out ] bi live-intervals get
] unit-test
