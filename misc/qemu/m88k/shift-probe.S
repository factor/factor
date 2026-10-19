.text
.globl shift_call
shift_call:
 subu %r31,%r31,16
 st %r1,%r31,0
 st %r14,%r31,4
 st %r19,%r31,8
 st %r20,%r31,12
 addu %r14,%r2,4
 jsr %r3
 ld %r20,%r31,12
 ld %r19,%r31,8
 ld %r14,%r31,4
 ld %r1,%r31,0
 addu %r31,%r31,16
 jmp %r1
.globl m88k_cache_sync
m88k_cache_sync:
 tb0 0,%r0,451
 jmp %r1
