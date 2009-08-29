DEF(void,primitive_fixnum_add,(void)):
    mov (DS_REG),ARG0
    mov -CELL_SIZE(DS_REG),ARG1
    sub $CELL_SIZE,DS_REG
    mov ARG1,ARITH_TEMP_1
    add ARG0,ARITH_TEMP_1
    jo MANGLE(overflow_fixnum_add)
    mov ARITH_TEMP_1,(DS_REG)
    ret

DEF(void,primitive_fixnum_subtract,(void)):
    mov (DS_REG),ARG1
    mov -CELL_SIZE(DS_REG),ARG0
    sub $CELL_SIZE,DS_REG
    mov ARG0,ARITH_TEMP_1
    sub ARG1,ARITH_TEMP_1
    jo MANGLE(overflow_fixnum_subtract)
    mov ARITH_TEMP_1,(DS_REG)
    ret

DEF(void,primitive_fixnum_multiply,(void)):
    mov (DS_REG),ARITH_TEMP_1
    mov ARITH_TEMP_1,DIV_RESULT
    mov -CELL_SIZE(DS_REG),ARITH_TEMP_2
    sar $3,ARITH_TEMP_2
    sub $CELL_SIZE,DS_REG
    imul ARITH_TEMP_2
    jo multiply_overflow
    mov DIV_RESULT,(DS_REG)
    ret
multiply_overflow:
    sar $3,ARITH_TEMP_1
    mov ARITH_TEMP_1,ARG0
    mov ARITH_TEMP_2,ARG1
    jmp MANGLE(overflow_fixnum_multiply)

DEF(F_FASTCALL void,c_to_factor,(CELL quot)):
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

DEF(F_FASTCALL void,throw_impl,(CELL quot, F_STACK_FRAME *rewind_to)):
	/* rewind_to */
	mov ARG1,STACK_REG                    
	jmp *QUOT_XT_OFFSET(ARG0)

DEF(F_FASTCALL void,lazy_jit_compile,(CELL quot)):
	mov STACK_REG,ARG1           /* Save stack pointer */
	sub $STACK_PADDING,STACK_REG
	call MANGLE(lazy_jit_compile_impl)
	mov RETURN_REG,ARG0          /* No-op on 32-bit */
	add $STACK_PADDING,STACK_REG
        jmp *QUOT_XT_OFFSET(ARG0)    /* Call the quotation */

#ifdef WINDOWS
	.section .drectve
	.ascii " -export:c_to_factor"
#endif
