! Copyright (C) 2008, 2009 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.cfg.write-barrier compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.debugger cpu.architecture
arrays tools.test vectors compiler.cfg kernel accessors
compiler.cfg.utilities namespaces sequences ;
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

V{
    T{ ##set-slot-imm f 2 1 3 4 }
    T{ ##write-barrier f 1 2 3 }
} 1 test-bb
V{
    T{ ##set-slot-imm f 2 1 3 4 }
    T{ ##write-barrier f 1 2 3 }
} 2 test-bb
1 get 2 get 1vector >>successors drop
cfg new 1 get >>entry 0 set

[ ] [ 0 [ eliminate-write-barriers ] change ] unit-test
[ V{
    T{ ##set-slot-imm f 2 1 3 4 }
    T{ ##write-barrier f 1 2 3 }
} ] [ 1 get instructions>> ] unit-test
[ V{
    T{ ##set-slot-imm f 2 1 3 4 }
} ] [ 2 get instructions>> ] unit-test

V{
    T{ ##set-slot-imm f 2 1 3 4 }
    T{ ##write-barrier f 1 2 3 }
} 1 test-bb
V{
    T{ ##allot }
    T{ ##set-slot-imm f 2 1 3 4 }
    T{ ##write-barrier f 1 2 3 }
} 2 test-bb
1 get 2 get 1vector >>successors drop
cfg new 1 get >>entry 0 set

[ ] [ 0 [ eliminate-write-barriers ] change ] unit-test
[ V{
    T{ ##set-slot-imm f 2 1 3 4 }
    T{ ##write-barrier f 1 2 3 }
} ] [ 1 get instructions>> ] unit-test
[ V{
    T{ ##allot }
    T{ ##set-slot-imm f 2 1 3 4 }
    T{ ##write-barrier f 1 2 3 }
} ] [ 2 get instructions>> ] unit-test

V{
    T{ ##set-slot-imm f 2 1 3 4 }
    T{ ##write-barrier f 1 2 3 }
} 1 test-bb
V{
    T{ ##allot }
} 2 test-bb
1 get 2 get 1vector >>successors drop
V{
    T{ ##set-slot-imm f 2 1 3 4 }
    T{ ##write-barrier f 1 2 3 }
} 3 test-bb
2 get 3 get 1vector >>successors drop
cfg new 1 get >>entry 0 set
[ ] [ 0 [ eliminate-write-barriers ] change ] unit-test
[ V{
    T{ ##set-slot-imm f 2 1 3 4 }
    T{ ##write-barrier f 1 2 3 }
} ] [ 1 get instructions>> ] unit-test
[ V{ T{ ##allot } } ] [ 2 get instructions>> ] unit-test
[ V{
    T{ ##set-slot-imm f 2 1 3 4 }
    T{ ##write-barrier f 1 2 3 }
} ] [ 3 get instructions>> ] unit-test
