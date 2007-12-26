#define JUMP_QUOT jmp *QUOT_XT_OFFSET(ARG0)

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

DEF(F_FASTCALL void,undefined,(CELL word)):
	mov STACK_REG,ARG1                    /* Pass callstack pointer */
	jmp MANGLE(undefined_error)           /* This throws an error */

DEF(F_FASTCALL void,primitive_call,(void)):
        mov (DS_REG),ARG0                     /* Load quotation from data stack */
	sub $CELL_SIZE,DS_REG                 /* Pop data stack */
	JUMP_QUOT

/* Don't mess up EDX, it's the callstack top parameter to primitives. */
DEF(F_FASTCALL void,primitive_execute,(void)):
	mov (DS_REG),ARG0                     /* Load word from data stack */
	sub $CELL_SIZE,DS_REG                 /* Pop data stack */
        jmp *WORD_XT_OFFSET(ARG0)             /* Load word-xt slot */

DEF(F_FASTCALL void,throw_impl,(CELL quot, F_STACK_FRAME *rewind_to)):
	mov ARG1,STACK_REG                    /* rewind_to */
	JUMP_QUOT

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
        JUMP_QUOT                    /* Call the quotation */

#ifdef WINDOWS
	.section .drectve
	.ascii " -export:c_to_factor"
#endif
