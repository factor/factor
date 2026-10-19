// Copyright (C) 2026 Doug Coleman.
// See https://factorcode.org/license.txt for BSD license.
#ifdef __arch64__
#define FRAME 176
#define BIAS 2047
#define CELL 8
#define STORE stx
.register %g2,#scratch
.register %g3,#scratch
#else
#define FRAME 96
#define BIAS 0
#define CELL 4
#define STORE st
#endif
.text
.global probe_trampoline
.type probe_trampoline,#function
probe_trampoline:
 save %sp,-FRAME,%sp
 mov %g2,%l0
 mov %g3,%l1
 mov %g4,%l2
 mov %g5,%l3
 mov %i0,%g1
 mov %i1,%g5
 mov 11,%g2
 mov 12,%g3
 mov 13,%g4
 mov %i2,%o0
 mov %i3,%o1
 call trampoline
 nop
 cmp %g2,11
 bne .Lbad
 nop
 cmp %g3,12
 bne .Lbad
 nop
 cmp %g4,13
 bne .Lbad
 nop
 mov %o0,%i0
 ba .Ldone
 nop
.Lbad:
 mov -1,%i0
.Ldone:
 mov %l0,%g2
 mov %l1,%g3
 mov %l2,%g4
 mov %l3,%g5
 ret
 restore
.section .note.GNU-stack,"",@progbits

.text
.global probe_restore_window
.type probe_restore_window,#function
probe_restore_window:
 save %sp,-FRAME,%sp
 mov 42,%l0
 STORE %l0,[%sp+BIAS+0*CELL]
 STORE %l1,[%sp+BIAS+1*CELL]
 STORE %l2,[%sp+BIAS+2*CELL]
 STORE %l3,[%sp+BIAS+3*CELL]
 STORE %l4,[%sp+BIAS+4*CELL]
 STORE %l5,[%sp+BIAS+5*CELL]
 STORE %l6,[%sp+BIAS+6*CELL]
 STORE %l7,[%sp+BIAS+7*CELL]
 STORE %i0,[%sp+BIAS+8*CELL]
 STORE %i1,[%sp+BIAS+9*CELL]
 STORE %i2,[%sp+BIAS+10*CELL]
 STORE %i3,[%sp+BIAS+11*CELL]
 STORE %i4,[%sp+BIAS+12*CELL]
 STORE %i5,[%sp+BIAS+13*CELL]
 STORE %i6,[%sp+BIAS+14*CELL]
 STORE %i7,[%sp+BIAS+15*CELL]
 add %sp,BIAS,%o0
 set .Lrestored,%o1
 mov 0,%l0
 call sparc_restore_window
 nop
.Lrestored:
 mov %l0,%i0
 ret
 restore
