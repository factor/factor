.text
.align 3
.globl alpha_bootstrap_enter
.ent alpha_bootstrap_enter
alpha_bootstrap_enter:
  lda $30,-32($30)
  stq $26,8($30)
  stq $29,16($30)
  stq $10,24($30)
  bis $17,$17,$10
  bis $16,$16,$27
  jsr $26,($27),0
  bis $10,$10,$0
  ldq $10,24($30)
  ldq $29,16($30)
  ldq $26,8($30)
  lda $30,32($30)
  ret $31,($26),1
.end alpha_bootstrap_enter
.section .note.GNU-stack,"",@progbits
