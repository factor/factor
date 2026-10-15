#ifdef __arch64__
#define CELL 8
#define FRAME 176
#define STORE stx
#define LOAD ldx
#define BIAS 2047
.register %g2,#scratch
.register %g3,#scratch
#else
#define CELL 4
#define FRAME 96
#define STORE st
#define LOAD ld
#define BIAS 0
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
.global reset_child_entry
reset_child_entry:
 and %o0,15,%o1
 cmp %o1,4
 bne .Lbad_start
 nop
 LOAD [%g2],%o0
 cmp %o0,112
 bne .Lbad_start
 nop
 mov 336,%o2
 ba .Lresume_parent
 nop
.Lbad_start:
 mov -1,%o2
.Lresume_parent:
 LOAD [%g4+CELL],%g5
 STORE %g5,[%g4]
 LOAD [%g5+2*CELL],%g2
 LOAD [%g5+3*CELL],%g3
 STORE %o2,[%g2]
 LOAD [%g5],%o0
 LOAD [%g4+2*CELL],%o1
 ba sparc_restore_window
 nop
.section .note.GNU-stack,"",@progbits
