DEF(void,primitive_fixnum_add,(void *myvm)):
	mov ARG0, ARG2  /* save vm ptr for overflow */
	mov (DS_REG),ARG0
	mov -CELL_SIZE(DS_REG),ARG1
	sub $CELL_SIZE,DS_REG
	mov ARG1,ARITH_TEMP_1
	add ARG0,ARITH_TEMP_1
	jo MANGLE(overflow_fixnum_add)
	mov ARITH_TEMP_1,(DS_REG)
	ret

DEF(void,primitive_fixnum_subtract,(void *myvm)):
	mov ARG0, ARG2  /* save vm ptr for overflow */
	mov (DS_REG),ARG1
	mov -CELL_SIZE(DS_REG),ARG0
	sub $CELL_SIZE,DS_REG
	mov ARG0,ARITH_TEMP_1
	sub ARG1,ARITH_TEMP_1
	jo MANGLE(overflow_fixnum_subtract)
	mov ARITH_TEMP_1,(DS_REG)
	ret

DEF(void,primitive_fixnum_multiply,(void *myvm)):
	push ARG0  /* save vm ptr for overflow */
	mov (DS_REG),ARITH_TEMP_1
	mov ARITH_TEMP_1,DIV_RESULT
	mov -CELL_SIZE(DS_REG),ARITH_TEMP_2
	sar $3,ARITH_TEMP_2
	sub $CELL_SIZE,DS_REG
	imul ARITH_TEMP_2
	jo multiply_overflow
	mov DIV_RESULT,(DS_REG)
	pop ARG2
	ret
multiply_overflow:
	sar $3,ARITH_TEMP_1
	mov ARITH_TEMP_1,ARG0
	mov ARITH_TEMP_2,ARG1
	pop ARG2
	jmp MANGLE(overflow_fixnum_multiply)

DEF(F_FASTCALL void,c_to_factor,(CELL quot, void *vm)):
	PUSH_NONVOLATILE
	mov ARG0,NV_TEMP_REG
	
	/* Create register shadow area for Win64 */
	sub $32,STACK_REG
	
	/* Save stack pointer */
	lea -CELL_SIZE(STACK_REG),ARG0
	call MANGLE(save_callstack_bottom)
	
	/* Call quot-xt */
	mov NV_TEMP_REG,ARG0
	call *QUOT_XT_OFFSET(ARG0)

	/* Tear down register shadow area */
	add $32,STACK_REG

	POP_NONVOLATILE
	ret

/* cpu.x86.features calls this */
DEF(bool,sse_version,(void)):
	mov $0x1,RETURN_REG
	cpuid
	test $0x100000,%ecx
	jnz sse_42
	test $0x80000,%ecx
	jnz sse_41
	test $0x200,%ecx
	jnz ssse_3
	test $0x1,%ecx
	jnz sse_3
	test $0x4000000,%edx
	jnz sse_2
	test $0x2000000,%edx
	jnz sse_1
	mov $0,%eax
	ret
sse_42:
	mov $42,RETURN_REG
	ret
sse_41:
	mov $41,RETURN_REG
	ret
ssse_3:
	mov $33,RETURN_REG
	ret
sse_3:
	mov $30,RETURN_REG
	ret
sse_2:
	mov $20,RETURN_REG
	ret
sse_1:
	mov $10,RETURN_REG
	ret

#ifdef WINDOWS
	.section .drectve
	.ascii " -export:sse_version"
	.ascii " -export:c_to_factor"
#endif
