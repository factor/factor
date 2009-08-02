! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel tools.test namespaces sequences vectors accessors sets
arrays math.ranges assocs
cpu.architecture
compiler.cfg
compiler.cfg.ssa.liveness.private
compiler.cfg.ssa.liveness 
compiler.cfg.debugger
compiler.cfg.instructions
compiler.cfg.predecessors
compiler.cfg.registers ;
IN: compiler.cfg.ssa.liveness

[ t ] [ { 1 } 1 only? ] unit-test
[ t ] [ { } 1 only? ] unit-test
[ f ] [ { 2 1 } 1 only? ] unit-test
[ f ] [ { 2 } 1 only? ] unit-test

V{
    T{ ##peek f V int-regs 0 D 0 }
    T{ ##replace f V int-regs 0 D 0 }
    T{ ##replace f V int-regs 1 D 1 }
} 1 test-bb

V{
    T{ ##replace f V int-regs 2 D 0 }
} 2 test-bb

V{
    T{ ##replace f V int-regs 3 D 0 }
} 3 test-bb

1 get 2 get 3 get V{ } 2sequence >>successors drop

cfg new 1 get >>entry 4 set

[ ] [ 4 get compute-predecessors drop ] unit-test
[ ] [ 4 get precompute-liveness ] unit-test

[ H{ } ] [ back-edge-targets get ] unit-test
[ H{ } ] [ phi-outs get ] unit-test
[ t ] [ 1 get R_q { 1 2 3 } [ get ] map unique = ] unit-test
[ t ] [ 2 get R_q { 2 } [ get ] map unique = ] unit-test
[ t ] [ 3 get R_q { 3 } [ get ] map unique = ] unit-test

: self-T_q ( n -- ? )
    get [ T_q ] [ 1array unique ] bi = ;

[ t ] [ 1 self-T_q ] unit-test
[ t ] [ 2 self-T_q ] unit-test
[ t ] [ 3 self-T_q ] unit-test

[ f ] [ V int-regs 0 1 get live-in? ] unit-test
[ t ] [ V int-regs 1 1 get live-in? ] unit-test
[ t ] [ V int-regs 2 1 get live-in? ] unit-test
[ t ] [ V int-regs 3 1 get live-in? ] unit-test

[ f ] [ V int-regs 0 1 get live-out? ] unit-test
[ f ] [ V int-regs 1 1 get live-out? ] unit-test
[ t ] [ V int-regs 2 1 get live-out? ] unit-test
[ t ] [ V int-regs 3 1 get live-out? ] unit-test

[ f ] [ V int-regs 0 2 get live-in? ] unit-test
[ f ] [ V int-regs 1 2 get live-in? ] unit-test
[ t ] [ V int-regs 2 2 get live-in? ] unit-test
[ f ] [ V int-regs 3 2 get live-in? ] unit-test

[ f ] [ V int-regs 0 2 get live-out? ] unit-test
[ f ] [ V int-regs 1 2 get live-out? ] unit-test
[ f ] [ V int-regs 2 2 get live-out? ] unit-test
[ f ] [ V int-regs 3 2 get live-out? ] unit-test

[ f ] [ V int-regs 0 3 get live-in? ] unit-test
[ f ] [ V int-regs 1 3 get live-in? ] unit-test
[ f ] [ V int-regs 2 3 get live-in? ] unit-test
[ t ] [ V int-regs 3 3 get live-in? ] unit-test

[ f ] [ V int-regs 0 3 get live-out? ] unit-test
[ f ] [ V int-regs 1 3 get live-out? ] unit-test
[ f ] [ V int-regs 2 3 get live-out? ] unit-test
[ f ] [ V int-regs 3 3 get live-out? ] unit-test

V{ } 0 test-bb
V{ } 1 test-bb
V{ } 2 test-bb
V{ } 3 test-bb
V int-regs 2
    2 get V int-regs 0 2array
    3 get V int-regs 1 2array
2array \ ##phi new-insn 1vector
4 test-bb
test-diamond

cfg new 1 get >>entry 5 set

[ ] [ 5 get compute-predecessors drop ] unit-test
[ ] [ 5 get precompute-liveness ] unit-test

[ t ] [ V int-regs 0 1 get live-in? ] unit-test
[ t ] [ V int-regs 1 1 get live-in? ] unit-test
[ f ] [ V int-regs 2 1 get live-in? ] unit-test

[ t ] [ V int-regs 0 1 get live-out? ] unit-test
[ t ] [ V int-regs 1 1 get live-out? ] unit-test
[ f ] [ V int-regs 2 1 get live-out? ] unit-test

[ t ] [ V int-regs 0 2 get live-in? ] unit-test
[ f ] [ V int-regs 1 2 get live-in? ] unit-test
[ f ] [ V int-regs 2 2 get live-in? ] unit-test

[ t ] [ V int-regs 0 2 get live-out? ] unit-test
[ f ] [ V int-regs 1 2 get live-out? ] unit-test
[ f ] [ V int-regs 2 2 get live-out? ] unit-test

[ f ] [ V int-regs 0 3 get live-in? ] unit-test
[ t ] [ V int-regs 1 3 get live-in? ] unit-test
[ f ] [ V int-regs 2 3 get live-in? ] unit-test

[ f ] [ V int-regs 0 3 get live-out? ] unit-test
[ t ] [ V int-regs 1 3 get live-out? ] unit-test
[ f ] [ V int-regs 2 3 get live-out? ] unit-test

[ f ] [ V int-regs 0 4 get live-in? ] unit-test
[ f ] [ V int-regs 1 4 get live-in? ] unit-test
[ f ] [ V int-regs 2 4 get live-in? ] unit-test

[ f ] [ V int-regs 0 4 get live-out? ] unit-test
[ f ] [ V int-regs 1 4 get live-out? ] unit-test
[ f ] [ V int-regs 2 4 get live-out? ] unit-test

! This is the CFG in Figure 3 from the paper
V{ } 1 test-bb
V{ } 2 test-bb
1 get 2 get 1vector >>successors drop
V{
    T{ ##peek f V int-regs 0 D 0 }
    T{ ##peek f V int-regs 1 D 0 }
    T{ ##peek f V int-regs 2 D 0 }
} 3 test-bb
V{ } 11 test-bb
2 get 3 get 11 get V{ } 2sequence >>successors drop
V{
    T{ ##replace f V int-regs 0 D 0 }
} 4 test-bb
V{ } 8 test-bb
3 get 8 get 4 get V{ } 2sequence >>successors drop
V{
    T{ ##replace f V int-regs 1 D 0 }
} 9 test-bb
8 get 9 get 1vector >>successors drop
V{
    T{ ##replace f V int-regs 2 D 0 }
} 5 test-bb
4 get 5 get 1vector >>successors drop
V{ } 10 test-bb
V{ } 6 test-bb
5 get 6 get 1vector >>successors drop
9 get 6 get 10 get V{ } 2sequence >>successors drop
V{ } 7 test-bb
6 get 5 get 7 get V{ } 2sequence >>successors drop
10 get 8 get 1vector >>successors drop
7 get 2 get 1vector >>successors drop

cfg new 1 get >>entry 0 set
[ ] [ 0 get compute-predecessors drop ] unit-test
[ ] [ 0 get precompute-liveness ] unit-test

[ t ] [ 1 get R_q 1 11 [a,b] [ get ] map unique = ] unit-test
[ t ] [ 2 get R_q 2 11 [a,b] [ get ] map unique = ] unit-test
[ t ] [ 3 get R_q 3 10 [a,b] [ get ] map unique = ] unit-test
[ t ] [ 4 get R_q 4 7 [a,b] [ get ] map unique = ] unit-test
[ t ] [ 5 get R_q 5 7 [a,b] [ get ] map unique = ] unit-test
[ t ] [ 6 get R_q 6 7 [a,b] [ get ] map unique = ] unit-test
[ t ] [ 7 get R_q 7 7 [a,b] [ get ] map unique = ] unit-test
[ t ] [ 8 get R_q 6 10 [a,b] [ get ] map unique = ] unit-test
[ t ] [ 9 get R_q 8 6 10 [a,b] remove [ get ] map unique = ] unit-test
[ t ] [ 10 get R_q 10 10 [a,b] [ get ] map unique = ] unit-test
[ t ] [ 11 get R_q 11 11 [a,b] [ get ] map unique = ] unit-test

[ t ] [ 1 get T_q 1 get 1array unique = ] unit-test
[ t ] [ 2 get T_q 2 get 1array unique = ] unit-test
[ t ] [ 3 get T_q 3 get 2 get 2array unique = ] unit-test
[ t ] [ 4 get T_q 4 get 2 get 2array unique = ] unit-test
[ t ] [ 5 get T_q 5 get 2 get 2array unique = ] unit-test
[ t ] [ 6 get T_q { 6 2 5 } [ get ] map unique = ] unit-test
[ t ] [ 7 get T_q { 7 2 } [ get ] map unique = ] unit-test
[ t ] [ 8 get T_q { 8 2 5 } [ get ] map unique = ] unit-test
[ t ] [ 9 get T_q { 2 5 8 9 } [ get ] map unique = ] unit-test
[ t ] [ 10 get T_q { 2 5 8 10 } [ get ] map unique = ] unit-test
[ t ] [ 11 get T_q 11 get 1array unique = ] unit-test

[ f ] [ 1 get back-edge-target? ] unit-test
[ t ] [ 2 get back-edge-target? ] unit-test
[ f ] [ 3 get back-edge-target? ] unit-test
[ f ] [ 4 get back-edge-target? ] unit-test
[ t ] [ 5 get back-edge-target? ] unit-test
[ f ] [ 6 get back-edge-target? ] unit-test
[ f ] [ 7 get back-edge-target? ] unit-test
[ t ] [ 8 get back-edge-target? ] unit-test
[ f ] [ 9 get back-edge-target? ] unit-test
[ f ] [ 10 get back-edge-target? ] unit-test
[ f ] [ 11 get back-edge-target? ] unit-test

[ f ] [ 1 11 [a,b] [ get phi-outs get at ] any? ] unit-test

[ f ] [ V int-regs 0 1 get live-in? ] unit-test
[ f ] [ V int-regs 1 1 get live-in? ] unit-test
[ f ] [ V int-regs 2 1 get live-in? ] unit-test

[ f ] [ V int-regs 0 1 get live-out? ] unit-test
[ f ] [ V int-regs 1 1 get live-out? ] unit-test
[ f ] [ V int-regs 2 1 get live-out? ] unit-test

[ f ] [ V int-regs 0 2 get live-in? ] unit-test
[ f ] [ V int-regs 1 2 get live-in? ] unit-test
[ f ] [ V int-regs 2 2 get live-in? ] unit-test

[ f ] [ V int-regs 0 2 get live-out? ] unit-test
[ f ] [ V int-regs 1 2 get live-out? ] unit-test
[ f ] [ V int-regs 2 2 get live-out? ] unit-test

[ f ] [ V int-regs 0 3 get live-in? ] unit-test
[ f ] [ V int-regs 1 3 get live-in? ] unit-test
[ f ] [ V int-regs 2 3 get live-in? ] unit-test

[ t ] [ V int-regs 0 3 get live-out? ] unit-test
[ t ] [ V int-regs 1 3 get live-out? ] unit-test
[ t ] [ V int-regs 2 3 get live-out? ] unit-test

[ t ] [ V int-regs 0 4 get live-in? ] unit-test
[ f ] [ V int-regs 1 4 get live-in? ] unit-test
[ t ] [ V int-regs 2 4 get live-in? ] unit-test

[ f ] [ V int-regs 0 4 get live-out? ] unit-test
[ f ] [ V int-regs 1 4 get live-out? ] unit-test
[ t ] [ V int-regs 2 4 get live-out? ] unit-test

[ f ] [ V int-regs 0 5 get live-in? ] unit-test
[ f ] [ V int-regs 1 5 get live-in? ] unit-test
[ t ] [ V int-regs 2 5 get live-in? ] unit-test

[ f ] [ V int-regs 0 5 get live-out? ] unit-test
[ f ] [ V int-regs 1 5 get live-out? ] unit-test
[ t ] [ V int-regs 2 5 get live-out? ] unit-test

[ f ] [ V int-regs 0 6 get live-in? ] unit-test
[ f ] [ V int-regs 1 6 get live-in? ] unit-test
[ t ] [ V int-regs 2 6 get live-in? ] unit-test

[ f ] [ V int-regs 0 6 get live-out? ] unit-test
[ f ] [ V int-regs 1 6 get live-out? ] unit-test
[ t ] [ V int-regs 2 6 get live-out? ] unit-test

[ f ] [ V int-regs 0 7 get live-in? ] unit-test
[ f ] [ V int-regs 1 7 get live-in? ] unit-test
[ f ] [ V int-regs 2 7 get live-in? ] unit-test

[ f ] [ V int-regs 0 7 get live-out? ] unit-test
[ f ] [ V int-regs 1 7 get live-out? ] unit-test
[ f ] [ V int-regs 2 7 get live-out? ] unit-test

[ f ] [ V int-regs 0 8 get live-in? ] unit-test
[ t ] [ V int-regs 1 8 get live-in? ] unit-test
[ t ] [ V int-regs 2 8 get live-in? ] unit-test

[ f ] [ V int-regs 0 8 get live-out? ] unit-test
[ t ] [ V int-regs 1 8 get live-out? ] unit-test
[ t ] [ V int-regs 2 8 get live-out? ] unit-test

[ f ] [ V int-regs 0 9 get live-in? ] unit-test
[ t ] [ V int-regs 1 9 get live-in? ] unit-test
[ t ] [ V int-regs 2 9 get live-in? ] unit-test

[ f ] [ V int-regs 0 9 get live-out? ] unit-test
[ t ] [ V int-regs 1 9 get live-out? ] unit-test
[ t ] [ V int-regs 2 9 get live-out? ] unit-test

[ f ] [ V int-regs 0 10 get live-in? ] unit-test
[ t ] [ V int-regs 1 10 get live-in? ] unit-test
[ t ] [ V int-regs 2 10 get live-in? ] unit-test

[ f ] [ V int-regs 0 10 get live-out? ] unit-test
[ t ] [ V int-regs 1 10 get live-out? ] unit-test
[ t ] [ V int-regs 2 10 get live-out? ] unit-test

[ f ] [ V int-regs 0 11 get live-in? ] unit-test
[ f ] [ V int-regs 1 11 get live-in? ] unit-test
[ f ] [ V int-regs 2 11 get live-in? ] unit-test

[ f ] [ V int-regs 0 11 get live-out? ] unit-test
[ f ] [ V int-regs 1 11 get live-out? ] unit-test
[ f ] [ V int-regs 2 11 get live-out? ] unit-test
