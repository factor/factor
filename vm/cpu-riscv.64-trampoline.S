.option norelax
.option norvc
.text
.p2align 2
.global trampoline
.type trampoline,@function
trampoline:
  addi sp, sp, -16
  sd s0, 0(sp)
  sd ra, 8(sp)
  mv s0, sp
  sd s0, 0(s3)
  jalr ra, t2, 0
  ld s0, 0(sp)
  ld ra, 8(sp)
  addi sp, sp, 16
  ret
.size trampoline,.-trampoline
.global trampoline2
.type trampoline2,@function
trampoline2:
  sd s0, 0(t3)
  sd ra, 8(t3)
  mv s0, t3
  sd s0, 0(s3)
  jalr ra, t2, 0
  ld ra, 8(s0)
  ld s0, 0(s0)
  ret
.size trampoline2,.-trampoline2
.section .note.GNU-stack,"",@progbits
