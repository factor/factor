! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test compiler.cfg kernel accessors compiler.cfg.dce
compiler.cfg.instructions compiler.cfg.registers cpu.architecture ;
IN: compiler.cfg.dce.tests

: test-dce ( insns -- insns' )
    <basic-block> swap >>instructions
    cfg new swap >>entry
    eliminate-dead-code
    entry>> instructions>> ; 

[ V{
    T{ ##load-immediate { dst 1 } { val 8 } }
    T{ ##load-immediate { dst 2 } { val 16 } }
    T{ ##add { dst 3 } { src1 1 } { src2 2 } }
    T{ ##replace { src 3 } { loc D 0 } }
} ] [ V{
    T{ ##load-immediate { dst 1 } { val 8 } }
    T{ ##load-immediate { dst 2 } { val 16 } }
    T{ ##add { dst 3 } { src1 1 } { src2 2 } }
    T{ ##replace { src 3 } { loc D 0 } }
} test-dce ] unit-test

[ V{ } ] [ V{
    T{ ##load-immediate { dst 1 } { val 8 } }
    T{ ##load-immediate { dst 2 } { val 16 } }
    T{ ##add { dst 3 } { src1 1 } { src2 2 } }
} test-dce ] unit-test

[ V{ } ] [ V{
    T{ ##load-immediate { dst 3 } { val 8 } }
    T{ ##allot { dst 1 } { temp 2 } }
} test-dce ] unit-test

[ V{ } ] [ V{
    T{ ##load-immediate { dst 3 } { val 8 } }
    T{ ##allot { dst 1 } { temp 2 } }
    T{ ##set-slot-imm { obj 1 } { src 3 } }
} test-dce ] unit-test

[ V{
    T{ ##load-immediate { dst 3 } { val 8 } }
    T{ ##allot { dst 1 } { temp 2 } }
    T{ ##set-slot-imm { obj 1 } { src 3 } }
    T{ ##replace { src 1 } { loc D 0 } }
} ] [ V{
    T{ ##load-immediate { dst 3 } { val 8 } }
    T{ ##allot { dst 1 } { temp 2 } }
    T{ ##set-slot-imm { obj 1 } { src 3 } }
    T{ ##replace { src 1 } { loc D 0 } }
} test-dce ] unit-test

[ V{
    T{ ##allot { dst 1 } { temp 2 } }
    T{ ##replace { src 1 } { loc D 0 } }
} ] [ V{
    T{ ##allot { dst 1 } { temp 2 } }
    T{ ##replace { src 1 } { loc D 0 } }
} test-dce ] unit-test

[ V{
    T{ ##allot { dst 1 } { temp 2 } }
    T{ ##replace { src 1 } { loc D 0 } }
    T{ ##load-immediate { dst 3 } { val 8 } }
    T{ ##set-slot-imm { obj 1 } { src 3 } }
} ] [ V{
    T{ ##allot { dst 1 } { temp 2 } }
    T{ ##replace { src 1 } { loc D 0 } }
    T{ ##load-immediate { dst 3 } { val 8 } }
    T{ ##set-slot-imm { obj 1 } { src 3 } }
} test-dce ] unit-test
