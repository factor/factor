.syntax unified
.arm
.text
.p2align 2
.global trampoline
.type trampoline,%function
trampoline:
  sub sp, sp, #16
  str fp, [sp]
  str lr, [sp, #4]
  mov fp, sp
  str fp, [r8]
  blx ip
  ldr fp, [sp]
  ldr lr, [sp, #4]
  add sp, sp, #16
  bx lr
.size trampoline,.-trampoline
.global trampoline2
.type trampoline2,%function
trampoline2:
  str fp, [r4]
  str lr, [r4, #4]
  mov fp, r4
  str fp, [r8]
  blx ip
  ldr lr, [fp, #4]
  ldr fp, [fp]
  bx lr
.size trampoline2,.-trampoline2
.section .note.GNU-stack,"",%progbits
