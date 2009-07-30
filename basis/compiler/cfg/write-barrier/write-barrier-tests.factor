USING: compiler.cfg.write-barrier compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.debugger cpu.architecture
arrays tools.test vectors compiler.cfg kernel accessors
compiler.cfg.utilities ;
IN: compiler.cfg.write-barrier.tests

: test-write-barrier ( insns -- insns )
    <simple-block> dup write-barriers-step instructions>> ;

[
    V{
        T{ ##peek f V int-regs 4 D 0 f }
        T{ ##allot f V int-regs 7 24 array V int-regs 8 f }
        T{ ##load-immediate f V int-regs 9 8 f }
        T{ ##set-slot-imm f V int-regs 9 V int-regs 7 1 3 f }
        T{ ##set-slot-imm f V int-regs 4 V int-regs 7 2 3 f }
        T{ ##replace f V int-regs 7 D 0 f }
        T{ ##branch }
    }
] [
    {
        T{ ##peek f V int-regs 4 D 0 }
        T{ ##allot f V int-regs 7 24 array V int-regs 8 }
        T{ ##load-immediate f V int-regs 9 8 }
        T{ ##set-slot-imm f V int-regs 9 V int-regs 7 1 3 }
        T{ ##write-barrier f V int-regs 7 V int-regs 10 V int-regs 11 }
        T{ ##set-slot-imm f V int-regs 4 V int-regs 7 2 3 }
        T{ ##write-barrier f V int-regs 7 V int-regs 12 V int-regs 13 }
        T{ ##replace f V int-regs 7 D 0 }
    } test-write-barrier
] unit-test

[
    V{
        T{ ##load-immediate f V int-regs 4 24 }
        T{ ##peek f V int-regs 5 D -1 }
        T{ ##peek f V int-regs 6 D -2 }
        T{ ##set-slot-imm f V int-regs 5 V int-regs 6 3 2 }
        T{ ##write-barrier f V int-regs 6 V int-regs 7 V int-regs 8 }
        T{ ##branch }
    }
] [
    {
        T{ ##load-immediate f V int-regs 4 24 }
        T{ ##peek f V int-regs 5 D -1 }
        T{ ##peek f V int-regs 6 D -2 }
        T{ ##set-slot-imm f V int-regs 5 V int-regs 6 3 2 }
        T{ ##write-barrier f V int-regs 6 V int-regs 7 V int-regs 8 }
    } test-write-barrier
] unit-test

[
    V{
        T{ ##peek f V int-regs 19 D -3 }
        T{ ##peek f V int-regs 22 D -2 }
        T{ ##set-slot-imm f V int-regs 22 V int-regs 19 3 2 }
        T{ ##write-barrier f V int-regs 19 V int-regs 24 V int-regs 25 }
        T{ ##peek f V int-regs 28 D -1 }
        T{ ##set-slot-imm f V int-regs 28 V int-regs 19 4 2 }
        T{ ##branch }
    }
] [
    {
        T{ ##peek f V int-regs 19 D -3 }
        T{ ##peek f V int-regs 22 D -2 }
        T{ ##set-slot-imm f V int-regs 22 V int-regs 19 3 2 }
        T{ ##write-barrier f V int-regs 19 V int-regs 24 V int-regs 25 }
        T{ ##peek f V int-regs 28 D -1 }
        T{ ##set-slot-imm f V int-regs 28 V int-regs 19 4 2 }
        T{ ##write-barrier f V int-regs 19 V int-regs 30 V int-regs 3 }
    } test-write-barrier
] unit-test
