// PIC-TAIL ($25) is live across lazy compilation but caller-saved in the ABI.
// Native calls enter with pv=$27 pointing to the C function and ctx=$13.
.text
.align 3
.globl trampoline
.ent trampoline
trampoline:
  lda $30,-32($30)
  stq $9,0($30)
  stq $26,8($30)
  stq $29,16($30)
  stq $25,24($30)
  bis $30,$30,$9
  stq $9,0($13)
  jsr $26,($27),0
  ldq $25,24($30)
  ldq $29,16($30)
  ldq $26,8($30)
  ldq $9,0($30)
  lda $30,32($30)
  ret $31,($26),1
.end trampoline
.globl trampoline2
.ent trampoline2
trampoline2:
  stq $9,0($3)
  stq $26,8($3)
  stq $29,16($3)
  stq $25,24($3)
  bis $3,$3,$9
  stq $9,0($13)
  jsr $26,($27),0
  ldq $25,24($9)
  ldq $29,16($9)
  ldq $26,8($9)
  ldq $9,0($9)
  ret $31,($26),1
.end trampoline2
.section .note.GNU-stack,"",@progbits
