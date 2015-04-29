USING: compiler.cfg.linear-scan.live-intervals cpu.architecture kernel
sequences tools.test ;
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
