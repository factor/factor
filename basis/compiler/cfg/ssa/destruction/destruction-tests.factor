USING: alien.syntax compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.ssa.destruction compiler.cfg.ssa.destruction.leaders
compiler.cfg.ssa.destruction.private compiler.cfg.utilities
cpu.architecture cpu.x86.assembler.operands kernel make namespaces
sequences tools.test ;
IN: compiler.cfg.ssa.destruction.tests

: setup-leader/reps-scenario ( -- )
    ! Note the differences in representation.
    H{ { 45 45 } { 46 45 } { 47 47 } { 100 47 } } leader-map set
    H{
        { 45 double-2-rep }
        { 46 double-rep }
        { 47 double-rep }
        { 100 double-rep }
    } representations set ;

! cleanup-insn
{
    V{ T{ ##copy { dst 100 } { src 46 } } }
} [
    setup-leader/reps-scenario
    T{ ##copy { src 46 } { dst 100 } } [ cleanup-insn ] V{ } make
] unit-test

! I think the difference is because ##parallel-copy may encode a swap
! between two vregs.
{
    V{ T{ ##copy { dst 47 } { src 45 } { rep double-2-rep } } }
} [
    setup-leader/reps-scenario
    T{ ##parallel-copy { values V{ { 100 46 } } } } [ cleanup-insn ] V{ } make
] unit-test

{ V{ } } [
    T{ ##parallel-copy { values V{ } } }
    [ cleanup-insn ] V{ } make
] unit-test

! destruct-ssa
{ } [
    H{ { 36 23 } { 23 23 } } leader-map set
    H{ { 36 int-rep } { 37 tagged-rep } } representations set
    V{
        T{ ##alien-invoke
           { reg-inputs V{ { 56 int-rep RDI } } }
           { stack-inputs V{ } }
           { reg-outputs { { 36 int-rep RAX } } }
           { dead-outputs { } }
           { cleanup 0 }
           { stack-size 0 }
           { symbols "g_quark_to_string" }
           { dll DLL" libglib-2.0.so" }
           { gc-map T{ gc-map } }
           { insn# 14 }
        }
        T{ ##call-gc { gc-map T{ gc-map } } }
        T{ ##box-alien
           { dst 37 }
           { src 36 }
           { temp 11 }
           { insn# 18 }
        }
    } 0 insns>block block>cfg destruct-ssa
] unit-test
