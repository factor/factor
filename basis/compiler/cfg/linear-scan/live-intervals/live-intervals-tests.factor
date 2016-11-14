USING: accessors arrays compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.numbering compiler.cfg.linear-scan.ranges
compiler.cfg.liveness compiler.cfg.registers
compiler.cfg.ssa.destruction.leaders compiler.cfg.utilities cpu.architecture
cpu.x86.assembler.operands fry kernel namespaces sequences tools.test ;
IN: compiler.cfg.linear-scan.live-intervals.tests

: <live-interval-for-ranges> ( ranges -- live-interval )
    10 <live-interval> [ '[ first2 _ ranges>> add-range ] each ] keep ;

! (add-use)
{
    T{ vreg-use f 20 f f t }
    T{ live-interval-state
       { vreg 10 }
       { uses V{ T{ vreg-use { n 20 } { spill-slot? t } } } }
     }
} [
    20 10 <live-interval> [ t (add-use) ] keep
] unit-test

! cfg>sync-points
{
    V{
        T{ sync-point { n 2 } }
    }
} [
    V{
        T{ ##call-gc }
        T{ ##callback-inputs }
    } insns>cfg
    [ number-instructions ] [ cfg>sync-points ] bi
] unit-test

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

! (find-use)
{
    T{ vreg-use
       { n 102 }
       { def-rep int-rep }
       { use-rep tagged-rep }
     }
} [
    128 test-interval (find-use)
] unit-test

! find-use
{
    f T{ vreg-use { n 25 } }
} [
    25 T{ live-interval-state { uses V{ } } } find-use
    25 T{ live-interval-state { uses V{ T{ vreg-use { n 25 } } } } } find-use
] unit-test

! finish-live-interval
{
    V{ { 5 10 } { 21 30 } }
} [
    { { 21 30 } { 5 10 } } <live-interval-for-ranges>
    dup finish-live-interval ranges>>
] unit-test

! insn>sync-point
{ f f t } [
    T{ ##call-gc } insn>sync-point
    T{ ##callback-outputs } insn>sync-point keep-dst?>>
    T{ ##unbox } insn>sync-point keep-dst?>>
] unit-test

! intervals-intersect?
{ t f f } [
    { { 4 20 } } <live-interval-for-ranges>
    { { 8 12 } } <live-interval-for-ranges> intervals-intersect?
    { { 9 20 } { 3 5 } } <live-interval-for-ranges>
    { { 7 8 } { 0 1 } } <live-interval-for-ranges> intervals-intersect?
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
               { ranges V{ { -10 23 } } }
               { uses V{ } }
            }
        }
        {
            9
            T{ live-interval-state
               { vreg 9 }
               { ranges V{ { -10 23 } } }
               { uses V{ } }
            }
        }
        {
            4
            T{ live-interval-state
               { vreg 4 }
               { ranges V{ { -10 23 } } }
               { uses V{ } }
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

! record-def
{
    T{ live-interval-state
       { vreg 37 }
       { ranges V{ { 20 20 } } }
       { uses V{ T{ vreg-use { n 20 } { def-rep int-rep } } } }
    }
} [
    H{ { 37 37 } } leader-map set
    H{ { 37 int-rep } } representations set
    37 20 f record-def
    37 vreg>live-interval
] unit-test
