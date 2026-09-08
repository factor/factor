USING: accessors arrays compiler.cfg.linear-scan.checker
compiler.cfg.linear-scan.live-intervals compiler.cfg.registers
cpu.architecture kernel namespaces sequences tools.test ;
IN: compiler.cfg.linear-scan.checker.tests

: interval-a ( -- interval )
    T{ live-interval-state
        { vreg 0 } { reg 0 } { ranges V{ { 0 3 } { 8 10 } } }
        { uses V{ T{ vreg-use { n 0 } } T{ vreg-use { n 10 } } } }
    } clone ;

: interval-b ( -- interval )
    T{ live-interval-state
        { vreg 1 } { reg 0 } { ranges V{ { 4 7 } } }
        { uses V{ T{ vreg-use { n 5 } } } }
    } clone ;

: check-pair ( a b -- )
    H{ { 0 int-rep } { 1 int-rep } } representations [
        2array H{ { int-regs { 0 1 } } } check-allocated-intervals
    ] with-variable ;

! Lifetime holes can share a register; enclosing intervals alone cannot
! establish interference.
{ } [ interval-a interval-b check-pair ] unit-test

[ interval-a interval-b V{ { 3 7 } } >>ranges check-pair ]
[ overlapping-allocated-ranges? ] must-fail-with

[ interval-a interval-b 2 >>reg check-pair ]
[ invalid-allocated-register? ] must-fail-with

[ interval-a interval-b V{ { 6 7 } } >>ranges check-pair ]
[ uncovered-allocated-use? ] must-fail-with

[ interval-a interval-b V{ { 7 4 } } >>ranges check-pair ]
[ invalid-allocated-ranges? ] must-fail-with

{ } [
    interval-a interval-b 2array dup required-register-uses
    check-register-uses
] unit-test

! Losing an entire interval is invisible to a range-overlap-only check.
[
    interval-a interval-b 2array required-register-uses
    interval-a 1array swap check-register-uses
] [ changed-register-uses? ] must-fail-with

[
    interval-a interval-b 2array required-register-uses
    interval-a dup interval-b 3array swap check-register-uses
] [ changed-register-uses? ] must-fail-with

! Memory operands at clobbers can disappear from the register intervals.
{ { { 0 0 } } } [
    interval-a V{ T{ vreg-use { n 0 } }
                  T{ vreg-use { n 10 } { spill-slot? t } } } >>uses
    1array required-register-uses
] unit-test
