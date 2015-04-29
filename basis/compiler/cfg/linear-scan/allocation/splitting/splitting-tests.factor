USING: compiler.cfg.instructions compiler.cfg.linear-scan.allocation.splitting
compiler.cfg.linear-scan.live-intervals cpu.architecture sequences tools.test ;
IN: compiler.cfg.linear-scan.allocation.splitting.tests

: test-interval-easy ( -- interval )
    T{ live-interval-state
       { ranges {
           T{ live-range { from 5 } { to 8 } }
           T{ live-range { from 12 } { to 20 } }
       } }
       { uses {
           T{ vreg-use { n 3 } { def-rep int-rep } }
           T{ vreg-use { n 15 } { def-rep int-rep } }
       } }
    } ;

! split-interval
{
    T{ live-interval-state
       { ranges { T{ live-range { from 5 } { to 8 } } } }
       { uses
         T{ slice
            { from 0 }
            { to 1 }
            { seq {
                T{ vreg-use { n 3 } { def-rep int-rep } }
                T{ vreg-use { n 15 } { def-rep int-rep } }
            } }
         }
       }
    }
    T{ live-interval-state
       { ranges { T{ live-range { from 12 } { to 20 } } } }
       { uses
         T{ slice
            { from 1 }
            { to 2 }
            { seq {
                T{ vreg-use { n 3 } { def-rep int-rep } }
                T{ vreg-use { n 15 } { def-rep int-rep } }
            } }
         }
       }
    }
} [
    test-interval-easy 10 split-interval
] unit-test
