USING: compiler.cfg.instructions compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.live-intervals cpu.architecture sequences tools.test ;
IN: compiler.cfg.linear-scan.allocation.spilling.tests

! last-use-rep
{
    double-rep
} [
    T{ live-interval-state
       { vreg 45 }
       { spill-to T{ spill-slot { n 8 } } }
       { spill-rep double-rep }
       { start 22 }
       { end 47 }
       { ranges
         T{ slice
            { from 0 }
            { to 1 }
            { seq
              {
                  T{ live-range { from 22 } { to 47 } }
                        T{ live-range { from 67 } { to 68 } }
                  T{ live-range { from 69 } { to 72 } }
              }
            }
         }
       }
       { uses
         {
             T{ vreg-use
                { n 28 }
                { use-rep double-rep }
             }
         }
       }
    } last-use-rep
] unit-test
