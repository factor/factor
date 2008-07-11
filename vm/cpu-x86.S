DEF(F_FASTCALL void,c_to_factor,(CELL quot)):
	PUSH_NONVOLATILE
	push ARG0                             /* Save quot */

	lea -CELL_SIZE(STACK_REG),ARG0        /* Save stack pointer */
	call MANGLE(save_callstack_bottom)

	mov (STACK_REG),ARG0                  /* Pass quot as arg 1 */
	call *QUOT_XT_OFFSET(ARG0)            /* Call quot-xt */

	POP ARG0
	POP_NONVOLATILE
	ret

DEF(F_FASTCALL void,throw_impl,(CELL quot, F_STACK_FRAME *rewind_to)):
	mov ARG1,STACK_REG                    /* rewind_to */
	jmp *QUOT_XT_OFFSET(ARG0)

DEF(FASTCALL void,lazy_jit_compile,(CELL quot)):
	mov STACK_REG,ARG1           /* Save stack pointer */
	push ARG1                    /* Alignment */
	push ARG1
	push ARG1
	call MANGLE(primitive_jit_compile)
	mov RETURN_REG,ARG0          /* No-op on 32-bit */
	pop ARG1                     /* OK to clobber ARG1 here */
	pop ARG1
	pop ARG1
        jmp *QUOT_XT_OFFSET(ARG0)    /* Call the quotation */

#ifdef WINDOWS
	.section .drectve
	.ascii " -export:c_to_factor"
#endif
