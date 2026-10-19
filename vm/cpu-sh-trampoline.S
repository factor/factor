/* Classic SH3/SH4 native gates. R1 is the native callee, R12 the active
 * context, R14 the linked Factor frame. R4..R7 and FP arguments stay intact.
 */
.text
.p2align 2
.global trampoline
.type trampoline,@function
trampoline:
  add #-16,r15
  mov.l r14,@r15
  sts pr,r0
  mov.l r0,@(4,r15)
  mov r15,r14
  mov.l r14,@r12
  jsr @r1
  nop
  mov.l @(4,r15),r7
  lds r7,pr
  mov.l @r15,r14
  rts
  add #16,r15
.size trampoline,.-trampoline

/* R3 identifies a reserved header above all outgoing stack arguments.
 * SP stays at the ABI argument area throughout the native call.
 */
.global trampoline2
.type trampoline2,@function
trampoline2:
  mov.l r14,@r3
  sts pr,r0
  mov.l r0,@(4,r3)
  mov r3,r14
  mov.l r14,@r12
  jsr @r1
  nop
  mov.l @(4,r14),r7
  lds r7,pr
  mov.l @r14,r14
  rts
  nop
.size trampoline2,.-trampoline2
.section .note.GNU-stack,"",@progbits
