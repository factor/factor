USING: arrays compiler.cfg.alias-analysis compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.debugger compiler.cfg.comparisons
cpu.architecture tools.test byte-arrays layouts literals alien
accessors sequences ;
IN: compiler.cfg.alias-analysis.tests

: test-alias-analysis ( insn -- insn )
    init-alias-analysis
    alias-analysis-step
    [ f >>insn# ] map ;

! Redundant load elimination
{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##copy f 2 1 any-rep }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##slot-imm f 2 0 1 0 }
    } test-alias-analysis
] unit-test

! Store-load forwarding
{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##set-slot-imm f 1 0 1 0 }
        T{ ##copy f 2 1 any-rep }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##set-slot-imm f 1 0 1 0 }
        T{ ##slot-imm f 2 0 1 0 }
    } test-alias-analysis
] unit-test

! Dead store elimination
{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##set-slot-imm f 2 0 1 0 }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##set-slot-imm f 1 0 1 0 }
        T{ ##set-slot-imm f 2 0 1 0 }
    } test-alias-analysis
] unit-test

{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##peek f 3 D: 3 }
        T{ ##set-slot-imm f 3 0 1 0 }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##peek f 3 D: 3 }
        T{ ##set-slot-imm f 1 0 1 0 }
        T{ ##set-slot-imm f 2 0 1 0 }
        T{ ##set-slot-imm f 3 0 1 0 }
    } test-alias-analysis
] unit-test

! Redundant store elimination
{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##slot-imm f 1 0 1 0 }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##set-slot-imm f 1 0 1 0 }
    } test-alias-analysis
] unit-test

{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##copy f 2 1 any-rep }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##copy f 2 1 any-rep }
        T{ ##set-slot-imm f 2 0 1 0 }
    } test-alias-analysis
] unit-test

! Not a redundant load
{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##set-slot-imm f 0 1 1 0 }
        T{ ##slot-imm f 2 0 1 0 }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##set-slot-imm f 0 1 1 0 }
        T{ ##slot-imm f 2 0 1 0 }
    } test-alias-analysis
] unit-test

! Not a redundant store
{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##peek f 3 D: 3 }
        T{ ##set-slot-imm f 2 1 1 0 }
        T{ ##slot-imm f 4 0 1 0 }
        T{ ##set-slot-imm f 3 1 1 0 }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##peek f 3 D: 3 }
        T{ ##set-slot-imm f 2 1 1 0 }
        T{ ##slot-imm f 4 0 1 0 }
        T{ ##set-slot-imm f 3 1 1 0 }
    } test-alias-analysis
] unit-test

! There's a redundant load, but not a redundant store
{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##peek f 3 D: 3 }
        T{ ##slot-imm f 4 0 1 0 }
        T{ ##set-slot-imm f 2 0 1 0 }
        T{ ##slot f 5 0 3 0 0 }
        T{ ##set-slot-imm f 3 0 1 0 }
        T{ ##copy f 6 3 any-rep }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##peek f 3 D: 3 }
        T{ ##slot-imm f 4 0 1 0 }
        T{ ##set-slot-imm f 2 0 1 0 }
        T{ ##slot f 5 0 3 0 0 }
        T{ ##set-slot-imm f 3 0 1 0 }
        T{ ##slot-imm f 6 0 1 0 }
    } test-alias-analysis
] unit-test

! Fresh allocations don't alias existing values

! Redundant load elimination
{
    V{
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##peek f 3 D: 3 }
        T{ ##allot f 4 16 array }
        T{ ##set-slot-imm f 3 4 1 0 }
        T{ ##set-slot-imm f 2 1 1 0 }
        T{ ##copy f 5 3 any-rep }
    }
} [
    V{
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##peek f 3 D: 3 }
        T{ ##allot f 4 16 array }
        T{ ##set-slot-imm f 3 4 1 0 }
        T{ ##set-slot-imm f 2 1 1 0 }
        T{ ##slot-imm f 5 4 1 0 }
    } test-alias-analysis
] unit-test

! Redundant store elimination
{
    V{
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##peek f 3 D: 3 }
        T{ ##allot f 4 16 array }
        T{ ##slot-imm f 5 1 1 0 }
        T{ ##set-slot-imm f 3 4 1 0 }
    }
} [
    V{
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##peek f 3 D: 3 }
        T{ ##allot f 4 16 array }
        T{ ##set-slot-imm f 1 4 1 0 }
        T{ ##slot-imm f 5 1 1 0 }
        T{ ##set-slot-imm f 3 4 1 0 }
    } test-alias-analysis
] unit-test

! Storing a new alias class into another object means that heap-ac
! can now alias the new ac
{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##peek f 3 D: 3 }
        T{ ##allot f 4 16 array }
        T{ ##set-slot-imm f 0 4 1 0 }
        T{ ##set-slot-imm f 4 2 1 0 }
        T{ ##slot-imm f 5 3 1 0 }
        T{ ##set-slot-imm f 1 5 1 0 }
        T{ ##slot-imm f 6 4 1 0 }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##peek f 3 D: 3 }
        T{ ##allot f 4 16 array }
        T{ ##set-slot-imm f 0 4 1 0 }
        T{ ##set-slot-imm f 4 2 1 0 }
        T{ ##slot-imm f 5 3 1 0 }
        T{ ##set-slot-imm f 1 5 1 0 }
        T{ ##slot-imm f 6 4 1 0 }
    } test-alias-analysis
] unit-test

! Compares between objects which cannot alias are eliminated
{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##allot f 1 16 array }
        T{ ##load-reference f 2 f }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##allot f 1 16 array }
        T{ ##compare f 2 0 1 cc= }
    } test-alias-analysis
] unit-test

! Make sure that input to ##box-displaced-alien becomes heap-ac
{
    V{
        T{ ##allot f 1 16 byte-array }
        T{ ##load-reference f 2 10 }
        T{ ##box-displaced-alien f 3 2 1 4 byte-array }
        T{ ##slot-imm f 5 3 1 $[ alien type-number ] }
        T{ ##compare f 6 5 1 cc= }
    }
} [
    V{
        T{ ##allot f 1 16 byte-array }
        T{ ##load-reference f 2 10 }
        T{ ##box-displaced-alien f 3 2 1 4 byte-array }
        T{ ##slot-imm f 5 3 1 $[ alien type-number ] }
        T{ ##compare f 6 5 1 cc= }
    } test-alias-analysis
] unit-test

! We can't make any assumptions about heap-ac between
! instructions which can call back into Factor code
{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##alien-invoke f { } { } { } { } 0 0 "free" }
        T{ ##slot-imm f 2 0 1 0 }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##alien-invoke f { } { } { } { } 0 0 "free" }
        T{ ##slot-imm f 2 0 1 0 }
    } test-alias-analysis
] unit-test

{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##set-slot-imm f 1 0 1 0 }
        T{ ##alien-invoke f { } { } { } { } 0 0 "free" }
        T{ ##slot-imm f 2 0 1 0 }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##set-slot-imm f 1 0 1 0 }
        T{ ##alien-invoke f { } { } { } { } 0 0 "free" }
        T{ ##slot-imm f 2 0 1 0 }
    } test-alias-analysis
] unit-test

{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##set-slot-imm f 1 0 1 0 }
        T{ ##alien-invoke f { } { } { } { } 0 0 "free" }
        T{ ##set-slot-imm f 2 0 1 0 }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##set-slot-imm f 1 0 1 0 }
        T{ ##alien-invoke f { } { } { } { } 0 0 "free" }
        T{ ##set-slot-imm f 2 0 1 0 }
    } test-alias-analysis
] unit-test

{
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##alien-invoke f { } { } { } { } 0 0 "free" }
        T{ ##set-slot-imm f 1 0 1 0 }
    }
} [
    V{
        T{ ##peek f 0 D: 0 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##alien-invoke f { } { } { } { } 0 0 "free" }
        T{ ##set-slot-imm f 1 0 1 0 }
    } test-alias-analysis
] unit-test

! We can't eliminate stores on any alias class across a GC-ing
! instruction
{
    V{
        T{ ##allot f 0 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##alien-invoke f { } { } { } { } 0 0 "free" }
        T{ ##copy f 2 1 any-rep }
    }
} [
    V{
        T{ ##allot f 0 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##alien-invoke f { } { } { } { } 0 0 "free" }
        T{ ##slot-imm f 2 0 1 0 }
    } test-alias-analysis
] unit-test

{
    V{
        T{ ##allot f 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##set-slot-imm f 1 0 1 0 }
        T{ ##alien-invoke f { } { } { } { } 0 0 "free" }
        T{ ##copy f 2 1 any-rep }
    }
} [
    V{
        T{ ##allot f 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##set-slot-imm f 1 0 1 0 }
        T{ ##alien-invoke f { } { } { } { } 0 0 "free" }
        T{ ##slot-imm f 2 0 1 0 }
    } test-alias-analysis
] unit-test

{
    V{
        T{ ##allot f 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##set-slot-imm f 1 0 1 0 }
        T{ ##alien-invoke f { } { } { } { } 0 0 "free" }
        T{ ##set-slot-imm f 2 0 1 0 }
    }
} [
    V{
        T{ ##allot f 0 }
        T{ ##peek f 1 D: 1 }
        T{ ##peek f 2 D: 2 }
        T{ ##set-slot-imm f 1 0 1 0 }
        T{ ##alien-invoke f { } { } { } { } 0 0 "free" }
        T{ ##set-slot-imm f 2 0 1 0 }
    } test-alias-analysis
] unit-test

{
    V{
        T{ ##allot f 0 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##alien-invoke f { } { } { } { } 0 0 "free" }
    }
} [
    V{
        T{ ##allot f 0 }
        T{ ##slot-imm f 1 0 1 0 }
        T{ ##alien-invoke f { } { } { } { } 0 0 "free" }
        T{ ##set-slot-imm f 1 0 1 0 }
    } test-alias-analysis
] unit-test

! Make sure that gc-map-insns which are also vreg-insns are
! handled properly
{
    V{
        T{ ##allot f 0 }
        T{ ##alien-indirect f f { } { } { { 2 double-rep 0 } } { } 0 0 "free" }
        T{ ##set-slot-imm f 2 0 1 0 }
    }
} [
    V{
        T{ ##allot f 0 }
        T{ ##alien-indirect f f { } { } { { 2 double-rep 0 } } { } 0 0 "free" }
        T{ ##set-slot-imm f 2 0 1 0 }
    } test-alias-analysis
] unit-test
