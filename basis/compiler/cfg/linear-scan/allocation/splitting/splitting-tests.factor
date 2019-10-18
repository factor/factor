USING: compiler.cfg.instructions compiler.cfg.linear-scan.allocation.splitting
compiler.cfg.linear-scan.live-intervals compiler.cfg.linear-scan.ranges
cpu.architecture sequences tools.test ;
IN: compiler.cfg.linear-scan.allocation.splitting.tests

: test-interval-easy ( -- interval )
    T{ live-interval-state
       { ranges V{ { 5 8 } { 12 20 } } }
       { uses
         V{
             T{ vreg-use { n 3 } { def-rep int-rep } }
             T{ vreg-use { n 15 } { def-rep int-rep } }
         }
       }
    } ;

! split-interval
{
    T{ live-interval-state
       { ranges V{ { 5 8 } } }
       { uses V{ T{ vreg-use { n 3 } { def-rep int-rep } } } }
    }
    T{ live-interval-state
       { ranges V{ { 12 20 } } }
       { uses V{ T{ vreg-use { n 15 } { def-rep int-rep } } } }
    }
} [
    test-interval-easy 10 split-interval
] unit-test

! split-uses
{
    { T{ vreg-use { n 3 } } }
    { T{ vreg-use { n 9 } } }
} [
    { T{ vreg-use { n 3 } } T{ vreg-use { n 9 } } } 6 split-uses
] unit-test

{
    { T{ vreg-use { n 10 } } T{ vreg-use { n 10 } } } { }
} [
    { T{ vreg-use { n 10 } } T{ vreg-use { n 10 } } } 12 split-uses
] unit-test

! This one is strange. Why is the middle one removed?
{
    { T{ vreg-use { n 3 } } }
    { T{ vreg-use { n 5 } } }
} [
    { T{ vreg-use { n 3 } } T{ vreg-use { n 4 } } T{ vreg-use { n 5 } } }
    4 split-uses
] unit-test
