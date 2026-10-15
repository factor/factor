/* O32 native call gate. t9 holds callee; s3 holds Factor context.
 * Keep 16 bytes of ABI argument home area below the linked Factor frame.
 * Linked frame: previous fp at 0, Factor return address at 4.
 */
.set noreorder
.set noat
.text
.p2align 2
.global trampoline
.type trampoline,@function
.ent trampoline
trampoline:
  addiu $sp,$sp,-32
  sw $fp,16($sp)
  sw $ra,20($sp)
  sw $gp,24($sp)
  addiu $fp,$sp,16
  sw $fp,0($s3)
  jalr $ra,$t9
  nop
  lw $gp,24($sp)
  lw $ra,20($sp)
  lw $fp,16($sp)
  jr $ra
  addiu $sp,$sp,32
.end trampoline
.size trampoline,.-trampoline

/* Caller prepares native SP and provides its linked frame address in t8.
 * This gate leaves SP unchanged, so arbitrary outgoing stack arguments stay
 * at their ABI-defined offsets. The frame reserves three cells for FP/RA/GP.
 */
.global trampoline2
.type trampoline2,@function
.ent trampoline2
trampoline2:
  sw $fp,0($t8)
  sw $ra,4($t8)
  sw $gp,8($t8)
  move $fp,$t8
  sw $fp,0($s3)
  jalr $ra,$t9
  nop
  lw $gp,8($fp)
  lw $ra,4($fp)
  lw $fp,0($fp)
  jr $ra
  nop
.end trampoline2
.size trampoline2,.-trampoline2

.section .note.GNU-stack,"",@progbits
