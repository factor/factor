#define JUMP_QUOT \
	mov QUOT_XT_OFFSET(ARG0),XT_REG ;     /* Load quot-xt */ \
	jmp *XT_REG                           /* Jump to quot-xt */

DEF(F_FASTCALL void,c_to_factor,(CELL quot)):
	PUSH_NONVOLATILE
	push ARG0                             /* Save quot */

	lea -CELL_SIZE(STACK_REG),ARG0        /* Save stack pointer */
	call MANGLE(save_callstack_bottom)

	mov (STACK_REG),ARG0                  /* Pass quot as arg 1 */
	mov QUOT_XT_OFFSET(ARG0),XT_REG
	call *XT_REG                          /* Call quot-xt */

	POP ARG0
	POP_NONVOLATILE
	ret

DEF(F_FASTCALL void,undefined,(CELL word)):
	mov STACK_REG,ARG1                    /* Pass callstack pointer */
	jmp MANGLE(undefined_error)           /* This throws an error */

DEF(F_FASTCALL void,dosym,(CELL word)):
	add $CELL_SIZE,DS_REG                 /* Increment stack pointer */
	mov ARG0,(DS_REG)                     /* Store word on stack */
	ret

/* Here we have two entry points. The first one is taken when profiling is
enabled */
DEF(F_FASTCALL void,docol_profiling,(CELL word)):
	add $8,PROFILING_OFFSET(ARG0)         /* Increment profile-count slot */
DEF(F_FASTCALL void,docol,(CELL word)):
	mov WORD_DEF_OFFSET(ARG0),ARG0        /* Load word-def slot */
	JUMP_QUOT

/* We must pass the XT to the quotation in ECX. */
DEF(F_FASTCALL void,primitive_call,(void)):
        mov (DS_REG),ARG0                     /* Load quotation from data stack */
	sub $CELL_SIZE,DS_REG                 /* Pop data stack */
	JUMP_QUOT

/* We pass the word in EAX and the XT in ECX. Don't mess up EDX, it's the
callstack top parameter to primitives. */
DEF(F_FASTCALL void,primitive_execute,(void)):
	mov (DS_REG),ARG0                     /* Load word from data stack */
	sub $CELL_SIZE,DS_REG                 /* Pop data stack */
        mov WORD_XT_OFFSET(ARG0),XT_REG       /* Load word-xt slot */
	jmp *XT_REG                           /* Go */

DEF(F_FASTCALL void,throw_impl,(CELL quot, F_STACK_FRAME *rewind_to)):
	mov ARG1,STACK_REG                    /* rewind_to */
	JUMP_QUOT

DEF(FASTCALL void,lazy_jit_compile,(CELL quot)):
	mov STACK_REG,ARG1           /* Save stack pointer */
	push XT_REG                  /* Alignment */
	push XT_REG
	push XT_REG
	call MANGLE(primitive_jit_compile)
	mov RETURN_REG,ARG0          /* No-op on 32-bit */
	pop XT_REG                   /* OK to clobber XT_REG here */
	pop XT_REG
	pop XT_REG
        JUMP_QUOT                    /* Call the quotation */
