#ifdef __arch64__
#define FRAME 176
.register %g2,#scratch
.register %g3,#scratch
#define CELL 8
#define BIAS 2047
#define LOAD ldx
#define STORE stx
#else
#define FRAME 96
#define CELL 4
#define BIAS 0
#define LOAD ld
#define STORE st
#endif
.text
.align 4
.global cb_integer_entry
cb_integer_entry:
 save %sp,-FRAME,%sp
 LOAD [%fp+BIAS+6*CELL],%l0
 cmp %l0,0
 be .Lfail
 nop
 add %i0,%i1,%i0
 add %i0,%i2,%i0
 add %i0,%i3,%i0
 add %i0,%i4,%i0
 add %i0,%i5,%i0
 ret
 restore
.Lfail:
 clr %i0
 ret
 restore
.global cb_float_entry
cb_float_entry:
 save %sp,-FRAME,%sp
#ifndef __arch64__
 std %i0,[%sp+64]
 ldd [%sp+64],%f0
#endif
 faddd %f0,%f0,%f0
 ret
 restore
.global cb_quotation_entry
cb_quotation_entry:
 save %sp,-FRAME,%sp
#ifdef __arch64__
 setx factor_child_called,%l7,%g1
#else
 set factor_child_called,%g1
#endif
 mov 1,%l0
 st %l0,[%g1]
#ifdef __arch64__
 setx factor_child_quot,%l7,%g1
#else
 set factor_child_quot,%g1
#endif
 STORE %i0,[%g1]
 ret
 restore
.global run_quot_template
run_quot_template:
 save %sp,-FRAME,%sp
 mov %g2,%l0
 mov %g3,%l1
 mov %g4,%l2
 mov %g5,%l3
 mov %i2,%g4
 clr %g3
 add %i0,CELL,%g2
 mov %i3,%o0
 set 0x11223344,%o4
 jmpl %i1,%o7
 nop
 mov %g2,%i0
 mov %l0,%g2
 mov %l1,%g3
 mov %l2,%g4
 mov %l3,%g5
 ret
 restore
.section .note.GNU-stack,"",@progbits
