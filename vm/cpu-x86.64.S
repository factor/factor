#include "asm.h"

#define STACK_REG %rsp
#define DS_REG %r14
#define RS_REG %r15
#define RETURN_REG %rax

#define CELL_SIZE 8
#define STACK_PADDING 56

#define NV0 %rbp
#define NV1 %r12

#ifdef WINDOWS

	#define ARG0 %rcx
	#define ARG1 %rdx
	#define ARG2 %r8
	#define ARG3 %r9

	#define PUSH_NONVOLATILE \
		push %r15 ; \
		push %r14 ; \
		push %r12 ; \
		push %r13 ; \
		push %rdi ; \
		push %rsi ; \
		push %rbx ; \
		push %rbp

	#define POP_NONVOLATILE \
		pop %rbp ; \
		pop %rbx ; \
		pop %rsi ; \
		pop %rdi ; \
		pop %r13 ; \
		pop %r12 ; \
		pop %r14 ; \
		pop %r15

#else

	#define ARG0 %rdi
	#define ARG1 %rsi
	#define ARG2 %rdx
	#define ARG3 %rcx

	#define PUSH_NONVOLATILE \
		push %rbx ; \
		push %rbp ; \
		push %r12 ; \
		push %r13 ; \
		push %r14 ; \
		push %r15

	#define POP_NONVOLATILE \
		pop %r15 ; \
		pop %r14 ; \
		pop %r13 ; \
		pop %r12 ; \
		pop %rbp ; \
		pop %rbx

#endif

#define QUOT_XT_OFFSET 28

DEF(F_FASTCALL void,c_to_factor,(CELL quot, void *vm)):
	PUSH_NONVOLATILE
	mov ARG0,NV0
	mov ARG1,NV1

	push ARG0
	push ARG1

	/* Create register shadow area (required for Win64 only) */
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

	/* Load context */
	pop ARG1
	pop ARG0
	mov (ARG1),ARG0

	/* Save ctx->datastack */
	mov DS_REG,(CELL_SIZE * 2)(ARG0)

	/* Save ctx->retainstack */
	mov RS_REG,(CELL_SIZE * 3)(ARG0)

	POP_NONVOLATILE
	ret

/* We pass a function pointer to memcpy to work around a Mac OS X
ABI limitation which would otherwise require us to do a bizzaro PC-relative
trampoline to retrieve the function address */
DEF(void,set_callstack,(F_STACK_FRAME *to, F_STACK_FRAME *from, CELL length, void *memcpy)):
	sub ARG2,ARG0                      /* compute new stack pointer */
	mov ARG0,%rsp
	call *ARG3                         /* call memcpy */
	ret                                /* return _with new stack_ */

DEF(F_FASTCALL void,throw_impl,(CELL quot, F_STACK_FRAME *rewind_to, void *vm)):
	/* clear x87 stack, but preserve rounding mode and exception flags */
	sub $2,STACK_REG
	fnstcw (STACK_REG)
	fninit
	fldcw (STACK_REG)
	/* rewind_to */
	mov ARG1,STACK_REG
	mov ARG2,ARG1  /* make vm ptr 2nd arg in case quot_xt = lazy_jit_compile_impl */
	jmp *QUOT_XT_OFFSET(ARG0)

DEF(F_FASTCALL void,lazy_jit_compile_impl,(CELL quot, void *vm)):
	mov ARG1,ARG2                /* vm is 3rd arg */
	mov STACK_REG,ARG1           /* Save stack pointer */
	sub $STACK_PADDING,STACK_REG
	call MANGLE(lazy_jit_compile)
	mov RETURN_REG,ARG0          /* No-op on 32-bit */
	add $STACK_PADDING,STACK_REG
        jmp *QUOT_XT_OFFSET(ARG0)    /* Call the quotation */

DEF(long long,read_timestamp_counter,(void)):
	mov $0,%rax
	rdtsc
	shl $32,%rdx
	or %rdx,%rax
	ret

DEF(void,get_sse_env,(void*)):
	stmxcsr (%rdi)
	ret

DEF(void,set_sse_env,(const void*)):
	ldmxcsr (%rdi)
	ret

DEF(void,get_x87_env,(void*)):
	fnstsw (%rdi)
	fnstcw 2(%rdi)
	ret

DEF(void,set_x87_env,(const void*)):
	fnclex
	fldcw 2(%rdi)
	ret
	
#include "cpu-x86.S"
