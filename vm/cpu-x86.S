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

DEF(FASTCALL void,lazy_jit_compile,(CELL quot)):
	mov STACK_REG,ARG1           /* Save stack pointer */
	sub $STACK_PADDING,STACK_REG
	call MANGLE(primitive_jit_compile)
	mov RETURN_REG,ARG0          /* No-op on 32-bit */
	add $STACK_PADDING,STACK_REG
        jmp *QUOT_XT_OFFSET(ARG0)    /* Call the quotation */

#ifdef WINDOWS
	.section .drectve
	.ascii " -export:c_to_factor"
#endif
