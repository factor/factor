USING: compiler.cfg.write-barrier compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.debugger cpu.architecture
arrays tools.test vectors compiler.cfg kernel accessors
compiler.cfg.utilities ;
IN: compiler.cfg.write-barrier.tests

: test-write-barrier ( insns -- insns )
    <simple-block> dup write-barriers-step instructions>> ;

[
    V{
        T{ ##peek f 4 D 0 f }
        T{ ##allot f 7 24 array 8 f }
        T{ ##load-immediate f 9 8 f }
        T{ ##set-slot-imm f 9 7 1 3 f }
        T{ ##set-slot-imm f 4 7 2 3 f }
        T{ ##replace f 7 D 0 f }
        T{ ##branch }
    }
] [
    {
        T{ ##peek f 4 D 0 }
        T{ ##allot f 7 24 array 8 }
        T{ ##load-immediate f 9 8 }
        T{ ##set-slot-imm f 9 7 1 3 }
        T{ ##write-barrier f 7 10 11 }
        T{ ##set-slot-imm f 4 7 2 3 }
        T{ ##write-barrier f 7 12 13 }
        T{ ##replace f 7 D 0 }
    } test-write-barrier
] unit-test

[
    V{
        T{ ##load-immediate f 4 24 }
        T{ ##peek f 5 D -1 }
        T{ ##peek f 6 D -2 }
        T{ ##set-slot-imm f 5 6 3 2 }
        T{ ##write-barrier f 6 7 8 }
        T{ ##branch }
    }
] [
    {
        T{ ##load-immediate f 4 24 }
        T{ ##peek f 5 D -1 }
        T{ ##peek f 6 D -2 }
        T{ ##set-slot-imm f 5 6 3 2 }
        T{ ##write-barrier f 6 7 8 }
    } test-write-barrier
] unit-test

[
    V{
        T{ ##peek f 19 D -3 }
        T{ ##peek f 22 D -2 }
        T{ ##set-slot-imm f 22 19 3 2 }
        T{ ##write-barrier f 19 24 25 }
        T{ ##peek f 28 D -1 }
        T{ ##set-slot-imm f 28 19 4 2 }
        T{ ##branch }
    }
] [
    {
        T{ ##peek f 19 D -3 }
        T{ ##peek f 22 D -2 }
        T{ ##set-slot-imm f 22 19 3 2 }
        T{ ##write-barrier f 19 24 25 }
        T{ ##peek f 28 D -1 }
        T{ ##set-slot-imm f 28 19 4 2 }
        T{ ##write-barrier f 19 30 3 }
    } test-write-barrier
] unit-test
