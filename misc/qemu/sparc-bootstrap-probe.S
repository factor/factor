/* Execute the bytes emitted by Factor, preserving the native caller's g2. */
#if defined(__arch64__)
.register %g2,#scratch
.register %g3,#scratch
#define FRAME 176
#define CELL 8
#else
#define FRAME 96
#define CELL 4
#endif
.text
.align 4
.global run_template
.type run_template,#function
run_template:
 save %sp,-FRAME,%sp
 mov %g2,%l0
 mov %g3,%l1
 mov %g4,%l2
 mov %g5,%l3
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
.global jit_swap
jit_swap:
.incbin "swap.bin"
 retl
 nop
.global jit_add
jit_add:
.incbin "add.bin"
 retl
 nop
.global jit_mul
jit_mul:
.incbin "mul.bin"
 retl
 nop
.global jit_divmod
jit_divmod:
.incbin "divmod.bin"
 retl
 nop
.global jit_checked_add
jit_checked_add:
.incbin "checked-add.bin"
 retl
 nop
.global jit_checked_sub
jit_checked_sub:
.incbin "checked-sub.bin"
 retl
 nop
.global jit_checked_mul
jit_checked_mul:
.incbin "checked-mul.bin"
 retl
 nop
.global run_fpu
run_fpu:
 save %sp,-FRAME,%sp
 jmpl %i0,%o7
 nop
 ret
 restore
.global jit_fpu_save_restore
jit_fpu_save_restore:
.incbin "fpu-state.bin"
.incbin "set-fpu-state.bin"
 retl
 nop
.section .note.GNU-stack,"",@progbits
