.text
.align 4
.global trampoline
.type trampoline,@function
trampoline:
  l.addi r1,r1,-16
  l.sw 0(r1),r2
  l.sw 4(r1),r9
  l.or r2,r1,r1
  l.sw 0(r20),r2
  l.jalr r13
   l.nop
  l.lwz r2,0(r1)
  l.lwz r9,4(r1)
  l.jr r9
   l.addi r1,r1,16
.size trampoline,.-trampoline

.global trampoline2
.type trampoline2,@function
trampoline2:
  l.sw 0(r15),r2
  l.sw 4(r15),r9
  l.or r2,r15,r15
  l.sw 0(r20),r2
  l.jalr r13
   l.nop
  l.lwz r9,4(r2)
  l.lwz r2,0(r2)
  l.jr r9
   l.nop
.size trampoline2,.-trampoline2
.section .note.GNU-stack,"",@progbits
