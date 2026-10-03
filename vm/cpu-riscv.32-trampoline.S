.option norelax
.option norvc
.text
.p2align 2
.global trampoline
.type trampoline,@function
trampoline:
  addi sp, sp, -16
  sw s0, 0(sp)
  sw ra, 4(sp)
  mv s0, sp
  sw s0, 0(s3)
  jalr ra, t2, 0
  lw s0, 0(sp)
  lw ra, 4(sp)
  addi sp, sp, 16
  ret
.size trampoline,.-trampoline
.global trampoline2
.type trampoline2,@function
trampoline2:
  sw s0, 0(t3)
  sw ra, 4(t3)
  mv s0, t3
  sw s0, 0(s3)
  jalr ra, t2, 0
  lw ra, 4(s0)
  lw s0, 0(s0)
  ret
.size trampoline2,.-trampoline2
.section .note.GNU-stack,"",@progbits
