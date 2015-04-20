USING: compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.ssa.destruction compiler.cfg.ssa.destruction.leaders
compiler.cfg.ssa.destruction.private cpu.architecture kernel make namespaces
tools.test ;
IN: compiler.cfg.ssa.destruction.tests

! cleanup-insn
{
    V{ T{ ##copy { src 45 } { dst 47 } { rep double-2-rep } } }
} [
    H{ { 45 45 } { 46 45 } { 47 47 } { 100 47 } } leader-map set
    ! how can the leader of a vreg have a different representation
    ! than the vreg itself?
    H{
        { 45 double-2-rep }
        { 46 double-rep }
        { 47 double-rep }
        { 100 double-rep }
    } representations set
    T{ ##parallel-copy { values V{ { 100 46 } } } }
    [ cleanup-insn ] V{ } make
] unit-test

{ V{ } } [
    T{ ##parallel-copy { values V{ } } }
    [ cleanup-insn ] V{ } make
] unit-test

! coalesce-leaders
{
    H{ { 30 60 } }
} [
    H{ } clone leader-map set
    30 60 coalesce-leaders
    leader-map get
] unit-test
