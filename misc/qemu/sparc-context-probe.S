#ifdef __arch64__
#define CELL 8
#define FRAME 176
#define STORE stx
.register %g2,#scratch
.register %g3,#scratch
#else
#define CELL 4
#define FRAME 96
#define STORE st
#endif
.text
.align 4
.global run_context
run_context:
 save %sp,-FRAME,%sp
 mov %g2,%l0
 mov %g3,%l1
 mov %g4,%l2
 mov %g5,%l3
 sub %sp,FRAME,%l4
 STORE %l4,[%i3+14*CELL]
 mov %i2,%g4
 clr %g3
 add %i0,CELL,%g2
 jmpl %i1,%o7
 nop
 mov %g2,%i0
 mov %l0,%g2
 mov %l1,%g3
 mov %l2,%g4
 mov %l3,%g5
 ret
 restore
.global run_tail
run_tail:
 save %sp,-FRAME,%sp
 jmpl %i0,%o7
 nop
 mov %o0,%i0
 ret
 restore
.global jit_tail_target
jit_tail_target:
 mov %o4,%o0
 retl
 nop
.section .note.GNU-stack,"",@progbits
