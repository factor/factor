/* N64 native call gate. t9 holds callee; s3 holds Factor context.
 * Linked frame: previous fp at 0, Factor return address at 8.
 * FP is native SP+16, so both Factor and native calls place live spills
 * 16 bytes above the linked frame. N64 has no stack argument home area.
 */
.set noreorder
.set noat
.text
.p2align 2
.global trampoline
.type trampoline,@function
.ent trampoline
trampoline:
  daddiu $sp,$sp,-32
  sd $fp,16($sp)
  sd $ra,24($sp)
  sd $gp,0($sp)
  daddiu $fp,$sp,16
  sd $fp,0($s3)
  jalr $ra,$t9
  nop
  ld $gp,0($sp)
  ld $ra,24($sp)
  ld $fp,16($sp)
  jr $ra
  daddiu $sp,$sp,32
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
  sd $fp,0($t8)
  sd $ra,8($t8)
  sd $gp,16($t8)
  move $fp,$t8
  sd $fp,0($s3)
  jalr $ra,$t9
  nop
  ld $gp,16($fp)
  ld $ra,8($fp)
  ld $fp,0($fp)
  jr $ra
  nop
.end trampoline2
.size trampoline2,.-trampoline2

.section .note.GNU-stack,"",@progbits
