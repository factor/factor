USING: arrays compiler.cfg.alias-analysis compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.debugger compiler.cfg.comparisons
cpu.architecture tools.test ;
IN: compiler.cfg.alias-analysis.tests

! Redundant load elimination
[
    V{
        T{ ##peek f 0 D 0 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##copy f 2 1 any-rep }
    }
] [
    V{
        T{ ##peek f 0 D 0 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##slot-imm f 2 0 1 0 }
    } alias-analysis-step
] unit-test

! Store-load forwarding
[
    V{
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##set-slot-imm f 1 0 1 0 }
        T{ ##copy f 2 1 any-rep }
    }
] [
    V{
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##set-slot-imm f 1 0 1 0 }
        T{ ##slot-imm f 2 0 1 0 }
    } alias-analysis-step
] unit-test

! Dead store elimination
[
    V{
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##peek f 2 D 2 }
        T{ ##set-slot-imm f 2 0 1 0 }
    }
] [
    V{
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##peek f 2 D 2 }
        T{ ##set-slot-imm f 1 0 1 0 }
        T{ ##set-slot-imm f 2 0 1 0 }
    } alias-analysis-step
] unit-test

! Redundant store elimination
[
    V{
        T{ ##peek f 0 D 0 }
        T{ ##slot-imm f 1 0 1 0 }
    }
] [
    V{
        T{ ##peek f 0 D 0 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##set-slot-imm f 1 0 1 0 }
    } alias-analysis-step
] unit-test

[
    V{
        T{ ##peek f 0 D 0 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##copy f 2 1 any-rep }
    }
] [
    V{
        T{ ##peek f 0 D 0 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##copy f 2 1 any-rep }
        T{ ##set-slot-imm f 2 0 1 0 }
    } alias-analysis-step
] unit-test

! Not a redundant load
[
    V{
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##set-slot-imm f 0 1 1 0 }
        T{ ##slot-imm f 2 0 1 0 }
    }
] [
    V{
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##set-slot-imm f 0 1 1 0 }
        T{ ##slot-imm f 2 0 1 0 }
    } alias-analysis-step
] unit-test

! Not a redundant store
[
    V{
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##peek f 2 D 2 }
        T{ ##peek f 3 D 3 }
        T{ ##set-slot-imm f 2 1 1 0 }
        T{ ##slot-imm f 4 0 1 0 }
        T{ ##set-slot-imm f 3 1 1 0 }
    }
] [
    V{
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##peek f 2 D 2 }
        T{ ##peek f 3 D 3 }
        T{ ##set-slot-imm f 2 1 1 0 }
        T{ ##slot-imm f 4 0 1 0 }
        T{ ##set-slot-imm f 3 1 1 0 }
    } alias-analysis-step
] unit-test

! There's a redundant load, but not a redundant store
[
    V{
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##peek f 2 D 2 }
        T{ ##peek f 3 D 3 }
        T{ ##slot-imm f 4 0 1 0 }
        T{ ##set-slot-imm f 2 0 1 0 }
        T{ ##slot f 5 0 3 0 0 }
        T{ ##set-slot-imm f 3 0 1 0 }
        T{ ##copy f 6 3 any-rep }
    }
] [
    V{
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##peek f 2 D 2 }
        T{ ##peek f 3 D 3 }
        T{ ##slot-imm f 4 0 1 0 }
        T{ ##set-slot-imm f 2 0 1 0 }
        T{ ##slot f 5 0 3 0 0 }
        T{ ##set-slot-imm f 3 0 1 0 }
        T{ ##slot-imm f 6 0 1 0 }
    } alias-analysis-step
] unit-test

! Fresh allocations don't alias existing values

! Redundant load elimination
[
    V{
        T{ ##peek f 1 D 1 }
        T{ ##peek f 2 D 2 }
        T{ ##peek f 3 D 3 }
        T{ ##allot f 4 16 array }
        T{ ##set-slot-imm f 3 4 1 0 }
        T{ ##set-slot-imm f 2 1 1 0 }
        T{ ##copy f 5 3 any-rep }
    }
] [
    V{
        T{ ##peek f 1 D 1 }
        T{ ##peek f 2 D 2 }
        T{ ##peek f 3 D 3 }
        T{ ##allot f 4 16 array }
        T{ ##set-slot-imm f 3 4 1 0 }
        T{ ##set-slot-imm f 2 1 1 0 }
        T{ ##slot-imm f 5 4 1 0 }
    } alias-analysis-step
] unit-test

! Redundant store elimination
[
    V{
        T{ ##peek f 1 D 1 }
        T{ ##peek f 2 D 2 }
        T{ ##peek f 3 D 3 }
        T{ ##allot f 4 16 array }
        T{ ##slot-imm f 5 1 1 0 }
        T{ ##set-slot-imm f 3 4 1 0 }
    }
] [
    V{
        T{ ##peek f 1 D 1 }
        T{ ##peek f 2 D 2 }
        T{ ##peek f 3 D 3 }
        T{ ##allot f 4 16 array }
        T{ ##set-slot-imm f 1 4 1 0 }
        T{ ##slot-imm f 5 1 1 0 }
        T{ ##set-slot-imm f 3 4 1 0 }
    } alias-analysis-step
] unit-test

! Storing a new alias class into another object means that heap-ac
! can now alias the new ac
[
    V{
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##peek f 2 D 2 }
        T{ ##peek f 3 D 3 }
        T{ ##allot f 4 16 array }
        T{ ##set-slot-imm f 0 4 1 0 }
        T{ ##set-slot-imm f 4 2 1 0 }
        T{ ##slot-imm f 5 3 1 0 }
        T{ ##set-slot-imm f 1 5 1 0 }
        T{ ##slot-imm f 6 4 1 0 }
    }
] [
    V{
        T{ ##peek f 0 D 0 }
        T{ ##peek f 1 D 1 }
        T{ ##peek f 2 D 2 }
        T{ ##peek f 3 D 3 }
        T{ ##allot f 4 16 array }
        T{ ##set-slot-imm f 0 4 1 0 }
        T{ ##set-slot-imm f 4 2 1 0 }
        T{ ##slot-imm f 5 3 1 0 }
        T{ ##set-slot-imm f 1 5 1 0 }
        T{ ##slot-imm f 6 4 1 0 }
    } alias-analysis-step
] unit-test

! Compares between objects which cannot alias are eliminated
[
    V{
        T{ ##peek f 0 D 0 }
        T{ ##allot f 1 16 array }
        T{ ##load-reference f 2 f }
    }
] [
    V{
        T{ ##peek f 0 D 0 }
        T{ ##allot f 1 16 array }
        T{ ##compare f 2 0 1 cc= }
    } alias-analysis-step
] unit-test
