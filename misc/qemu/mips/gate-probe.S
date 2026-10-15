/* Native test harness establishing the Factor gate's dedicated ctx register.
 * abi: call_gate(native_target, context), returns native_target(1,2,3,4).
 */
.set noreorder
.text
.global call_gate
.type call_gate,@function
.ent call_gate
call_gate:
#if __SIZEOF_POINTER__ == 8
 daddiu $sp,$sp,-160
 sd $ra,96($sp)
 sd $s3,104($sp)
 sd $fp,112($sp)
 sd $gp,120($sp)
 move $t9,$a0
 move $s3,$a1
 move $fp,$sp
 sd $sp,8($s3)
 li $12,0x12345678
 sd $12,64($sp)
#ifdef ALTERNATE
 daddiu $t8,$sp,128
 dla $15,trampoline2
#else
 dla $15,trampoline
#endif
#else
 addiu $sp,$sp,-160
 sw $ra,96($sp)
 sw $s3,100($sp)
 sw $fp,104($sp)
 sw $gp,108($sp)
 move $t9,$a0
 move $s3,$a1
 move $fp,$sp
 sw $sp,4($s3)
 li $12,0x12345678
 sw $12,64($sp)
#ifdef ALTERNATE
 addiu $t8,$sp,128
 la $15,trampoline2
#else
 la $15,trampoline
#endif
#endif
 li $a0,1
 li $a1,2
 li $a2,3
 li $a3,4
#ifdef ALTERNATE
#if __SIZEOF_POINTER__ == 8
 li $8,5
 li $9,6
 li $10,7
 li $11,8
 li $12,9
 sd $12,0($sp)
 li $12,10
 sd $12,8($sp)
 li $12,11
 sd $12,16($sp)
 li $12,12
 sd $12,24($sp)
#else
 li $12,5
 sw $12,16($sp)
 li $12,6
 sw $12,20($sp)
 li $12,7
 sw $12,24($sp)
 li $12,8
 sw $12,28($sp)
 li $12,9
 sw $12,32($sp)
 li $12,10
 sw $12,36($sp)
 li $12,11
 sw $12,40($sp)
 li $12,12
 sw $12,44($sp)
#endif
#endif
 jalr $ra,$15
 nop
#if __SIZEOF_POINTER__ == 8
 ld $ra,96($sp)
 ld $s3,104($sp)
 ld $fp,112($sp)
 ld $gp,120($sp)
 jr $ra
 daddiu $sp,$sp,160
#else
 lw $ra,96($sp)
 lw $s3,100($sp)
 lw $fp,104($sp)
 lw $gp,108($sp)
 jr $ra
 addiu $sp,$sp,160
#endif
.end call_gate
.size call_gate,.-call_gate
.section .note.GNU-stack,"",@progbits
