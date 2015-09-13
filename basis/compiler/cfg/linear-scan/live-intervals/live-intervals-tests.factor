USING: accessors arrays compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.numbering compiler.cfg.linear-scan.ranges
compiler.cfg.liveness compiler.cfg.registers
compiler.cfg.ssa.destruction.leaders compiler.cfg.utilities cpu.architecture
fry kernel namespaces sequences tools.test ;
IN: compiler.cfg.linear-scan.live-intervals.tests

: <live-interval-for-ranges> ( ranges -- live-interval )
    10 int-rep <live-interval> [ '[ first2 _ ranges>> add-range ] each ] keep
    dup compute-start/end ;

! cfg>sync-points
{
    V{ T{ sync-point { n 0 } } }
} [
    V{ T{ ##call-gc } } insns>cfg
    [ number-instructions ] [ cfg>sync-points ] bi
] unit-test

! intervals-intersect?
{ t f f } [
    { { 4 20 } } <live-interval-for-ranges>
    { { 8 12 } } <live-interval-for-ranges> intervals-intersect?
    { { 9 20 } { 3 5 } } <live-interval-for-ranges>
    { { 0 1 } { 7 8 } } <live-interval-for-ranges> intervals-intersect?
    { { 3 5 } } <live-interval-for-ranges>
    { { 7 8 } } <live-interval-for-ranges> intervals-intersect?
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
