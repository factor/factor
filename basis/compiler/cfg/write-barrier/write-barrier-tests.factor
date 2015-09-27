USING: compiler.cfg.instructions compiler.cfg.write-barrier
tools.test ;
IN: compiler.cfg.write-barrier.tests

! Do need a write barrier on a random store.
{
    V{
        T{ ##peek f 1 }
        T{ ##set-slot f 2 1 3 }
        T{ ##write-barrier f 1 3 }
    }
} [
    V{
        T{ ##peek f 1 }
        T{ ##set-slot f 2 1 3 }
        T{ ##write-barrier f 1 3 }
    } write-barriers-step
] unit-test

{
    V{
        T{ ##peek f 1 }
        T{ ##set-slot-imm f 2 1 }
        T{ ##write-barrier-imm f 1 }
    }
} [
    V{
        T{ ##peek f 1 }
        T{ ##set-slot-imm f 2 1 }
        T{ ##write-barrier-imm f 1 }
    } write-barriers-step
] unit-test

! Don't need a write barrier on freshly allocated objects.
{
    V{
        T{ ##allot f 1 }
        T{ ##set-slot f 2 1 3 }
    }
} [
    V{
        T{ ##allot f 1 }
        T{ ##set-slot f 2 1 3 }
        T{ ##write-barrier f 1 3 }
    } write-barriers-step
] unit-test

{
    V{
        T{ ##allot f 1 }
        T{ ##set-slot-imm f 2 1 }
    }
} [
    V{
        T{ ##allot f 1 }
        T{ ##set-slot-imm f 2 1 }
        T{ ##write-barrier-imm f 1 }
    } write-barriers-step
] unit-test

! Do need a write barrier if there's a subroutine call between
! the allocation and the store.
{
    V{
        T{ ##allot f 1 }
        T{ ##box }
        T{ ##set-slot f 2 1 3 }
        T{ ##write-barrier f 1 3 }
    }
} [
    V{
        T{ ##allot f 1 }
        T{ ##box }
        T{ ##set-slot f 2 1 3 }
        T{ ##write-barrier f 1 3 }
    } write-barriers-step
] unit-test

{
    V{
        T{ ##allot f 1 }
        T{ ##box }
        T{ ##set-slot-imm f 2 1 }
        T{ ##write-barrier-imm f 1 }
    }
} [
    V{
        T{ ##allot f 1 }
        T{ ##box }
        T{ ##set-slot-imm f 2 1 }
        T{ ##write-barrier-imm f 1 }
    } write-barriers-step
] unit-test

! ##copy instructions
{
    V{
        T{ ##copy f 2 1 }
        T{ ##set-slot-imm f 3 1 }
        T{ ##write-barrier-imm f 2 }
    }
} [
    V{
        T{ ##copy f 2 1 }
        T{ ##set-slot-imm f 3 1 }
        T{ ##write-barrier-imm f 2 }
    } write-barriers-step
] unit-test

{
    V{
        T{ ##copy f 2 1 }
        T{ ##set-slot-imm f 3 2 }
        T{ ##write-barrier-imm f 1 }
    }
} [
    V{
        T{ ##copy f 2 1 }
        T{ ##set-slot-imm f 3 2 }
        T{ ##write-barrier-imm f 1 }
    } write-barriers-step
] unit-test

{
    V{
        T{ ##copy f 2 1 }
        T{ ##copy f 3 2 }
        T{ ##set-slot-imm f 3 1 }
        T{ ##write-barrier-imm f 2 }
    }
} [
    V{
        T{ ##copy f 2 1 }
        T{ ##copy f 3 2 }
        T{ ##set-slot-imm f 3 1 }
        T{ ##write-barrier-imm f 2 }
    } write-barriers-step
] unit-test

{
    V{
        T{ ##copy f 2 1 }
        T{ ##copy f 3 2 }
        T{ ##set-slot-imm f 4 1 }
        T{ ##write-barrier-imm f 3 }
    }
} [
    V{
        T{ ##copy f 2 1 }
        T{ ##copy f 3 2 }
        T{ ##set-slot-imm f 4 1 }
        T{ ##write-barrier-imm f 3 }
    } write-barriers-step
] unit-test
