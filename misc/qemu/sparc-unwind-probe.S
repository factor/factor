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
 mov %i2,%g4
 clr %g3
 mov %i0,%g2
 LOAD [%i0],%o0
 jmpl %i1,%o7
 nop
 mov %g2,%i0
 mov %l0,%g2
 mov %l1,%g3
 mov %l2,%g4
 mov %l3,%g5
 ret
 restore
.global unwind_child_entry
unwind_child_entry:
 save %sp,-FRAME,%sp
 and %i0,15,%o1
 cmp %o1,4
 bne .Lbad_unwind
 nop
 mov 336,%o0
 ba .Ldone_unwind
 nop
.Lbad_unwind:
 mov -1,%o0
.Ldone_unwind:
 STORE %o0,[%g2]
 ret
 restore
.section .note.GNU-stack,"",@progbits
