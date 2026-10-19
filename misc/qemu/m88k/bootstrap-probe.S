.text
.globl backend_cfg_call
backend_cfg_call:
 subu %r31,%r31,48
 st %r1,%r31,4
 st %r14,%r31,8
 st %r19,%r31,16
 st %r20,%r31,20
 st %r21,%r31,24
 st %r22,%r31,28
 st %r25,%r31,32
 st %r30,%r31,36
 or %r10,%r0,%r2
 or %r14,%r0,%r3
 jsr %r10
 ld %r2,%r14,0
 ld %r1,%r31,4
 ld %r14,%r31,8
 ld %r19,%r31,16
 ld %r20,%r31,20
 ld %r21,%r31,24
 ld %r22,%r31,28
 ld %r25,%r31,32
 ld %r30,%r31,36
 addu %r31,%r31,48
 jmp %r1

.globl boot_true
boot_true:
 or %r2,%r0,111
 st %r2,%r14,0
 jmp %r1
.globl boot_false
boot_false:
 or %r2,%r0,222
 st %r2,%r14,0
 jmp %r1
