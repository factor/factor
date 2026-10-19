#ifdef __arch64__
#define FRAME 176
#else
#define FRAME 96
#endif
.text
.align 4
.global run_pic
run_pic:
 save %sp,-FRAME,%sp
 mov 123,%l7
 mov %i0,%o0
 cmp %i2,0
 be .Lnonzero
 nop
 cmp %g0,%g0
 ba .Lenter
 nop
.Lnonzero:
 orcc %g0,1,%g0
.Lenter:
 jmpl %i1,%o7
 nop
 st %l7,[%i3]
 mov %o0,%i0
 ret
 restore
.global pic_hit
pic_hit:
 mov 1,%o0
 retl
 nop
.section .note.GNU-stack,"",@progbits
