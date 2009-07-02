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
    T{ ##load-immediate { dst V int-regs 1 } { val 8 } }
    T{ ##load-immediate { dst V int-regs 2 } { val 16 } }
    T{ ##add { dst V int-regs 3 } { src1 V int-regs 1 } { src2 V int-regs 2 } }
    T{ ##replace { src V int-regs 3 } { loc D 0 } }
} ] [ V{
    T{ ##load-immediate { dst V int-regs 1 } { val 8 } }
    T{ ##load-immediate { dst V int-regs 2 } { val 16 } }
    T{ ##add { dst V int-regs 3 } { src1 V int-regs 1 } { src2 V int-regs 2 } }
    T{ ##replace { src V int-regs 3 } { loc D 0 } }
} test-dce ] unit-test

[ V{ } ] [ V{
    T{ ##load-immediate { dst V int-regs 1 } { val 8 } }
    T{ ##load-immediate { dst V int-regs 2 } { val 16 } }
    T{ ##add { dst V int-regs 3 } { src1 V int-regs 1 } { src2 V int-regs 2 } }
} test-dce ] unit-test

[ V{ } ] [ V{
    T{ ##load-immediate { dst V int-regs 3 } { val 8 } }
    T{ ##allot { dst V int-regs 1 } { temp V int-regs 2 } }
} test-dce ] unit-test

[ V{ } ] [ V{
    T{ ##load-immediate { dst V int-regs 3 } { val 8 } }
    T{ ##allot { dst V int-regs 1 } { temp V int-regs 2 } }
    T{ ##set-slot-imm { obj V int-regs 1 } { src V int-regs 3 } }
} test-dce ] unit-test

[ V{
    T{ ##load-immediate { dst V int-regs 3 } { val 8 } }
    T{ ##allot { dst V int-regs 1 } { temp V int-regs 2 } }
    T{ ##set-slot-imm { obj V int-regs 1 } { src V int-regs 3 } }
    T{ ##replace { src V int-regs 1 } { loc D 0 } }
} ] [ V{
    T{ ##load-immediate { dst V int-regs 3 } { val 8 } }
    T{ ##allot { dst V int-regs 1 } { temp V int-regs 2 } }
    T{ ##set-slot-imm { obj V int-regs 1 } { src V int-regs 3 } }
    T{ ##replace { src V int-regs 1 } { loc D 0 } }
} test-dce ] unit-test

[ V{
    T{ ##allot { dst V int-regs 1 } { temp V int-regs 2 } }
    T{ ##replace { src V int-regs 1 } { loc D 0 } }
} ] [ V{
    T{ ##allot { dst V int-regs 1 } { temp V int-regs 2 } }
    T{ ##replace { src V int-regs 1 } { loc D 0 } }
} test-dce ] unit-test

[ V{
    T{ ##allot { dst V int-regs 1 } { temp V int-regs 2 } }
    T{ ##replace { src V int-regs 1 } { loc D 0 } }
    T{ ##load-immediate { dst V int-regs 3 } { val 8 } }
    T{ ##set-slot-imm { obj V int-regs 1 } { src V int-regs 3 } }
} ] [ V{
    T{ ##allot { dst V int-regs 1 } { temp V int-regs 2 } }
    T{ ##replace { src V int-regs 1 } { loc D 0 } }
    T{ ##load-immediate { dst V int-regs 3 } { val 8 } }
    T{ ##set-slot-imm { obj V int-regs 1 } { src V int-regs 3 } }
} test-dce ] unit-test
