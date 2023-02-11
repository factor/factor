! Copyright (C) 2009 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel compiler.cfg compiler.cfg.dce compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.utilities cpu.architecture tools.test ;
IN: compiler.cfg.dce.tests

: test-dce ( insns -- insns' )
    insns>cfg dup eliminate-dead-code entry>> instructions>> ;

{ V{
    T{ ##load-integer { dst 1 } { val 8 } }
    T{ ##load-integer { dst 2 } { val 16 } }
    T{ ##add { dst 3 } { src1 1 } { src2 2 } }
    T{ ##replace { src 3 } { loc D: 0 } }
} } [ V{
    T{ ##load-integer { dst 1 } { val 8 } }
    T{ ##load-integer { dst 2 } { val 16 } }
    T{ ##add { dst 3 } { src1 1 } { src2 2 } }
    T{ ##replace { src 3 } { loc D: 0 } }
} test-dce ] unit-test

{ V{ } } [ V{
    T{ ##load-integer { dst 1 } { val 8 } }
    T{ ##load-integer { dst 2 } { val 16 } }
    T{ ##add { dst 3 } { src1 1 } { src2 2 } }
} test-dce ] unit-test

{ V{ } } [ V{
    T{ ##load-integer { dst 3 } { val 8 } }
    T{ ##allot { dst 1 } { temp 2 } }
} test-dce ] unit-test

{ V{ } } [ V{
    T{ ##load-integer { dst 3 } { val 8 } }
    T{ ##allot { dst 1 } { temp 2 } }
    T{ ##set-slot-imm { obj 1 } { src 3 } }
} test-dce ] unit-test

{ V{
    T{ ##load-integer { dst 3 } { val 8 } }
    T{ ##allot { dst 1 } { temp 2 } }
    T{ ##set-slot-imm { obj 1 } { src 3 } }
    T{ ##replace { src 1 } { loc D: 0 } }
} } [ V{
    T{ ##load-integer { dst 3 } { val 8 } }
    T{ ##allot { dst 1 } { temp 2 } }
    T{ ##set-slot-imm { obj 1 } { src 3 } }
    T{ ##replace { src 1 } { loc D: 0 } }
} test-dce ] unit-test

{ V{
    T{ ##allot { dst 1 } { temp 2 } }
    T{ ##replace { src 1 } { loc D: 0 } }
} } [ V{
    T{ ##allot { dst 1 } { temp 2 } }
    T{ ##replace { src 1 } { loc D: 0 } }
} test-dce ] unit-test

{ V{
    T{ ##allot { dst 1 } { temp 2 } }
    T{ ##replace { src 1 } { loc D: 0 } }
    T{ ##load-integer { dst 3 } { val 8 } }
    T{ ##set-slot-imm { obj 1 } { src 3 } }
} } [ V{
    T{ ##allot { dst 1 } { temp 2 } }
    T{ ##replace { src 1 } { loc D: 0 } }
    T{ ##load-integer { dst 3 } { val 8 } }
    T{ ##set-slot-imm { obj 1 } { src 3 } }
} test-dce ] unit-test
