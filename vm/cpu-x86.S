DEF(F_FASTCALL void,c_to_factor,(CELL quot, void *vm)):
	PUSH_NONVOLATILE
	mov ARG0,NV0
	mov ARG1,NV1

    /* Save old stack pointer and align */
    mov STACK_REG,ARG0
    and $-16,STACK_REG
    add $CELL_SIZE,STACK_REG
    push ARG0

	/* Create register shadow area for Win64 */
	sub $32,STACK_REG

	/* Load context */
    mov (NV1),ARG0

    /* Save ctx->callstack_bottom */
	lea -CELL_SIZE(STACK_REG),ARG1
    mov ARG1,CELL_SIZE(ARG0)

    /* Load ctx->datastack */
    mov (CELL_SIZE * 2)(ARG0),DS_REG

    /* Load ctx->retainstack */
    mov (CELL_SIZE * 3)(ARG0),RS_REG

	/* Call quot-xt */
	mov NV0,ARG0
	mov NV1,ARG1
	call *QUOT_XT_OFFSET(ARG0)

	/* Tear down register shadow area */
	add $32,STACK_REG

    /* Undo stack alignment */
    mov (STACK_REG),STACK_REG

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
